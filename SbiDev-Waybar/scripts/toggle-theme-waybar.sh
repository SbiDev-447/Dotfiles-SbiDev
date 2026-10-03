#!/bin/bash
set -e

# El symlink es RELATIVO a proposito: style.css esta versionado en git, asi que
# una ruta absoluta /home/<usuario>/... queda rota al clonar en otra maquina.
# Waybar carga style.css como entry, y sus "@import ./styles/colors-*.css" se
# resuelven contra el directorio del entry, no contra el destino del symlink,
# por lo que un link relativo funciona igual que uno absoluto.
WAYBAR_DIR="$HOME/.config/waybar"
LINK_FILE="$WAYBAR_DIR/style.css"
DARK_TARGET="styles/dark.css"
LIGHT_TARGET="styles/light.css"
DARK_FILE="$WAYBAR_DIR/${DARK_TARGET}"
LIGHT_FILE="$WAYBAR_DIR/${LIGHT_TARGET}"

# Verifica que los targets existan
if [ ! -f "$DARK_FILE" ] || [ ! -f "$LIGHT_FILE" ]; then
  echo "Error: faltan dark.css o light.css en ~/.config/waybar/styles/" >&2
  exit 1
fi

# Si style.css no es symlink, conviertelo (respalda primero)
if [ ! -L "$LINK_FILE" ]; then
  [ -f "$LINK_FILE" ] && mv "$LINK_FILE" "$LINK_FILE.bak"
  ln -s "$DARK_TARGET" "$LINK_FILE"
  echo "Convertido style.css a symlink relativo -> ${DARK_TARGET}"
else
  CURRENT=$(readlink -f "$LINK_FILE")
  if [ "$CURRENT" = "$(readlink -f "$DARK_FILE")" ]; then
    ln -sfn "$LIGHT_TARGET" "$LINK_FILE"
    echo "Cambiado a LIGHT"
  else
    ln -sfn "$DARK_TARGET" "$LINK_FILE"
    echo "Cambiado a DARK"
  fi
fi

pkill -SIGUSR2 waybar || true