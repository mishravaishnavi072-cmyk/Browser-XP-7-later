# Branding

Edit [`product.json`](product.json) to rename the browser. Keep IDs stable once you ship—changing `userDataDirName` orphans existing profiles.

## Assets

Place icons here before a branded release:

| File | Purpose |
| --- | --- |
| `assets/icon.ico` | Windows application icon (multi-resolution) |
| `assets/logo.png` | About / installer artwork (optional) |
| `assets/installer.bmp` | mini_installer side graphic (optional) |

Placeholder notes live in [`assets/PLACEHOLDERS.md`](assets/PLACEHOLDERS.md).

## Applying to Chromium / Supermium

Chromium branding is spread across GRIT resources, installer strings, and `chrome/app` themes. Horizon’s first overlay focuses on string replacements via patches in `patches/horizon/`. For a deeper rebrand (icons, installer), copy assets into the corresponding Chromium paths documented in the patch headers after you sync the pinned Supermium tree.

Suggested Chromium touchpoints (exact paths vary by major):

- `chrome/app/theme/` — product icons
- `chrome/app/resources/` — localized strings
- `chrome/installer/` — installer product name
- `chrome/common/chrome_constants.cc` / related — directory names (prefer patch)

Always rebuild after branding changes and confirm `chrome://version` shows Horizon strings.
