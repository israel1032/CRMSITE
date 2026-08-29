import { describe, expect, it } from 'vitest';
import { isAppHost } from '@/lib/app-hosts';

describe('isAppHost', () => {
  it('preserves the hosted platform and Railway defaults when the env is unset', () => {
    expect(isAppHost('simplerdevelopment.com', '')).toBe(true);
    expect(isAppHost('staging.simplerdevelopment.com', '')).toBe(true);
    expect(isAppHost('preview.up.railway.app', '')).toBe(true);
    expect(isAppHost('tenant.example.com', '')).toBe(false);
  });

  it('adds comma-separated self-host domains without replacing the defaults', () => {
    const configured = 'app.example.com, admin.example.net';
    expect(isAppHost('app.example.com', configured)).toBe(true);
    expect(isAppHost('admin.example.net:3000', configured)).toBe(true);
    expect(isAppHost('simplerdevelopment.com', configured)).toBe(true);
    expect(isAppHost('tenant.example.com', configured)).toBe(false);
  });
});
