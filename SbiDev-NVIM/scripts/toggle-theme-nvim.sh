#!/usr/bin/env bash

set -euo pipefail

CONFIG="$HOME/.config/nvim/lua/plugins/colorscheme.lua"

# Rango del bloque conmutado. Los marcadores van indentados dentro de la funcion
# Lua, asi que NO se pueden anclar a la columna 0 como en kitty.conf.
RANGE='/^[[:space:]]*-- BEGIN_NVIM_THEME/,/^[[:space:]]*-- END_NVIM_THEME/'

# Verifica que el archivo y los marcadores existan
if [[ ! -f "$CONFIG" ]]; then
  echo "Error: no existe $CONFIG" >&2
  exit 1
fi

if ! grep -q "^[[:space:]]*-- BEGIN_NVIM_THEME$" "$CONFIG"; then
  echo "Error: no se encontró '-- BEGIN_NVIM_THEME' en $CONFIG" >&2
  exit 1
fi

# Detecta que tema esta activo.
# Si la linea 'vim.cmd.colorscheme("gruvbox")' NO esta comentada -> tema claro activo.
# La detccion es obligatoria: un sed de intercambio incondicional es un trinquete
# de un solo sentido, porque en la segunda pasada ya no encuentra la linea activa
# que comentar y se queda congelado en el segundo estado.
if sed -n "$RANGE"p "$CONFIG" |
  grep -q '^[[:space:]]*vim\.cmd\.colorscheme("gruvbox")$'; then
  # Está en modo claro -> cambiar a oscuro
  sed -i \
    -e "$RANGE{
            s|^\([[:space:]]*\)vim\.o\.background = \"light\"|\1-- vim.o.background = \"light\"|
            s|^\([[:space:]]*\)vim\.cmd\.colorscheme(\"gruvbox\")|\1-- vim.cmd.colorscheme(\"gruvbox\")|
            s|^\([[:space:]]*\)-- vim\.o\.background = \"dark\"|\1vim.o.background = \"dark\"|
            s|^\([[:space:]]*\)-- vim\.cmd\.colorscheme(\"gentleman-kanagawa-blur\")|\1vim.cmd.colorscheme(\"gentleman-kanagawa-blur\")|
        }" "$CONFIG"
  TARGET="DARK"
else
  # Está en modo oscuro -> cambiar a claro
  sed -i \
    -e "$RANGE{
            s|^\([[:space:]]*\)vim\.o\.background = \"dark\"|\1-- vim.o.background = \"dark\"|
            s|^\([[:space:]]*\)vim\.cmd\.colorscheme(\"gentleman-kanagawa-blur\")|\1-- vim.cmd.colorscheme(\"gentleman-kanagawa-blur\")|
            s|^\([[:space:]]*\)-- vim\.o\.background = \"light\"|\1vim.o.background = \"light\"|
            s|^\([[:space:]]*\)-- vim\.cmd\.colorscheme(\"gruvbox\")|\1vim.cmd.colorscheme(\"gruvbox\")|
        }" "$CONFIG"
  TARGET="LIGHT"
fi

# Post-comprobacion: dentro del bloque debe quedar exactamente una variante activa.
# Sin esto, un write-back defectuoso dejaria el archivo con cero o dos lineas
# activas y el fallo no se veria hasta abrir Neovim.
ACTIVE=$(sed -n "$RANGE"p "$CONFIG" | grep -c '^[[:space:]]*vim\.cmd\.colorscheme(' || true)
if [[ "$ACTIVE" -ne 1 ]]; then
  echo "Error: el bloque de tema quedo con $ACTIVE variantes activas (se esperaba 1) en $CONFIG" >&2
  exit 1
fi

echo "Tema cambiado a: $TARGET"

# No recarga nada: Neovim lee su configuracion en el arranque, asi que el cambio
# se aplica en la proxima instancia. A diferencia de Kitty y Waybar no hay senal
# que enviar.