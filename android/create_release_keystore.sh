#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEYSTORE_PATH="${SCRIPT_DIR}/upload-keystore.jks"
KEY_PROPERTIES_PATH="${SCRIPT_DIR}/key.properties"

if [[ -f "${KEYSTORE_PATH}" ]]; then
  echo "Keystore already exists: ${KEYSTORE_PATH}"
  echo "Delete it first if you want to create a new one."
  exit 1
fi

read -rsp "Enter keystore password: " STORE_PASSWORD
echo
read -rsp "Confirm keystore password: " STORE_PASSWORD_CONFIRM
echo

if [[ "${STORE_PASSWORD}" != "${STORE_PASSWORD_CONFIRM}" ]]; then
  echo "Passwords do not match."
  exit 1
fi

KEY_PASSWORD="${STORE_PASSWORD}"

keytool -genkeypair \
  -v \
  -keystore "${KEYSTORE_PATH}" \
  -alias upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass "${STORE_PASSWORD}" \
  -keypass "${KEY_PASSWORD}" \
  -dname "CN=Poortak, OU=Mobile, O=Poortak, L=Tehran, ST=Tehran, C=IR"

cat > "${KEY_PROPERTIES_PATH}" <<EOF
storePassword=${STORE_PASSWORD}
keyPassword=${KEY_PASSWORD}
keyAlias=upload
storeFile=upload-keystore.jks
EOF

echo
echo "Release keystore created:"
echo "  ${KEYSTORE_PATH}"
echo "  ${KEY_PROPERTIES_PATH}"
echo
echo "Keep these files and your password safe. You need the same key for all future Bazaar/Play updates."
