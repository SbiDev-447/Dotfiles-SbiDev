#!/usr/bin/env bash
# Waybar custom module — volumen del sink por defecto (event-driven, sin polling).
# Linea 1 de cada salida: icono y porcentaje, directo en la barra.
# Al enmudecer muestra solo el icono: un sink muteado sigue reportando su volumen.
#
# Este script es un daemon: imprime el estado actual una vez y se queda vivo en
# `pactl subscribe`. Cada linea de stdout es una actualizacion del modulo
# (waybar elige continuousWorker cuando no hay `interval` ni `signal`).
# Si PipeWire se reinicia y el subscribe muere, waybar lo revive a los 5 s
# via `restart-interval`.
#
# Filtro: solo 'change' del sink (volumen/mute). Los eventos de cliente
# (new/remove) los genera la propia consulta y NO deben reimprimir, porque
# crearian un bucle infinito de consultas.

print_volume() {
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
}

print_volume

pactl subscribe | while read -r event; do
  case "$event" in
    *"Event 'change' on sink #"*|*"Event 'change' on server"*) print_volume ;;
  esac
done
