#!/bin/sh
set -eu

gateway_port="${PORT:-${OPENCLAW_GATEWAY_PORT:-18789}}"
gateway_bind="${OPENCLAW_GATEWAY_BIND:-loopback}"
allow_host_header_fallback="${OPENCLAW_GATEWAY_ALLOW_HOST_HEADER_ORIGIN_FALLBACK:-false}"

export OPENCLAW_GATEWAY_PORT="$gateway_port"
export OPENCLAW_GATEWAY_BIND="$gateway_bind"

node openclaw.mjs config set gateway.mode local >/dev/null
node openclaw.mjs config set gateway.bind "$gateway_bind" >/dev/null

if [ "$allow_host_header_fallback" = "true" ]; then
  node openclaw.mjs config set gateway.controlUi.dangerouslyAllowHostHeaderOriginFallback true --strict-json >/dev/null
fi

exec node openclaw.mjs gateway --bind "$gateway_bind" --port "$gateway_port"
