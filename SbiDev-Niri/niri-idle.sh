#!/bin/bash
# Cadena de inactividad compartida por Niri y Sway.
#
# Cada compositor conserva SU política, a propósito:
#   - Niri: nunca bloquea por inactividad (evita interrumpir vídeo).
#   - Sway: bloquea a los 5 minutos.
#
# Los handlers de swayidle se ejecutan con `sh -c`, así que no pueden ver
# funciones de este script: MON_OFF / MON_ON se interpolan como texto y los
# expande el shell hijo.

# Apagado/encendido de monitores según el compositor activo.
MON_OFF='if [ -n "${NIRI_SOCKET:-}" ]; then niri msg action power-off-monitors; else swaymsg "output * power off"; fi'
MON_ON='if [ -n "${NIRI_SOCKET:-}" ]; then niri msg action power-on-monitors; else swaymsg "output * power on"; fi'

if [ -n "${NIRI_SOCKET:-}" ]; then
  swayidle -w \
    timeout 180 'brightnessctl -c backlight set 30%' \
    timeout 300 "brightnessctl -c backlight set 10% && $MON_OFF" \
    timeout 600 'systemctl suspend' \
    resume "$MON_ON && brightnessctl -c backlight set 50%" \
    lock "brightnessctl -c backlight set 10% && $MON_OFF" \
    unlock "$MON_ON && brightnessctl -c backlight set 50%" \
    before-sleep "$MON_OFF"
else
  swayidle -w \
    timeout 300 'swaylock -f -c 000000' \
    timeout 600 "$MON_OFF" resume "$MON_ON" \
    before-sleep 'swaylock -f -c 000000'
fi
