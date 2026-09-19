#!/usr/bin/env bash
# Waybar custom module — volumen del sink por defecto.
# Linea 1: icono en la barra. Lineas restantes: tooltip con barra de bloques.

vol="$(pactl get-sink-volume @DEFAULT_SINK@ | sed -n 's/.*[[:space:]]\([0-9]*\)%.*/\1/p' | head -n1)"
[ -z "$vol" ] && vol=0
muted="$(pactl get-sink-mute @DEFAULT_SINK@ | sed -n 's/^Mute: //p')"

if [ "$muted" = "yes" ]; then
  icon="󰝟 "
elif [ "$vol" -ge 66 ]; then
  icon="󰕾 "
elif [ "$vol" -ge 33 ]; then
  icon="󰖀 "
else
  icon="󰕿 "
fi

filled=$(( (vol + 5) / 10 ))
bar=""
i=0
while [ "$i" -lt 10 ]; do
  if [ "$i" -lt "$filled" ]; then bar+="▰"; else bar+="▱"; fi
  i=$(( i + 1 ))
done

printf '%s\n%s %s%%\n' "$icon" "$bar" "$vol"