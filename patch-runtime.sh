#!/usr/bin/env bash
set -euo pipefail

RUNTIME_HOME=/opt/runtime
GLIBC_HOME=${RUNTIME_HOME}/glibc
CONDA_ENV_HOME=${RUNTIME_HOME}/envs/py312-spark411

find_loader() {
  local x
  for x in \
    "${GLIBC_HOME}/lib/ld-linux-x86-64.so.2" \
    "${GLIBC_HOME}/lib64/ld-linux-x86-64.so.2"; do
    if [[ -x "$x" ]]; then
      echo "$x"
      return 0
    fi
  done
  return 1
}

LOADER="$(find_loader)"
if [[ -z "${LOADER}" ]]; then
  echo "FATAL: glibc loader not found"
  exit 1
fi

COMMON_RPATH="${GLIBC_HOME}/lib:${GLIBC_HOME}/lib64:${CONDA_ENV_HOME}/lib"

patch_one() {
  local f="$1"
  if [[ -f "$f" ]]; then
    echo "patching: $f"
    patchelf --set-rpath "${COMMON_RPATH}" "$f" || true
  fi
}

patch_pybin() {
  local f="$1"
  if [[ -f "$f" ]]; then
    echo "patching python binary: $f"
    patchelf --set-interpreter "${LOADER}" "$f" || true
    patchelf --set-rpath "${COMMON_RPATH}" "$f" || true
  fi
}

patch_pybin "${CONDA_ENV_HOME}/bin/python"
patch_pybin "${CONDA_ENV_HOME}/bin/python3"
patch_pybin "${CONDA_ENV_HOME}/bin/python3.12"

find "${CONDA_ENV_HOME}/lib" -maxdepth 3 -type f \
  \( \
    -name "libpython3.12*.so*" -o \
    -name "libarrow*.so*" -o \
    -name "libparquet*.so*" -o \
    -name "libprotobuf*.so*" -o \
    -name "libstdc++.so*" \
  \) \
  | while read -r sofile; do
      patch_one "$sofile"
    done

SITE_PKGS="${CONDA_ENV_HOME}/lib/python3.12/site-packages"

if [[ -d "${SITE_PKGS}/pyarrow" ]]; then
  find "${SITE_PKGS}/pyarrow" -type f -name "*.so" | while read -r sofile; do
    patch_one "$sofile"
  done
fi

if [[ -d "${SITE_PKGS}/numpy" ]]; then
  find "${SITE_PKGS}/numpy" -type f -name "*.so" | while read -r sofile; do
    patch_one "$sofile"
  done
fi

if [[ -d "${SITE_PKGS}/pandas" ]]; then
  find "${SITE_PKGS}/pandas" -type f -name "*.so" | while read -r sofile; do
    patch_one "$sofile"
  done
fi

JAVA_BIN="${RUNTIME_HOME}/java/bin/java"
if [[ -f "${JAVA_BIN}" ]]; then
  echo "patching java binary rpath: ${JAVA_BIN}"
  patchelf --set-rpath "${COMMON_RPATH}:${RUNTIME_HOME}/java/lib:${RUNTIME_HOME}/java/lib/server" "${JAVA_BIN}" || true
fi

echo "Patch done."
