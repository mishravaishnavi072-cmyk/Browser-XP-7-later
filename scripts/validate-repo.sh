#!/usr/bin/env bash
# Lightweight validation for the Horizon control-plane repo (runs on Linux CI).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "== required files =="
required=(
  README.md
  VERSION
  docs/architecture.md
  docs/build-windows.md
  docs/smoke-test.md
  docs/security-updates.md
  branding/product.json
  patches/horizon/SERIES
  policies/recommended.json
  scripts/apply-patches.ps1
  scripts/apply-branding.ps1
  scripts/sync-supermium.ps1
  scripts/patch-progwrp.ps1
  scripts/release-checklist.ps1
)
for f in "${required[@]}"; do
  [[ -f "$f" ]] || { echo "MISSING $f"; exit 1; }
  echo "ok $f"
done

echo "== VERSION keys =="
for key in PRODUCT_NAME PRODUCT_VERSION SUPERMIUM_REPO SUPERMIUM_REF CHROMIUM_VERSION_LABEL; do
  grep -q "^${key}=" VERSION || { echo "VERSION missing $key"; exit 1; }
done

echo "== product.json =="
python3 - <<'PY'
import json
from pathlib import Path
p = json.loads(Path("branding/product.json").read_text())
for k in ("productName", "userDataDirName", "defaultSearchUrl"):
    assert k in p and p[k], k
print("ok product.json")
PY

echo "== SERIES patches exist =="
while IFS= read -r line; do
  line="${line%%#*}"
  line="$(echo "$line" | tr -d '[:space:]')"
  [[ -z "$line" ]] && continue
  [[ -f "patches/horizon/$line" ]] || { echo "SERIES entry missing file: $line"; exit 1; }
  echo "ok patches/horizon/$line"
done < patches/horizon/SERIES

echo "== recommended.json =="
python3 - <<'PY'
import json
from pathlib import Path
json.loads(Path("policies/recommended.json").read_text())
print("ok policies/recommended.json")
PY

echo "All control-plane checks passed."
