#!/usr/bin/env bash
set -euo pipefail

FORCE=false
[[ "${1:-}" == "--force" ]] && FORCE=true

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${HOME}/.local/bin"

SCRIPT_DIRS=(
  "SbiDev-CLI-Scripts"
  "SbiDev-Fuzzel"
  "SbiDev-Fuzzel/scripts"
  "SbiDev-Niri"
  "SbiDev-Kitty/scripts"
  "SbiDev-Alacritty/scripts"
  "SbiDev-Waybar/scripts"
  "SbiDev-NVIM/scripts"
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

# --- Bluetooth: desactivar el tray de blueman --------------------------------
# El applet (blueman-applet) lanza 'blueman-tray' a traves del plugin StatusIcon,
# pero no hay ninguna bandeja donde mostrarlo: niri no tiene tray bar y la barra
# de XFCE tampoco trae plugin systray/statusnotifier. El tray queda huerfano,
# ocupando RAM, en ambas sesiones. Desactivar StatusIcon no rompe nada:
# blueman-applet sigue activo (org.blueman.Applet) y blueman-manager sigue
# abriendo rapido. En XFCE el bluetooth sigue funcionando con normalidad.
if command -v gsettings >/dev/null 2>&1 && [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
  if gsettings get org.blueman.general plugin-list 2>/dev/null | grep -q "'!StatusIcon'"; then
    echo "OK blueman (StatusIcon ya desactivado)"
  else
    gsettings set org.blueman.general plugin-list "['!StatusIcon']"
    echo "FIX blueman: StatusIcon desactivado (sin blueman-tray)"
  fi
else
  echo "SKIP blueman (sin sesion D-Bus; StatusIcon intacto)"
fi
