# Horizon architecture

## Goal

Ship a branded Chromium browser that runs on **Windows 7 SP1+** and can receive feature/security updates for ~5 years by rebasing onto Win7-compatible Chromium forks—primarily [Supermium](https://github.com/win32ss/supermium).

## Why not stock Chromium?

Google Chromium dropped Windows 7 after the 109 line. Newer Chromium binaries import APIs that do not exist on Win7. Supermium (and similar forks) keep rebasing upstream Chromium and route missing APIs through compatibility wrappers (`progwrp`), with a post-link **import table patcher** so PE files load on Win7.

## Pipeline

```text
Chromium upstream
       │
       ▼
Supermium (Win7 + newer Chromium)
       │
       ▼
Horizon overlays (branding / policies / patches)
       │
       ▼
Windows build (GN + Ninja → chrome, mini_installer)
       │
       ▼
progwrp import patcher on .exe / .dll
       │
       ▼
Installer + portable zip for Win7 SP1+
```

## Components

| Piece | Lives where | Role |
| --- | --- | --- |
| Chromium / Supermium source | Build machine only (not this git repo) | Browser engine and UI |
| `VERSION` + pin metadata | This repo | Exact tag/commit to sync |
| `patches/horizon/` | This repo | Branding and policy diffs |
| `branding/` | This repo | Names, IDs, icons |
| `policies/` | This repo | Recommended defaults |
| `progwrp` + patcher | Supermium release tooling | Win7 API compatibility |

## Channels

- **Stable** — Follow a tested Supermium release tag (prefer ESR-style lines when available).
- **Security** — Hotfix branch that cherry-picks critical Chromium advisories onto the last Stable pin when a full rebase is not ready.

## Longevity model (5 years)

Horizon ages well only if updates continue:

1. **Weekly / as disclosed** — Watch Chromium security blogs and Supermium releases.
2. **Per major** — Bump `VERSION`, refresh patches, rebuild, smoke-test Win7 SP1 x64.
3. **Quarterly** — Broader compatibility matrix (see [smoke-test.md](smoke-test.md)).
4. **Yearly** — Decide whether Supermium (or your own compat layer) remains viable. If not, freeze the last good pin and document a Windows 10+ migration path.

### Risk

Supermium maintenance capacity is limited. If upstream Win7 support stops, Horizon must either:

- absorb and maintain the compat patches in-house, or
- stop claiming “current Chromium on Win7” and migrate users forward.

## Security model (honest)

| Layer | Expectation |
| --- | --- |
| Blink / V8 / network stack | Tracks Chromium when you rebase |
| Site isolation / sandbox | Present but constrained by Win7 kernel APIs |
| OS TLS / crypto / drivers | Win7 EOL risk remains |
| Auto-update | You must host or wire an update endpoint; do not ship without a patch channel |

## Non-goals

- Vendoring the multi-GB Chromium tree into this GitHub repo
- Windows XP / Vista support
- Electron/CEF as the primary engine (they follow official Chromium OS cutoffs)
- Claiming equal security to Chrome on Windows 10/11
