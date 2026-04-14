#!/usr/bin/env bash
set -euo pipefail

RUNTIME_HOME=/opt/runtime
OUT_DIR=${1:-/tmp}
OUT_NAME=${2:-runtime-spark411-java21-py312-glibc228.tar.gz}

mkdir -p "${OUT_DIR}"

cd "${RUNTIME_HOME}/.."
tar -czf "${OUT_DIR}/${OUT_NAME}" runtime

echo "Created: ${OUT_DIR}/${OUT_NAME}"
