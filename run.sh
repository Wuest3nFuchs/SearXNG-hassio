#!/usr/bin/env bash
set -euo pipefail

# default values from config.json options (Supervisor exports them as environment variables)
SEARXNG_VERSION="${SEARXNG_VERSION:-${options_searxng_version:-latest}}"
LISTEN_PORT="${LISTEN_PORT:-${options_listen_port:-8080}}"
BIND_ADDRESS="${BIND_ADDRESS:-${options_bind_address:-0.0.0.0}}"
BASE_URL="${BASE_URL:-${options_base_url:-}}"
PERSISTENCE_ENABLE="${PERSISTENCE_ENABLE:-${options_persistence_enable:-true}}"
PERSISTENCE_PATH="${PERSISTENCE_PATH:-${options_persistence_path:-/share/searxng}}"
SECRET_KEY="${SECRET_KEY:-${options_secret_key:-}}"

echo "[searxng-addon] Starting SearxNG add-on"
echo "[searxng-addon] Requested version: ${SEARXNG_VERSION}"
echo "[searxng-addon] Persistence: ${PERSISTENCE_ENABLE} -> ${PERSISTENCE_PATH}"

# Ensure persistence dir if enabled
if [ "${PERSISTENCE_ENABLE}" = "true" ] || [ "${PERSISTENCE_ENABLE}" = "1" ]; then
  mkdir -p "${PERSISTENCE_PATH}"
  chown -R searx:searx "${PERSISTENCE_PATH}"
fi

# Install chosen SearxNG version (pip). Installing at runtime keeps image size smaller and allows version switching.
echo "[searxng-addon] Installing searxng ${SEARXNG_VERSION}..."
if [ "${SEARXNG_VERSION}" = "latest" ]; then
  pip3 install --no-cache-dir searxng
else
  pip3 install --no-cache-dir "searxng==${SEARXNG_VERSION}"
fi

# Prepare config directory inside persistence (fall back to /etc/searxng if persistence disabled)
if [ "${PERSISTENCE_ENABLE}" = "true" ] || [ "${PERSISTENCE_ENABLE}" = "1" ]; then
  CONFIG_DIR="${PERSISTENCE_PATH}/settings"
  mkdir -p "${CONFIG_DIR}"
  CONFIG_FILE="${CONFIG_DIR}/settings.yml"
  if [ ! -f "${CONFIG_FILE}" ]; then
    echo "[searxng-addon] Copying default settings.yml to persistence"
    cp /etc/searxng/settings.yml "${CONFIG_FILE}"
    chown searx:searx "${CONFIG_FILE}"
  fi
else
  CONFIG_FILE="/etc/searxng/settings.yml"
fi

# Ensure SECRET_KEY set
if [ -z "${SECRET_KEY}" ] || [ "${SECRET_KEY}" = "null" ]; then
  # generate a random secret key if not supplied and persist it if persistence enabled
  GENERATED_KEY=$(python3 - <<'PY'
import secrets, sys
print(secrets.token_hex(32))
PY
)
  echo "[searxng-addon] Generated secret_key"
  if [ "${PERSISTENCE_ENABLE}" = "true" ] || [ "${PERSISTENCE_ENABLE}" = "1" ]; then
    yq eval ".security.secret_key = \"${GENERATED_KEY}\"" -i "${CONFIG_FILE}"
    chown searx:searx "${CONFIG_FILE}"
  else
    # inject into env for runtime only
    export SEARXNG_SECRET_KEY="${GENERATED_KEY}"
  fi
fi

# Apply base_url if provided (modify config file)
if [ -n "${BASE_URL}" ] && [ "${BASE_URL}" != "null" ]; then
  echo "[searxng-addon] Applying base_url=${BASE_URL}"
  yq eval ".server.base_url = \"${BASE_URL}\"" -i "${CONFIG_FILE}" || true
fi

# Apply listen/port/bind_address
echo "[searxng-addon] Configuring server listen ${BIND_ADDRESS}:${LISTEN_PORT}"
yq eval ".server.listen = \"${BIND_ADDRESS}\"" -i "${CONFIG_FILE}" || true
yq eval ".server.port = ${LISTEN_PORT}" -i "${CONFIG_FILE}" || true

# Ensure DB path exists (SearxNG uses var dir locations)
VAR_DIR="${PERSISTENCE_PATH}/var"
mkdir -p "${VAR_DIR}"
chown -R searx:searx "${VAR_DIR}"

# Final: run searxng as non-root user
echo "[searxng-addon] Starting searxng-run..."
exec su-exec searx searx-run --config "${CONFIG_FILE}" --host "${BIND_ADDRESS}" --port "${LISTEN_PORT}"
