#!/usr/bin/env bash

set -euo pipefail

CONFIG="$HOME/.config/alacritty/alacritty.toml"

# Verifica que el archivo y los marcadores existan
if [[ ! -f "$CONFIG" ]]; then
  echo "Error: no existe $CONFIG" >&2
  exit 1
fi

if ! grep -q "^# BEGIN_ALACRITTY_THEME" "$CONFIG"; then
  echo "Error: no se encontró '# BEGIN_ALACRITTY_THEME' en $CONFIG" >&2
  exit 1
fi

# Detecta qué tema está activo actualmente
# Si la línea 'general.import = ["alacritty-theme.toml"]' NO está comentada -> tema oscuro activo
#
# Cada sustitución solo comenta o descomenta su propia línea y conserva el
# nombre del archivo: así ninguna puede pisar la salida de la otra.
# El prefijo 'general.' se reescribe siempre; si se perdiera, el import
# desaparecería del config y el toggle quedaría congelado.
if sed -n '/^# BEGIN_ALACRITTY_THEME/,/^# END_ALACRITTY_THEME/p' "$CONFIG" |
  grep -q '^general\.import = \["alacritty-theme\.toml"\]$'; then
  # Está en modo oscuro -> cambiar a claro
  sed -i \
    -e '/^# BEGIN_ALACRITTY_THEME/,/^# END_ALACRITTY_THEME/{
            s|^general\.import = \["alacritty-theme\.toml"\]$|#general.import = ["alacritty-theme.toml"]|
            s|^#general\.import = \["alacritty-theme-light\.toml"\]$|general.import = ["alacritty-theme-light.toml"]|
        }' "$CONFIG"
  echo "Tema cambiado a: LIGHT"
else
  # Está en modo claro -> cambiar a oscuro
  sed -i \
    -e '/^# BEGIN_ALACRITTY_THEME/,/^# END_ALACRITTY_THEME/{
            s|^general\.import = \["alacritty-theme-light\.toml"\]$|#general.import = ["alacritty-theme-light.toml"]|
            s|^#general\.import = \["alacritty-theme\.toml"\]$|general.import = ["alacritty-theme.toml"]|
        }' "$CONFIG"
  echo "Tema cambiado a: DARK"
fi

# No se envía ninguna señal a propósito.
#
# Alacritty vigila su propia configuración (ConfigMonitor, con inotify y un
# fallback de sondeo) y se recarga solo cuando el fichero cambia, aplicando el
# cambio a todas las ventanas. Por eso no hace falta nada más aquí.
#
# El detalle importante: alacritty solo instala handler para SIGINT y SIGTERM.
# SIGHUP y SIGUSR1 no tienen handler, así que la señal aplica su acción por
# defecto sobre un proceso vivo -> lo mata. Enviar cualquiera de las dos
# cerraba todas las terminales abiertas en lugar de recargar.
