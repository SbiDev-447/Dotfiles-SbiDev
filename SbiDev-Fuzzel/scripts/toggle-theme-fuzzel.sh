#!/usr/bin/env bash

set -euo pipefail

CONFIG="$HOME/.config/fuzzel/fuzzel.ini"

# Verifica que el archivo y los marcadores existan
if [[ ! -f "$CONFIG" ]]; then
  echo "Error: no existe $CONFIG" >&2
  exit 1
fi

if ! grep -q "^# BEGIN_FUZZEL_THEME" "$CONFIG"; then
  echo "Error: no se encontró '# BEGIN_FUZZEL_THEME' en $CONFIG" >&2
  exit 1
fi

# Detecta qué tema está activo actualmente
# Si la línea 'include=~/.config/fuzzel/themes/Owl47-Dark.ini' NO está comentada -> tema oscuro activo
#
# Cada sustitución solo comenta o descomenta su propia línea y conserva el
# nombre del archivo: así ninguna puede pisar la salida de la otra.
if sed -n '/^# BEGIN_FUZZEL_THEME/,/^# END_FUZZEL_THEME/p' "$CONFIG" |
  grep -q "^include=~/.config/fuzzel/themes/Owl47-Dark\.ini$"; then
  # Está en modo oscuro -> cambiar a claro
  sed -i \
    -e '/^# BEGIN_FUZZEL_THEME/,/^# END_FUZZEL_THEME/{
            s|^include=~/.config/fuzzel/themes/Owl47-Dark\.ini$|#include=~/.config/fuzzel/themes/Owl47-Dark.ini|
            s|^#include=~/.config/fuzzel/themes/Turtle47-Light\.ini$|include=~/.config/fuzzel/themes/Turtle47-Light.ini|
        }' "$CONFIG"
  echo "Tema cambiado a: LIGHT"
else
  # Está en modo claro -> cambiar a oscuro
  sed -i \
    -e '/^# BEGIN_FUZZEL_THEME/,/^# END_FUZZEL_THEME/{
            s|^#include=~/.config/fuzzel/themes/Owl47-Dark\.ini$|include=~/.config/fuzzel/themes/Owl47-Dark.ini|
            s|^include=~/.config/fuzzel/themes/Turtle47-Light\.ini$|#include=~/.config/fuzzel/themes/Turtle47-Light.ini|
        }' "$CONFIG"
  echo "Tema cambiado a: DARK"
fi
