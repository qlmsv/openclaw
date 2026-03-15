#!/bin/sh
set -eu

# Render runtime can be tight on memory during startup. Give Node a bit more heap
# to avoid early OOM while still staying under the container limit.
: "${NODE_OPTIONS:=--max-old-space-size=1536}"
export NODE_OPTIONS

gateway_port="${PORT:-${OPENCLAW_GATEWAY_PORT:-18789}}"
gateway_bind="${OPENCLAW_GATEWAY_BIND:-loopback}"
allow_host_header_fallback="${OPENCLAW_GATEWAY_ALLOW_HOST_HEADER_ORIGIN_FALLBACK:-false}"
openclaw_data_dir="${OPENCLAW_DATA_DIR:-/data/.openclaw}"
workspace_dir="${OPENCLAW_WORKSPACE_DIR:-$openclaw_data_dir/workspace}"
home_dir="${HOME:-/home/node}"
home_skills_dir="$home_dir/.openclaw/workspace/skills"

export OPENCLAW_GATEWAY_PORT="$gateway_port"
export OPENCLAW_GATEWAY_BIND="$gateway_bind"

mkdir -p "$workspace_dir/skills" "$(dirname "$home_skills_dir")"

# Keep the workspace on persistent disk for container platforms like Render.
node openclaw.mjs config set agents.defaults.workspace "$workspace_dir" >/dev/null

# Mirror the default home-based skills path to the persistent workspace.
if [ -e "$home_skills_dir" ] && [ ! -L "$home_skills_dir" ]; then
  rm -rf "$home_skills_dir"
fi
if [ ! -e "$home_skills_dir" ]; then
  ln -s "$workspace_dir/skills" "$home_skills_dir"
fi

node openclaw.mjs config set gateway.mode local >/dev/null
node openclaw.mjs config set gateway.bind "$gateway_bind" >/dev/null
node openclaw.mjs config set gateway.port "$gateway_port" --strict-json >/dev/null

if [ "$allow_host_header_fallback" = "true" ]; then
  node openclaw.mjs config set gateway.controlUi.dangerouslyAllowHostHeaderOriginFallback true --strict-json >/dev/null
fi

exec node openclaw.mjs gateway run
