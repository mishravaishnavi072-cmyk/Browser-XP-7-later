# Building Horizon on Windows

Horizon binaries are produced on a **Windows 10/11** build machine, then patched for **Windows 7 SP1** runtime. This Linux/cloud environment cannot complete a full Chromium compile.

## Machine requirements

| Resource | Recommendation |
| --- | --- |
| OS | Windows 10 or 11 (x64) |
| CPU / RAM | High core count; **~35 GB** RAM or pagefile for linking |
| Disk | 100 GB+ free (SSD strongly preferred) |
| Toolchain | Visual Studio 2022 with C++ desktop workload |
| SDK | Windows 10/11 SDK (match Chromium/Supermium docs for the pinned tag) |
| Tools | [`depot_tools`](https://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html) on `PATH` |

Also install Git for Windows and a recent Python 3 (Chromium’s depot_tools may vendor its own).

## 1. Install depot_tools

Follow Chromium’s [Windows build instructions](https://chromium.googlesource.com/chromium/src/+/main/docs/windows_build_instructions.md):

1. Clone `depot_tools`.
2. Add it to `PATH`.
3. Open a **fresh** `cmd.exe` or Developer PowerShell and run `gclient` once so it bootstraps.

Set (as needed for your environment):

```bat
set DEPOT_TOOLS_WIN_TOOLCHAIN=0
```

(Use Chromium’s documented toolchain settings for your VS/SDK setup.)

## 2. Read the Horizon pin

Open [`VERSION`](../VERSION) in this repository. Note:

- `SUPERMIUM_REPO`
- `SUPERMIUM_REF` (tag or commit)
- `CHROMIUM_VERSION_LABEL` (human-readable)

Do not sync “latest main” for releases—always pin.

## 3. Fetch Supermium

From a short path (e.g. `C:\src\horizon-build`) to avoid Windows path-length issues:

```bat
mkdir C:\src\horizon-build
cd C:\src\horizon-build

REM Example: configure gclient for Supermium (adjust URL/ref from VERSION)
gclient config --name=src https://github.com/win32ss/supermium.git
```

Checkout the pinned ref inside `src`, then sync dependencies. Supermium maintainers often recommend merge-friendly sync so custom third_party repos are not overwritten:

```bat
cd src
git fetch --tags
git checkout <SUPERMIUM_REF>

cd ..
gclient sync -D --with_branch_heads --with_tags
```

If Supermium documents `gclient sync -m` / `--merge` for your tag, prefer that over a blind overwrite of customized third_party trees. See upstream issues on [building Supermium](https://github.com/win32ss/supermium/issues).

Run hooks after a successful sync:

```bat
gclient runhooks
```

## 4. Apply Horizon overlays

Clone or copy **this** repository next to the build tree (or pass `-HorizonRoot`):

```powershell
powershell -ExecutionPolicy Bypass -File C:\path\to\Browser-XP-7-later\scripts\apply-patches.ps1 -ChromiumSrc C:\src\horizon-build\src
```

Copy branding assets per [branding/README.md](../branding/README.md).

## 5. GN args

Generate a release output directory:

```bat
cd C:\src\horizon-build\src
gn gen out\HorizonRelease --args="is_debug=false is_official_build=true is_component_build=false symbol_level=1 blink_symbol_level=0"
```

Adjust args to match the pinned Supermium release notes (official builds may require additional flags). For faster local iteration only:

```bat
gn gen out\HorizonComponent --args="is_debug=false is_component_build=true"
```

Component builds are for developers; ship **non-component** official builds.

## 6. Build

```bat
ninja -C out\HorizonRelease chrome
ninja -C out\HorizonRelease mini_installer
```

Expect multi-hour first builds.

## 7. Win7 compatibility patch (progwrp)

Supermium ships (or documents) a **progwrp** wrapper DLL set and an import-table **patcher**. After a successful build:

1. Obtain `progwrp` binaries and `progwrp_patcher` for the same Supermium generation you pinned (from Supermium release assets / maintainer docs).
2. Copy required wrapper DLLs beside `chrome.exe`.
3. Run the patcher over every shipped `.exe` and `.dll` (see `scripts/patch-progwrp.ps1`).

Without this step, binaries often fail on Win7 with missing `kernel32` / delayed-import symbols (e.g. DPI APIs).

## 8. Package

- Prefer `mini_installer` output for setup.exe-style installs.
- Also zip a portable directory (patched binaries + locales + resources) for lab machines.
- Record the exact `SUPERMIUM_REF`, GN args, and patcher version in the GitHub release notes.

## 9. Verify

1. Install or unpack on a clean **Windows 7 SP1 x64** VM (with current Win7 convenience rollup / SHA-2 updates as required for TLS).
2. Run [smoke-test.md](smoke-test.md).
3. Only then promote to Stable.

## Helper scripts in this repo

| Script | Purpose |
| --- | --- |
| `scripts/sync-supermium.ps1` | Reminder/checklist wrapper around fetch + pin checkout |
| `scripts/apply-patches.ps1` | Apply `patches/horizon` in order |
| `scripts/patch-progwrp.ps1` | Invoke progwrp_patcher on a binary directory |
| `scripts/release-checklist.ps1` | Print release gate checklist |

## Troubleshooting

- **Missing Win7 APIs at runtime** — Patcher not run, or wrapper DLLs not deployed next to `chrome.exe`.
- **`gclient sync` wiped custom third_party** — Use the merge flags Supermium documents for that tag; re-checkout Supermium third_party remotes if needed.
- **Linker / memory failures** — Increase pagefile; close other apps; avoid parallel link storms.
- **Path too long** — Keep the tree under a short root like `C:\src\h`.
