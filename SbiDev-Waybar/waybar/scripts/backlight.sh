#!/usr/bin/env bash
# Waybar custom module — volumen del sink por defecto.
# Linea 1: icono y porcentaje, directo en la barra.
# Al enmudecer muestra solo el icono: un sink muteado sigue reportando su volumen.

vol="$(pactl get-sink-volume @DEFAULT_SINK@ | sed -n 's/.*[[:space:]]\([0-9]*\)%.*/\1/p' | head -n1)"
[ -z "$vol" ] && vol=0
muted="$(pactl get-sink-mute @DEFAULT_SINK@ | sed -n 's/^Mute: //p')"

if [ "$muted" = "yes" ]; then
  label="󰝟"
elif [ "$vol" -ge 66 ]; then
  label="$vol% 󰕾"
elif [ "$vol" -ge 33 ]; then
  label="$vol% 󰖀"
else
  label="$vol% 󰕿"
fi

printf '%s\n' "$label"
