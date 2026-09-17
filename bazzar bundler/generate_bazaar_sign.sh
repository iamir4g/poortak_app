#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

BUNDLE_SIGNER_JAR="${SCRIPT_DIR}/bundlesigner-0.1.13.jar"
KEY_PROPERTIES="${PROJECT_ROOT}/android/key.properties"
KEYSTORE="${PROJECT_ROOT}/android/upload-keystore.jks"
AAB="${1:-${PROJECT_ROOT}/build/app/outputs/bundle/bazaarRelease/app-bazaar-release.aab}"
OUTPUT_DIR="${SCRIPT_DIR}/output"

if [[ ! -f "${BUNDLE_SIGNER_JAR}" ]]; then
  echo "Bundle Signer not found: ${BUNDLE_SIGNER_JAR}"
  exit 1
fi

if [[ ! -f "${KEY_PROPERTIES}" ]]; then
  echo "Missing ${KEY_PROPERTIES}"
  echo "Create it from android/key.properties.example or run android/create_release_keystore.sh"
  exit 1
fi

if [[ ! -f "${KEYSTORE}" ]]; then
  echo "Missing keystore: ${KEYSTORE}"
  exit 1
fi

if [[ ! -f "${AAB}" ]]; then
  echo "AAB not found: ${AAB}"
  echo "Build it first: flutter build appbundle --release --flavor bazaar"
  exit 1
fi

STORE_PASSWORD=""
KEY_PASSWORD=""
KEY_ALIAS="upload"

while IFS='=' read -r key value; do
  [[ -z "${key}" || "${key}" == \#* ]] && continue
  case "${key}" in
    storePassword) STORE_PASSWORD="${value}" ;;
    keyPassword) KEY_PASSWORD="${value}" ;;
    keyAlias) KEY_ALIAS="${value}" ;;
  esac
done < "${KEY_PROPERTIES}"

if [[ -z "${STORE_PASSWORD}" || -z "${KEY_PASSWORD}" ]]; then
  echo "storePassword and keyPassword are required in ${KEY_PROPERTIES}"
  exit 1
fi

if command -v java >/dev/null 2>&1; then
  JAVA_BIN="java"
elif [[ -x "/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/java" ]]; then
  JAVA_BIN="/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/java"
else
  echo "Java not found. Install JRE 8+ or Android Studio."
  exit 1
fi

mkdir -p "${OUTPUT_DIR}"

echo "Generating Bazaar sign file..."
echo "  AAB:    ${AAB}"
echo "  Output: ${OUTPUT_DIR}"
echo "  Keystore alias: ${KEY_ALIAS}"
echo

"${JAVA_BIN}" -jar "${BUNDLE_SIGNER_JAR}" genbin \
  --bundle "${AAB}" \
  --bin "${OUTPUT_DIR}" \
  --v2-signing-enabled true \
  --v3-signing-enabled false \
  --ks "${KEYSTORE}" \
  --ks-key-alias "${KEY_ALIAS}" \
  --ks-pass "pass:${STORE_PASSWORD}" \
  --key-pass "pass:${KEY_PASSWORD}" \
  -v

echo
echo "Done. Upload the generated .bin file from:"
echo "  ${OUTPUT_DIR}"
