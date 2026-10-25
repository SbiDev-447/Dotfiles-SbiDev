#!/bin/bash

# Alterna la cadena de inactividad en Niri y Sway (niri-idle.sh elige la
# política segun el compositor activo).

if pgrep -x swayidle >/dev/null; then
  pkill -x swayidle
  notify-send 'Idle' 'Desactivado (modo presentación)'
else
  ~/.local/bin/niri-idle.sh &
  notify-send 'Idle' 'Activado (ahorro OLED)'
fi
