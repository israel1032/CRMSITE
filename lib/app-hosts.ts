const DEFAULT_APP_HOSTS = [
  'localhost',
  '127.0.0.1',
  'simplerdevelopment.com',
  'www.simplerdevelopment.com',
  'staging.simplerdevelopment.com',
];

/**
 * Public tenant sites share the root layout with the platform app, so the Host
 * header decides whether app chrome/auth providers are mounted. Self-hosted app
 * domains opt in through NEXT_PUBLIC_APP_HOSTS; an unset variable preserves the
 * hosted platform's historical allowlist exactly. SHOST-005.
 */
export function isAppHost(host: string, configuredHosts = process.env.NEXT_PUBLIC_APP_HOSTS): boolean {
  const hostname = host.split(':')[0];
  const additionalHosts = configuredHosts
    ?.split(',')
    .map((entry) => entry.trim())
    .filter(Boolean) ?? [];

  return (
    DEFAULT_APP_HOSTS.includes(hostname) ||
    additionalHosts.includes(hostname) ||
    hostname.endsWith('.railway.app')
  );
}
