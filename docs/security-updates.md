# Security update process

Horizon’s security posture is only as good as its rebase discipline.

## Sources to monitor

1. [Chromium security updates / Chrome releases](https://chromereleases.googleblog.com/)
2. [Supermium releases](https://github.com/win32ss/supermium/releases)
3. Critical CVEs affecting V8, Blink, network stack, or sandbox escape

## Severity triage

| Severity | Target response |
| --- | --- |
| Critical (active exploit / sandbox escape) | Security channel hotfix within days if a patch exists upstream |
| High | Fold into next Stable pin or dedicated Security build within the current sprint |
| Medium / Low | Next scheduled major rebase |

## Hotfix procedure

1. Identify the Chromium commit(s) or Supermium tag that contain the fix.
2. Prefer bumping `SUPERMIUM_REF` in [`VERSION`](../VERSION) to a Supermium release that already includes the fix.
3. If Supermium has not shipped yet and you maintain local expertise, cherry-pick onto the last Horizon pin **only** when the patch applies cleanly—document every cherry-pick in `patches/horizon/SERIES` notes.
4. Rebuild official binaries, run progwrp patching, execute [smoke-test.md](smoke-test.md).
5. Publish release notes listing Chromium advisory IDs and the new pin.
6. Notify users through your update channel (see `policies/recommended.json` `HomepageLocation` / update URL placeholders).

## What not to do

- Do not ship unpatched Stable for weeks while “waiting for a big rebase” if a critical fix is available on a nearby Supermium tag.
- Do not claim “latest Google Chrome security” unless the pin matches that Chromium security revision.
- Do not disable the sandbox to “fix” Win7 crashes in production builds.

## Yearly reassessment

Each year, record in a GitHub issue:

- Is Supermium (or successor) still producing Win7 builds?
- How many weeks behind Chromium Stable is the current pin?
- Is the in-house team able to maintain progwrp-class shims if upstream stops?

If the answer to the first is no and the third is no, freeze the last good pin and publish a Windows 10+ migration guide.
