#!/bin/bash

# niri_wallpaper.sh - Cambia el fondo de pantalla en Niri
# Copyright (C) 2026  SbiDev-447
#
# Este programa es software libre: puedes redistribuirlo y/o modificarlo
# bajo los términos de la Licencia Pública General de GNU v3 o posterior.
#
# Este programa se distribuye SIN NINGUNA GARANTÍA; ni siquiera la garantía
# implícita de COMERCIABILIDAD o IDONEIDAD PARA UN PROPÓSITO PARTICULAR.
# Consulta la GPLv3 para más detalles en <https://www.gnu.org/licenses/>.
#
# Deberías haber recibido una copia de la GPLv3 junto con este programa.
# Si no, consulta <https://www.gnu.org/licenses/gpl-3.0.html>

# ================================================
# Cambia el fondo con swaybg en orden aleatorio,
# sin repetir ninguna imagen hasta agotar la lista.
# Busca recursivamente en subcarpetas y usa .webp,
# que es el formato que produce convertMyBackgrounds.
# ================================================

set -euo pipefail

# ==================== CONFIGURACIÓN ====================
readonly WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Imágenes/Wallpapers}"
readonly QUEUE_FILE="/tmp/niri_wallpaper_queue.txt"
readonly LOCK_FILE="/tmp/niri_wallpaper.lock"
readonly RENDER_MODE="${WALLPAPER_RENDER_MODE:-fill}"

# ==================== FUNCIONES ====================

# Adquirir lock (evita ejecuciones concurrentes)
acquire_lock() {
  local pid=""
  [ -f "$LOCK_FILE" ] && pid=$(cat "$LOCK_FILE" 2>/dev/null || true)
  if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
    return 1
  fi
  echo $$ >"$LOCK_FILE"
}

release_lock() {
  rm -f "$LOCK_FILE"
}

# Verificar si la imagen es válida
is_image_valid() {
  [ -f "$1" ] && [ -r "$1" ] && [ -s "$1" ]
}

# ==================== EJECUCIÓN ====================
change_wallpaper() {
  # Evitar ejecuciones concurrentes
  acquire_lock || return 0
  trap release_lock EXIT

  if ! command -v swaybg &>/dev/null; then
    notify-send "Error" "swaybg no está instalado"
    return 1
  fi

  if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Error" "Directorio no existe: $WALLPAPER_DIR"
    return 1
  fi

  # La cola guardada es la lista de imágenes que quedan por salir: se saca la
  # primera y se guarda el resto. Así ninguna se repite hasta agotar la lista.
  local -a pending=()
  if [ -s "$QUEUE_FILE" ]; then
    while IFS= read -r -d '' file; do
      pending+=("$file")
    done <"$QUEUE_FILE"
  fi

  local selected=""
  # Dos pasadas: la cola guardada y, si se agota, un ciclo nuevo barajado.
  for pass in 1 2; do
    while [ ${#pending[@]} -gt 0 ]; do
      selected="${pending[0]}"
      pending=("${pending[@]:1}")
      is_image_valid "$selected" && break 2
      selected=""
    done

    [ "$pass" = "2" ] && break

    local -a all=()
    while IFS= read -r -d '' file; do
      all+=("$file")
    done < <(find "$WALLPAPER_DIR" -type f -iname '*.webp' -print0 2>/dev/null)

    if [ ${#all[@]} -eq 0 ]; then
      notify-send "Error" "No se encontraron imágenes en $WALLPAPER_DIR"
      return 1
    fi
    mapfile -d '' -t pending < <(printf '%s\0' "${all[@]}" | shuf -z)
  done

  if [ -z "$selected" ]; then
    notify-send "Error" "No hay imágenes válidas en $WALLPAPER_DIR"
    return 1
  fi

  if [ ${#pending[@]} -gt 0 ]; then
    printf '%s\0' "${pending[@]}" >"$QUEUE_FILE"
  else
    : >"$QUEUE_FILE"
  fi

  pkill -u "$USER" -x swaybg 2>/dev/null || true
  sleep 0.02
  swaybg -i "$selected" -m "$RENDER_MODE" &
}

change_wallpaper
