#!/usr/bin/env bash
# Ensure environment normalization for Home Assistant Supervisor
set -euo pipefail

# Supervisor passes options as env variables: translate possible lowercase/uppercase differences
# Nothing to normalize for now; just exec the CMD
exec "$@"
