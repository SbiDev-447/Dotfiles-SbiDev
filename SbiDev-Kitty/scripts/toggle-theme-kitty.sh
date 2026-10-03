#!/usr/bin/env bash
# guarda como ~/.config/kitty/toggle_kitty_theme.sh

set -euo pipefail

CONFIG="$HOME/.config/kitty/kitty.conf"

# Verifica que el archivo y los marcadores existan
if [[ ! -f "$CONFIG" ]]; then
  echo "Error: no existe $CONFIG" >&2
  exit 1
fi

if ! grep -q "^# BEGIN_KITTY_THEME" "$CONFIG"; then
  echo "Error: no se encontró '# BEGIN_KITTY_THEME' en $CONFIG" >&2
  exit 1
fi

# Detecta qué tema está activo actualmente
# Si la línea 'include kitty-theme.conf' NO está comentada -> tema oscuro activo
if sed -n '/^# BEGIN_KITTY_THEME/,/^# END_KITTY_THEME/p' "$CONFIG" |
  grep -q "^include kitty-theme\.conf$"; then
  # Está en modo oscuro -> cambiar a claro
  sed -i \
    -e '/^# BEGIN_KITTY_THEME/,/^# END_KITTY_THEME/{
            s/^include kitty-theme\.conf$/#include kitty-theme.conf/
            s/^#include kitty-theme-light\.conf$/include kitty-theme-light.conf/
        }' "$CONFIG"
  echo "Tema cambiado a: LIGHT"
else
  # Está en modo claro -> cambiar a oscuro
  sed -i \
    -e '/^# BEGIN_KITTY_THEME/,/^# END_KITTY_THEME/{
            s/^#include kitty-theme\.conf$/include kitty-theme.conf/
            s/^include kitty-theme-light\.conf$/#include kitty-theme-light.conf/
        }' "$CONFIG"
  echo "Tema cambiado a: DARK"
fi

# Recarga kitty si está corriendo (opcional)
# Envía SIGUSR1 a todas las instancias de kitty para recargar la config
if pgrep -x kitty >/dev/null; then
  pkill -SIGUSR1 -x kitty || true
  echo "Kitty recargado."
fi
