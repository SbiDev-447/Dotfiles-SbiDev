#!/bin/bash

# ================================================
# Script para cambiar fondo de pantalla en Niri
# Usa swaybg con orden aleatorio sin repeticiones
# Soporta subcarpetas y múltiples formatos
# ================================================

set -euo pipefail

# ==================== CONFIGURACIÓN ====================
readonly WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Imágenes/Wallpapers}"
readonly STATE_FILE="/tmp/niri_wallpaper_state.txt"
readonly INDEX_FILE="/tmp/niri_wallpaper_index.txt"
readonly LOCK_FILE="/tmp/niri_wallpaper.lock"
readonly RENDER_MODE="${WALLPAPER_RENDER_MODE:-fill}"

# ==================== FUNCIONES ====================

# Adquirir lock (evita ejecuciones concurrentes)
acquire_lock() {
  if [ -f "$LOCK_FILE" ]; then
    local pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      return 1
    fi
  fi
  echo $$ >"$LOCK_FILE"
  return 0
}

release_lock() {
  rm -f "$LOCK_FILE"
}

# Construir argumentos para find
build_find_args() {
  local args=()
  # Solo buscamos webp para ser rápidos
  args+=(-iname "*.webp")
  echo "${args[@]}"
}

# Obtener todas las imágenes
get_all_images() {
  local -n result=$1
  local find_args=$(build_find_args)

  [ -d "$WALLPAPER_DIR" ] || return 1

  while IFS= read -r -d '' file; do
    result+=("$file")
  done < <(find "$WALLPAPER_DIR" -type f \( $find_args \) -print0 2>/dev/null)
}

# Barajar y guardar estado
shuffle_and_save() {
  local images=("$@")
  [ ${#images[@]} -eq 0 ] && return 1
  printf "%s\0" "${images[@]}" | shuf -z >"$STATE_FILE"
  echo 0 >"$INDEX_FILE"
}

# Leer estado guardado
read_state() {
  local -n result=$1
  if [ -f "$STATE_FILE" ] && [ -s "$STATE_FILE" ]; then
    while IFS= read -r -d '' file; do
      [ -f "$file" ] && [ -r "$file" ] && result+=("$file")
    done <"$STATE_FILE"
  fi
}

# Obtener índice actual
get_current_index() {
  local max_index=$1
  local index=0

  if [ -f "$INDEX_FILE" ]; then
    index=$(cat "$INDEX_FILE" 2>/dev/null || echo 0)
    [[ "$index" =~ ^[0-9]+$ ]] || index=0
    [ "$index" -ge "$max_index" ] && index=0
  fi
  echo "$index"
}

# Verificar si la imagen es válida
is_image_valid() {
  [ -f "$1" ] && [ -r "$1" ] && [ -s "$1" ]
}

# Función principal
change_wallpaper() {
  # Evitar ejecuciones concurrentes
  acquire_lock || return 0
  trap release_lock EXIT

  local all_images=()
  get_all_images all_images || {
    notify-send "Error" "Directorio no existe: $WALLPAPER_DIR"
    return 1
  }

  [ ${#all_images[@]} -eq 0 ] && {
    notify-send "Error" "No se encontraron imágenes en $WALLPAPER_DIR"
    return 1
  }

  local shuffled_images=()
  read_state shuffled_images

  if [ ${#shuffled_images[@]} -ne ${#all_images[@]} ] || [ ${#shuffled_images[@]} -eq 0 ]; then
    shuffle_and_save "${all_images[@]}"
    shuffled_images=()
    read_state shuffled_images
  fi

  local index=$(get_current_index "${#shuffled_images[@]}")
  local selected_image="${shuffled_images[$index]}"

  # Verificar imagen seleccionada
  if ! is_image_valid "$selected_image"; then
    # Buscar primera imagen válida
    for img in "${shuffled_images[@]}"; do
      if is_image_valid "$img"; then
        selected_image="$img"
        break
      fi
    done

    # Si ninguna es válida, regenerar
    if ! is_image_valid "$selected_image"; then
      shuffle_and_save "${all_images[@]}"
      shuffled_images=()
      read_state shuffled_images
      selected_image="${shuffled_images[0]}"
      index=1
    else
      # Encontrar índice de la imagen seleccionada
      for i in "${!shuffled_images[@]}"; do
        if [ "${shuffled_images[$i]}" = "$selected_image" ]; then
          index=$((i + 1))
          break
        fi
      done
    fi
  else
    index=$((index + 1))
  fi

  # Guardar siguiente índice
  if [ "$index" -ge "${#shuffled_images[@]}" ]; then
    shuffle_and_save "${all_images[@]}"
  else
    echo "$index" >"$INDEX_FILE"
  fi

  # Cambiar wallpaper
  pkill -u "$USER" -x swaybg 2>/dev/null || true
  sleep 0.02

  if command -v swaybg &>/dev/null; then
    swaybg -i "$selected_image" -m "$RENDER_MODE" &
  else
    notify-send "Error" "swaybg no está instalado"
    return 1
  fi
}

# ==================== EJECUCIÓN ====================
change_wallpaper
