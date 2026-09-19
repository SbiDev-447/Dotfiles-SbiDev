#!/usr/bin/env bash
# Waybar custom module — brillo (selecciona el dispositivo por clase backlight).
# Linea 1: icono en la barra. Lineas restantes: tooltip con barra de bloques.

pct="$(brightnessctl --class=backlight -m 2>/dev/null | head -n1 | awk -F, '{print int($4)}')"
[ -z "$pct" ] && pct=0

icons=("󰃚 " "󰃛 " "󰃜 " "󰃟 " "󰃞 " "󰃝 " "󰃠 ")
idx=$(( pct * 6 / 100 ))
[ "$idx" -gt 6 ] && idx=6
icon="${icons[$idx]}"

filled=$(( (pct + 5) / 10 ))
bar=""
i=0
while [ "$i" -lt 10 ]; do
  if [ "$i" -lt "$filled" ]; then bar+="▰"; else bar+="▱"; fi
  i=$(( i + 1 ))
done

printf '%s\n%s %s%%\n' "$icon" "$bar" "$pct"