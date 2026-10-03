#!/bin/bash
set -e

LINK_FILE="$HOME/.config/waybar/style.css"
DARK_TARGET="$HOME/.config/waybar/styles/dark.css"
LIGHT_TARGET="$HOME/.config/waybar/styles/light.css"

# Verifica que los targets existan
if [ ! -f "$DARK_TARGET" ] || [ ! -f "$LIGHT_TARGET" ]; then
  echo "Error: faltan dark.css o light.css en ~/.config/waybar/styles/" >&2
  exit 1
fi

# Si style.css no es symlink, conviértelo (respalda primero)
if [ ! -L "$LINK_FILE" ]; then
  [ -f "$LINK_FILE" ] && mv "$LINK_FILE" "$LINK_FILE.bak"
  ln -s "$DARK_TARGET" "$LINK_FILE"
  echo "Convertido style.css a symlink -> dark.css"
else
  CURRENT=$(readlink -f "$LINK_FILE")
  if [ "$CURRENT" = "$(readlink -f "$DARK_TARGET")" ]; then
    ln -sfn "$LIGHT_TARGET" "$LINK_FILE"
    echo "Cambiado a LIGHT"
  else
    ln -sfn "$DARK_TARGET" "$LINK_FILE"
    echo "Cambiado a DARK"
  fi
fi

pkill -SIGUSR2 waybar || true
