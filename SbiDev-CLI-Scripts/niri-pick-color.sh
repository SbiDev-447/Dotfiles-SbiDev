#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 SbiDev
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

# Captura un color de la pantalla con `niri msg pick-color` y lo imprime por
# stdout en el formato elegido, copiándolo además al portapapeles con wl-copy.
#
# niri devuelve el color como JSON con floats de 0.0 a 1.0:
#   {"rgb":[0.5019607843137255,0.2,1.0]}
# y `null` si se cancela la captura con Escape.

set -uo pipefail

uso() {
  cat <<'EOF'
Uso: niri-pick-color.sh [FORMATO]

Captura un color de la pantalla con 'niri msg pick-color' (clic para elegir,
Escape para cancelar), lo imprime por stdout y lo copia al portapapeles.

Formatos:
  rgb         rgb(r, g, b)
  hex         #rrggbb
  -h, --help  Muestra esta ayuda

Sin argumentos pregunta el formato por consola.
EOF
}

error() {
  echo "niri-pick-color: $*" >&2
  exit 1
}

# El formato pedido por argumento; vacío significa preguntar por consola.
if [[ $# -gt 1 ]]; then
  echo "niri-pick-color: demasiados argumentos" >&2
  uso >&2
  exit 2
fi

formato="${1:-}"

case "$formato" in
  -h | --help)
    uso
    exit 0
    ;;
  r) formato=rgb ;;
  h) formato=hex ;;
  rgb | hex) ;;
  '') ;;
  *)
    echo "niri-pick-color: formato no válido: $formato" >&2
    uso >&2
    exit 2
    ;;
esac

command -v niri >/dev/null 2>&1 || error "no se encontró 'niri' en PATH"
command -v wl-copy >/dev/null 2>&1 || error "no se encontró 'wl-copy' en PATH (paquete wl-clipboard)"

# Captura. niri msg devuelve un único objeto JSON (o null si se cancela).
json=$(niri msg --json pick-color) ||
  error "falló 'niri msg --json pick-color' (¿está niri en ejecución?)"

[[ -n "$json" ]] || error "niri no devolvió ningún dato"

if [[ "$json" == "null" ]]; then
  error "no se eligió ningún color"
fi

rgb_re='^[[:space:]]*\{[[:space:]]*"rgb"[[:space:]]*:[[:space:]]*\[[[:space:]]*([^],[:space:]]+)[[:space:]]*,[[:space:]]*([^],[:space:]]+)[[:space:]]*,[[:space:]]*([^],[:space:]]+)[[:space:]]*\][[:space:]]*\}[[:space:]]*$'
if [[ ! "$json" =~ $rgb_re ]]; then
  error "respuesta inesperada de niri: $json"
fi

num_re='^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)([eE][+-]?[0-9]+)?$'
r=${BASH_REMATCH[1]}
g=${BASH_REMATCH[2]}
b=${BASH_REMATCH[3]}
for canal in "$r" "$g" "$b"; do
  [[ "$canal" =~ $num_re ]] || error "valor de color no numérico: $canal"
done

# Convierte 0.0-1.0 a 0-255 redondeando, igual que hace niri al imprimir.
read -r r8 g8 b8 < <(awk -v r="$r" -v g="$g" -v b="$b" '
  function to8(v) { if (v < 0) v = 0; if (v > 1) v = 1; return int(v * 255 + 0.5) }
  BEGIN { printf "%d %d %d\n", to8(r), to8(g), to8(b) }
') || error "no se pudo convertir el color"

[[ -n "${r8:-}" && -n "${g8:-}" && -n "${b8:-}" ]] || error "no se pudo convertir el color"

# Pregunta el formato cuando no se pasó por argumento (después de capturar el color).
if [[ -z "$formato" ]]; then
  while :; do
    {
      echo "Formato de salida:"
      echo "  1) RGB  rgb(r, g, b)"
      echo "  2) HEX  #rrggbb"
      printf '> '
    } >&2

    IFS= read -r opcion || error "entrada cancelada"

    case "${opcion,,}" in
      1 | rgb) formato=rgb; break ;;
      2 | hex) formato=hex; break ;;
      *) echo "Opción no válida: escribe 1 (RGB) o 2 (HEX)." >&2 ;;
    esac
  done
fi

case "$formato" in
  rgb) salida=$(printf 'rgb(%d, %d, %d)' "$r8" "$g8" "$b8") ;;
  hex) salida=$(printf '#%02x%02x%02x' "$r8" "$g8" "$b8") ;;
  *) error "formato interno no válido: $formato" ;;
esac

# El valor va a stdout (capturable) y la confirmación de copia a stderr.
printf '%s\n' "$salida"

if printf '%s' "$salida" | wl-copy; then
  echo "Copiado al portapapeles: $salida" >&2
else
  error "no se pudo copiar al portapapeles con wl-copy"
fi
