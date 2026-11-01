#!/bin/bash
set -e

# Alterna tema GTK + set de iconos entre modo claro y oscuro.
# Compatible con Xfce (con sincronización gsettings) y Niri (Wayland lee gsettings).
# Solo escribe claves de gsettings; no toca ningún fichero de tema.

DARK_THEME="TurtleGlasses-GTK-Dark"
LIGHT_THEME="TurtleGlasses-GTK"
DARK_ICONS="Gruvbox-Plus-Dark"
LIGHT_ICONS="Gruvbox-Plus-Light"

SCHEMA="org.gnome.desktop.interface"
THEME_KEY="gtk-theme"
ICONS_KEY="icon-theme"

theme_installed() {
  local name="$1" dir
  for dir in "$HOME/.local/share/themes" "$HOME/.themes" /usr/share/themes; do
    [ -d "$dir/$name" ] && return 0
  done
  return 1
}

icons_installed() {
  local name="$1" dir
  for dir in "$HOME/.local/share/icons" "$HOME/.icons" /usr/share/icons; do
    [ -d "$dir/$name" ] && return 0
  done
  return 1
}

# Sin D-Bus (por ejemplo desde una TTY) gsettings falla; se comprueba a mano.
if ! current=$(gsettings get "$SCHEMA" "$THEME_KEY" 2>/dev/null); then
  echo "Error: no se pudo leer $SCHEMA $THEME_KEY (¿sesión sin D-Bus?)" >&2
  exit 1
fi
current="${current//\'/}"

if [ "$current" = "$DARK_THEME" ]; then
  next_theme="$LIGHT_THEME"
  next_icons="$LIGHT_ICONS"
  label="LIGHT"
else
  next_theme="$DARK_THEME"
  next_icons="$DARK_ICONS"
  label="DARK"
fi

if ! theme_installed "$next_theme"; then
  echo "Error: el tema '$next_theme' no está instalado." >&2
  exit 1
fi

if ! icons_installed "$next_icons"; then
  echo "Error: el set de iconos '$next_icons' no está instalado." >&2
  exit 1
fi

if ! gsettings set "$SCHEMA" "$THEME_KEY" "$next_theme"; then
  echo "Error: no se pudo escribir $SCHEMA $THEME_KEY." >&2
  exit 1
fi

if ! gsettings set "$SCHEMA" "$ICONS_KEY" "$next_icons"; then
  echo "Error: no se pudo escribir $SCHEMA $ICONS_KEY." >&2
  exit 1
fi

echo "GTK: $label ($next_theme) + iconos ($next_icons)"
