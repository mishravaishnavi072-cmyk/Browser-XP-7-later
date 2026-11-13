# Horizon

Chromium-based browser control plane for **Windows 7 SP1 and later**, designed to stay usable for roughly five years through continuous rebases—not a frozen Chrome 109 binary.

Horizon does **not** vendor the full Chromium tree. This repository holds branding, patches, policies, docs, and build/release scripts. You fetch a pinned [Supermium](https://github.com/win32ss/supermium) (Win7-compatible Chromium) checkout on a Windows build machine, apply Horizon overlays, build, then run the `progwrp` import patcher so binaries run on Windows 7.

## Support matrix

| OS | Status |
| --- | --- |
| Windows 7 SP1 (x86 / x64) | Primary target |
| Windows 8 / 8.1 | Supported (same build) |
| Windows 10 / 11 | Supported |
| Windows XP / Vista | Out of scope |

Official Google Chrome last supported Windows 7 at version **109**. Horizon tracks newer Chromium via Supermium’s compatibility layer.

## Security expectations

- Horizon can track modern Chromium security fixes **only while** you rebase onto updated Supermium/Chromium tags.
- Windows 7 is end-of-support. OS-level crypto, drivers, and some sandbox boundaries are weaker than on Windows 10/11.
- Do not claim parity with current Chrome on Windows 10+. See [docs/architecture.md](docs/architecture.md).

## Repository layout

```
branding/          Product name, IDs, icon placeholders
docs/              Architecture and Windows build guide
patches/horizon/   Branding and policy patches applied after Supermium sync
policies/          Recommended enterprise / default policies
scripts/           Sync, patch, and release helpers (run on Windows build box)
VERSION            Pinned Supermium / Chromium identity
```

## Quick start (Windows build machine)

1. Read [docs/build-windows.md](docs/build-windows.md).
2. Install Visual Studio, Windows SDK, and `depot_tools`.
3. Pin versions in [`VERSION`](VERSION) and sync Supermium.
4. Apply Horizon patches: `scripts/apply-patches.ps1`
5. Build `chrome` + `mini_installer`, then run the progwrp patcher.
6. Smoke-test on a real Windows 7 SP1 machine using [docs/smoke-test.md](docs/smoke-test.md).

## 5-year maintenance

| Cadence | Action |
| --- | --- |
| As disclosed | Monitor Chromium + Supermium advisories; cut hotfixes |
| Each Supermium major | Rebase overlays, rebuild, Win7 smoke-test |
| Quarterly | Compatibility pass (media, TLS, extensions, PDF, WebRTC) |
| Yearly | Reassess fork health; plan Win10+ migration if Win7 path stalls |

Details: [docs/architecture.md](docs/architecture.md) and [docs/security-updates.md](docs/security-updates.md).

## License

Horizon overlay files in this repository are MIT unless noted otherwise. Chromium, Supermium, and third-party components keep their own licenses—you must comply with those when you distribute binaries.
