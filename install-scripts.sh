#!/usr/bin/env bash
set -euo pipefail

FORCE=false
[[ "${1:-}" == "--force" ]] && FORCE=true

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${HOME}/.local/bin"

SCRIPT_DIRS=(
  "SbiDev-CLI-Scripts"
  "SbiDev-Fuzzel"
  "SbiDev-Niri"
)

if [[ ! -d "${BIN_DIR}" ]]; then
  mkdir -p "${BIN_DIR}"
  echo "Creado ${BIN_DIR}"
fi

for dir in "${SCRIPT_DIRS[@]}"; do
  src_dir="${REPO_DIR}/${dir}"
  [[ -d "${src_dir}" ]] || continue

  for script in "${src_dir}"/*; do
    [[ -f "${script}" && -x "${script}" ]] || continue

    name="$(basename "${script}")"
    link="${BIN_DIR}/${name}"
    target="$(realpath --relative-to="${BIN_DIR}" "${script}")"

    if [[ -L "${link}" ]] && [[ "$(readlink "${link}")" == "${target}" ]]; then
      echo "OK ${name} (ya enlazado)"
      continue
    fi

    if [[ -e "${link}" ]] || [[ -L "${link}" ]]; then
      if [[ "${FORCE}" == true ]]; then
        rm -rf "${link}"
        ln -s "${target}" "${link}"
        echo "FORCE ${name} (reemplazado)"
      else
        echo "SKIP ${name} (existe un archivo en ${link})"
      fi
      continue
    fi

    ln -s "${target}" "${link}"
    echo "LINK ${name}"
  done
done
