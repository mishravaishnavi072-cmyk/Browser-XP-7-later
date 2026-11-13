# Windows 7 smoke-test checklist

Run on a clean **Windows 7 SP1 x64** VM (and optionally x86) after every Stable or Security build.

## Environment

- [ ] Win7 SP1 + SHA-2 code signing support / convenience updates installed
- [ ] No residual Chrome/Chromium user-data collisions (or use a fresh profile path)
- [ ] Build under test recorded: Horizon version, `SUPERMIUM_REF`, patcher version

## Launch and UI

- [ ] `chrome.exe` / Horizon starts without missing-DLL dialogs
- [ ] New tab, address bar navigation, back/forward, reload
- [ ] Bookmarks bar create / open / delete
- [ ] Settings page opens (`chrome://settings`)
- [ ] `chrome://version` shows expected branding and Chromium version label

## Web platform

- [ ] HTTPS site with modern TLS (e.g. a major bank or Google) loads
- [ ] YouTube playback (HTML5) for a short clip
- [ ] PDF opens in the built-in viewer
- [ ] File download completes and opens from the shelf
- [ ] WebRTC smoke (meet/jitsi test call) if Widevine/media stack is in scope

## Extensions and sandbox

- [ ] Install a known-good Manifest V2/V3 extension allowed by this pin
- [ ] Extension survives restart
- [ ] Sandbox remains enabled (`chrome://sandbox` / task manager detail as available)
- [ ] Multiple tabs with site isolation do not immediately crash the browser

## Graphics

- [ ] Page scroll remains responsive for 10+ minutes
- [ ] If freezes occur, note GPU flags (`#ignore-gpu-blocklist`, hardware acceleration off) and file a regression note

## Packaging

- [ ] `mini_installer` install + uninstall leaves no broken shortcuts
- [ ] Portable zip runs from a non-ASCII path and from a path with spaces
- [ ] Default browser prompt behaves acceptably on Win7

## Sign-off

| Role | Name | Date | Result |
| --- | --- | --- | --- |
| Builder | | | pass / fail |
| Win7 tester | | | pass / fail |

Attach crash dumps / `chrome://version` screenshots to the release issue when failing.
