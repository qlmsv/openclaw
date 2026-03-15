#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

rm -rf dist
mkdir -p dist

filters=(
  core-index
  core-entry
  core-daemon-cli
  core-warning-filter
  channels-runtime
  plugin-sdk-1
  plugin-sdk-2
  plugin-sdk-3
  plugin-sdk-4
  extension-api
  hooks
)

for filter in "${filters[@]}"; do
  echo "[build:docker] tsdown filter=${filter}"
  node scripts/tsdown-build.mjs --no-clean --filter "$filter"
done

node scripts/copy-plugin-sdk-root-alias.mjs
pnpm build:plugin-sdk:dts
node --import tsx scripts/write-plugin-sdk-entry-dts.ts
node --import tsx scripts/canvas-a2ui-copy.ts
node --import tsx scripts/copy-hook-metadata.ts
node --import tsx scripts/copy-export-html-templates.ts
node --import tsx scripts/write-build-info.ts
node --import tsx scripts/write-cli-startup-metadata.ts
node --import tsx scripts/write-cli-compat.ts
