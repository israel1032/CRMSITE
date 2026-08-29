/**
 * The single source of truth for "does this deployment use Secure cookies?"
 *
 * This expression previously existed in three places — lib/auth.ts,
 * lib/plugins/tenant-cookie.ts and app/api/portal/sign-out/route.ts — each
 * carrying a comment saying it MUST mirror the others. That is the shape of a
 * bug waiting to happen, and it already happened once: a bare
 * `NODE_ENV === 'production'` check in the sign-out route diverged under the
 * e2e combo and left the real session cookie intact, so sign-out silently
 * no-op'd (QAD-047). Import this instead of restating the condition.
 */

/**
 * `AUTH_INSECURE_COOKIES=1` drops the `Secure` flag and the `__Secure-` name
 * prefix. It exists for a production BUILD served over plain HTTP — the
 * Critical-e2e CI job runs `bun start` on http://localhost:3000, and a
 * self-hoster may intentionally expose a plain-HTTP origin. Without it the
 * browser rejects the `__Secure-`-prefixed cookie on an insecure origin, which
 * surfaced as a 500 on the credentials callback and cascaded ~1000 e2e specs
 * (QAD-047).
 *
 * The hazard the flag carried: nothing stopped it being copy-pasted into a real
 * HTTPS production environment — cloning a CI env-var set is the obvious way in
 * — which would silently ship the session cookie over plaintext HTTP, i.e. a
 * MITM/downgrade path to session theft. httpOnly stays true either way, so this
 * was never XSS exposure, but it was a real transport exposure.
 *
 * So the flag is now honoured everywhere EXCEPT a real production deploy, where
 * it is ignored and loudly logged. `VERCEL_ENV === 'production'` is the signal:
 * Vercel sets it only on the production deployment (previews get 'preview'), and
 * it is absent in CI and self-host, so neither legitimate use of the flag
 * regresses. AUTH79-018.
 */
export function secureCookiesEnabled(): boolean {
  // Non-production builds (dev, test) never use Secure cookies — localhost is
  // http and the browser would reject them.
  if (process.env.NODE_ENV !== 'production') return false;

  if (process.env.AUTH_INSECURE_COOKIES !== '1') {
    warnSecureCookieOnInsecureOrigin();
    return true;
  }

  if (process.env.VERCEL_ENV === 'production') {
    warnIgnoredOnProd();
    warnSecureCookieOnInsecureOrigin();
    return true; // refuse the escape hatch on a real production deploy
  }

  return false;
}

let warned = false;
let warnedInsecureOrigin = false;

/**
 * A production server can start successfully with an http:// auth URL while
 * still issuing a __Secure- cookie. The callback then returns a valid JWT but
 * the browser discards it, producing a silent login loop that looks unrelated
 * to cookies from outside the server. Detect that configuration at module boot
 * (secureCookiesEnabled is evaluated by lib/auth.ts) and log it once. The
 * cookie policy itself is unchanged; AUTH_INSECURE_COOKIES=1 remains the
 * explicit self-host opt-in for a genuinely plaintext public origin. AUTH79-021.
 */
function warnSecureCookieOnInsecureOrigin(): void {
  if (warnedInsecureOrigin) return;

  const authUrl = process.env.AUTH_URL ?? process.env.NEXTAUTH_URL;
  if (!authUrl) return;

  try {
    if (new URL(authUrl).protocol === 'https:') return;
  } catch {
    // URL validation belongs to Auth.js. This warning only diagnoses the
    // valid-but-insecure configuration that causes the silent cookie drop.
    return;
  }

  warnedInsecureOrigin = true;
  console.error(
    JSON.stringify({
      level: 'error',
      event: 'auth.secure_cookie_on_insecure_origin',
      message:
        'Production is configured with an HTTP AUTH_URL/NEXTAUTH_URL while Secure session cookies are enabled. Browsers will discard the session cookie. Serve the public origin over HTTPS, or set AUTH_INSECURE_COOKIES=1 only when the public origin is intentionally plain HTTP.',
    }),
  );
}

function warnIgnoredOnProd(): void {
  if (warned) return;
  warned = true;
  console.error(
    JSON.stringify({
      level: 'error',
      event: 'auth.insecure_cookies_ignored',
      message:
        'AUTH_INSECURE_COOKIES=1 is set on a production deploy (VERCEL_ENV=production) and is being IGNORED. Secure cookies stay enabled. Remove this variable — it belongs to CI/self-host-over-HTTP only.',
    }),
  );
}

/** Test-only: reset the warn-once latch so each case can assert the log. */
export function __resetSecureCookieWarning(): void {
  warned = false;
  warnedInsecureOrigin = false;
}
