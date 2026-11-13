# Policies

[`recommended.json`](recommended.json) lists defaults we want Horizon to ship with. On Windows, Chromium reads enterprise policies from the registry under keys that match your browser’s policy namespace (Chrome uses `Software\Policies\Google\Chrome`; a branded build typically uses a parallel path—confirm for your Supermium/Horizon branding).

## Applying

1. Replace `HorizonUpdateUrlPlaceholder` / `example.com` with your real update service.
2. Convert JSON keys to registry `REG_SZ` / `REG_DWORD` values as required by Chromium policy docs for your major.
3. Prefer policy for search/home/update over hard-coding, so enterprises can override.

## Win7 note

Some cloud-linked policies degrade gracefully when Google services are unavailable. Prefer disabling unused Google sync/signin in recommended defaults for privacy and reliability on offline-leaning Win7 machines.
