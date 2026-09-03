#!/bin/bash

if pgrep -x swayidle >/dev/null; then
  pkill -x swayidle
  notify-send 'Idle' 'Desactivado (modo presentación)'
else
  ~/.local/bin/niri-idle.sh &
  notify-send 'Idle' 'Activado (ahorro OLED)'
fi
