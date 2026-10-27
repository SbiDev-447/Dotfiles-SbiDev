#!/bin/bash
set -e

# Alterna el tema GTK del sistema entre TurtleGlasses-GTK y TurtleGlasses-GTK-Dark.
#
# Los dos temas viven en ~/.local/share/themes/ y NO estan versionados en este
# repo, asi que el script no toca ningun fichero: solo escribe la clave de
# gsettings.
#
# A diferencia de los toggle de Kitty, Alacritty o Fuzzel, aqui no hay fichero
# marcador que inspeccionar: el estado actual se lee de gsettings, que es la
# unica fuente de verdad. Asi sigue funcionando aunque cambies el tema a mano
# con GNOME Tweaks u otra herramienta.

DARK_THEME="TurtleGlasses-GTK-Dark"
LIGHT_THEME="TurtleGlasses-GTK"
SCHEMA="org.gnome.desktop.interface"
KEY="gtk-theme"

# GTK busca los temas en estos tres directorios.
theme_installed() {
  local name="$1" dir
  for dir in "$HOME/.local/share/themes" "$HOME/.themes" /usr/share/themes; do
    [ -d "$dir/$name" ] && return 0
  done
  return 1
}

# Sin D-Bus (por ejemplo desde una TTY) gsettings falla; con set -e el script
# moriria sin explicar el motivo, asi que se comprueba a mano.
if ! current=$(gsettings get "$SCHEMA" "$KEY" 2>/dev/null); then
  echo "Error: no se pudo leer $SCHEMA $KEY (¿sesion sin D-Bus?)" >&2
  exit 1
fi
current="${current//\'/}"

if [ "$current" = "$DARK_THEME" ]; then
  next="$LIGHT_THEME"
  label="LIGHT"
else
  next="$DARK_THEME"
  label="DARK"
fi

if ! theme_installed "$next"; then
  echo "Error: el tema '$next' no esta instalado en ~/.local/share/themes/, ~/.themes/ ni /usr/share/themes/" >&2
  exit 1
fi

if ! gsettings set "$SCHEMA" "$KEY" "$next"; then
  echo "Error: no se pudo escribir $SCHEMA $KEY (¿sesion sin D-Bus?)" >&2
  exit 1
fi

echo "GTK: $label ($next)"
