#!/bin/bash
# Cadena de inactividad compartida por Niri y Sway.
#
# Cada compositor conserva SU política, a propósito:
#   - Niri: nunca bloquea antes de los 5 min (evita interrumpir vídeo; además
#     los reproductores toman inhibidor de idle).
#   - Sway: bloquea a los 5 minutos.
#
# swayidle guarda `resume` POR timeout (en su código es cmd->resume_cmd), no
# global: por eso cada timeout que baja el brillo lleva su propio resume que
# lo devuelve. Sin eso el brillo se queda bajo al volver la actividad.
#
# Los handlers de swayidle se ejecutan con `sh -c`, así que no pueden ver
# funciones de este script: MON_OFF / MON_ON / RESTORE se interpolan como texto
# y los expande el shell hijo.

BL='brightnessctl -c backlight'
# `-s` guarda el nivel del usuario antes de bajar; `-r` lo devuelve.
DIM_SOFT="$BL -s set 30%"
DIM_HARD="$BL set 10%"
RESTORE="$BL -r"
# No relanzar swaylock si ya hay una sesión bloqueada.
LOCK='pgrep -x swaylock >/dev/null || swaylock -f'

# Apagado/encendido de monitores según el compositor activo.
MON_OFF='if [ -n "${NIRI_SOCKET:-}" ]; then niri msg action power-off-monitors; else swaymsg "output * power off"; fi'
MON_ON='if [ -n "${NIRI_SOCKET:-}" ]; then niri msg action power-on-monitors; else swaymsg "output * power on"; fi'

if [ -n "${NIRI_SOCKET:-}" ]; then
  swayidle -w \
    timeout 180 "$DIM_SOFT" resume "$RESTORE" \
    timeout 300 "$LOCK; $DIM_HARD; $MON_OFF" resume "$MON_ON; $RESTORE" \
    timeout 600 'systemctl suspend' resume "$MON_ON; $RESTORE" \
    lock "$LOCK" \
    unlock "$MON_ON" \
    before-sleep "$LOCK; $MON_OFF"
else
  swayidle -w \
    timeout 300 'swaylock -f -c 000000' \
    timeout 600 "$MON_OFF" resume "$MON_ON" \
    before-sleep 'swaylock -f -c 000000'
fi
