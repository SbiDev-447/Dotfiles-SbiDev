#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 SbiDev
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

# Avisos de batería para Waybar (ver battery.events en SbiDev-Waybar/waybar/modules.json).
# Uso: low-battery-notify.sh {warning|critical|danger|empty|full} [nivel]
#   warning -> 30%   critical -> 20%   danger -> 10%   empty -> 5%
#   full <nivel> -> Waybar alcanzó ese porcentaje; solo avisa si es el techo de carga.
# Waybar crea un módulo de batería por cada salida, así que un mismo evento llega
# varias veces seguidas: la marca de tiempo evita notificaciones duplicadas.

set -u

state_dir="${XDG_RUNTIME_DIR:-/tmp}/low-battery-notify"
mkdir -p "$state_dir" 2>/dev/null || state_dir="/tmp/low-battery-notify.$$"
mkdir -p "$state_dir" 2>/dev/null || exit 0

# notified <clave> <ventana-segundos>: evita repetir el aviso dentro de la ventana.
notified() {
  local stamp="$state_dir/$1" now last
  now=$(date +%s)
  last=$(stat -c %Y "$stamp" 2>/dev/null || echo 0)
  if [ "$((now - last))" -lt "$2" ]; then
    return 1
  fi
  : >"$stamp" 2>/dev/null || true
  return 0
}

case "${1:-}" in
warning)
  notified 30 300 &&
    notify-send -u normal "🔋 Batería 30%" "Considera conectar el cargador."
  ;;
critical)
  notified 20 300 &&
    notify-send -u critical "🔋 Batería 20%" "Por favor, conecta el cargador."
  ;;
danger)
  notified 10 300 &&
    notify-send -u critical "⚠️ Batería 10%" "¡Conecta el cargador ahora mismo!"
  ;;
empty)
  notified 5 300 &&
    notify-send -u critical "🚨 Batería 5%" "El sistema se apagará en breve."
  ;;
full)
  level=${2:-}
  [ -n "$level" ] || exit 0
  bat=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1) || exit 0
  lim=$(cat "$bat/charge_control_end_threshold" 2>/dev/null) || lim=100
  [ -n "$lim" ] || lim=100
  # Waybar calcula el porcentaje con charge_now/charge_full, que difiere en ±1 del
  # campo capacity del kernel: con techo 80 el valor oscila entre 79 y 80 y ambos
  # significan "en el techo". Toleramos 1% solo si el techo no es 100, para que un
  # techo de 100 siga exigiendo un 100 real. La clave de deduplicación es "full"
  # (no el nivel) porque esa oscilacion provocaria avisos duplicados.
  if [ "$lim" -lt 100 ]; then
    [ "$level" -lt $((lim - 1)) ] && exit 0
  else
    [ "$level" -lt "$lim" ] && exit 0
  fi
  notified full 300 || exit 0
  if [ "$lim" = "100" ]; then
    notify-send -u normal "🔌 Carga completa" "Batería al ${level}%."
  else
    notify-send -u normal "🔌 Carga completa" "Batería al ${level}% (techo ${lim}%)."
  fi
  ;;
esac

exit 0
