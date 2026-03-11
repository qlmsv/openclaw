#!/bin/sh
set -eu

gateway_port="${PORT:-${OPENCLAW_GATEWAY_PORT:-18789}}"

node -e "fetch('http://127.0.0.1:' + process.argv[1] + '/healthz').then((r)=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))" "$gateway_port"
