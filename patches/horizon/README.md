# Horizon patches

Patches are **unified diffs** applied to a synced Supermium/`src` tree with `git apply` (or `patch -p1`).

## Rules

1. Keep patches small and branded/policy-focused—do not duplicate Supermium’s Win7 compat work.
2. Record every file in [`SERIES`](SERIES) in apply order.
3. After bumping `SUPERMIUM_REF`, refresh patches (`git apply` dry-run, then regenerate).
4. Note Chromium path drift in the patch header commit message area.

## Creating a new patch

From the Chromium `src` directory after making edits:

```bat
git diff -- chrome/path/file.cc > C:\path\to\repo\patches\horizon\0003-my-change.patch
```

Add the filename to `SERIES`, then run `scripts/apply-patches.ps1 -DryRun` on a clean tree.
