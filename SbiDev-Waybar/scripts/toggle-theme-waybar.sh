#!/bin/bash
set -e

# Alterna el tema de Waybar reescribiendo in situ la línea @import de style.css.
#
# Por qué así:
# - config-common.jsonc tiene "reload_style_on_change": true, y Waybar vigila
#   style.css. Al reescribirlo en el mismo inodo (truncar + escribir) recarga
#   SOLO el CSS: no recrea la layer-surface ni reinicializa los módulos.
# - No usar `pkill -SIGUSR2 waybar`: en Waybar SIGUSR2 significa RELOAD completo
#   (Client::reset + reentrada en main), destruye y recrea la barra entera.
# - No usar `sed -i`: reemplaza el fichero por rename y Waybar no recibe el
#   evento CHANGES_DONE_HINT que usa para recargar. `printf >` sí.
#
# Los @import de styles/dark.css y styles/light.css apuntan a ./colors-*.css
# (relativo a styles/): GTK resuelve los imports anidados contra el directorio
# del fichero que los contiene. No cambiar a ./styles/colors-*.css.

WAYBAR_DIR="$HOME/.config/waybar"
STYLE_FILE="$WAYBAR_DIR/style.css"
DARK_TARGET="./styles/dark.css"
LIGHT_TARGET="./styles/light.css"
DARK_FILE="$WAYBAR_DIR/styles/dark.css"
LIGHT_FILE="$WAYBAR_DIR/styles/light.css"

if [ ! -f "$DARK_FILE" ] || [ ! -f "$LIGHT_FILE" ]; then
  echo "Error: faltan dark.css o light.css en ~/.config/waybar/styles/" >&2
  exit 1
fi

# Migración desde las instalaciones antiguas: style.css era un symlink a
# styles/{dark,light}.css. Se convierte en fichero real con la misma selección.
if [ -L "$STYLE_FILE" ]; then
  CURRENT_TARGET=$(readlink "$STYLE_FILE")
  rm -f "$STYLE_FILE"
  case "$CURRENT_TARGET" in
    *dark.css) printf '@import "%s";\n' "$DARK_TARGET" > "$STYLE_FILE" ;;
    *)         printf '@import "%s";\n' "$LIGHT_TARGET" > "$STYLE_FILE" ;;
  esac
fi

if [ ! -f "$STYLE_FILE" ]; then
  echo "Error: falta $STYLE_FILE" >&2
  exit 1
fi

if grep -qxF "@import \"$LIGHT_TARGET\";" "$STYLE_FILE"; then
  NEXT_TARGET="$DARK_TARGET"
  LABEL="DARK"
elif grep -qxF "@import \"$DARK_TARGET\";" "$STYLE_FILE"; then
  NEXT_TARGET="$LIGHT_TARGET"
  LABEL="LIGHT"
else
  echo "Error: no encuentro la línea '@import' de tema en $STYLE_FILE" >&2
  exit 1
fi

printf '@import "%s";\n' "$NEXT_TARGET" > "$STYLE_FILE"
echo "Waybar: $LABEL"
