#!/usr/bin/env bash
# Waybar custom module — brillo (selecciona el dispositivo por clase backlight).
# Linea 1: icono y porcentaje, directo en la barra.

pct="$(brightnessctl --class=backlight -m 2>/dev/null | head -n1 | awk -F, '{print int($4)}')"
[ -z "$pct" ] && pct=0

icons=("󰃚" "󰃛" "󰃜" "󰃟" "󰃞" "󰃝" "󰃠")
idx=$(( pct * 6 / 100 ))
[ "$idx" -gt 6 ] && idx=6
icon="${icons[$idx]}"

printf '%s\n' "${pct}% ${icon}"
