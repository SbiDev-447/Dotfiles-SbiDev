
<div align="center">

# Niri Scripts Collection

![Debian](https://img.shields.io/badge/Debian-13%20Trixie-blue?logo=debian)
![Wayland](https://img.shields.io/badge/Wayland-Niri-brightgreen)
![License](https://img.shields.io/badge/License-GPLv3-blue)

Colección de scripts de personalización, gestión de energía y lanzadores rápidos con **Fuzzel** diseñados para el compositor [Niri](https://github.com/YaLTeR/niri) en **Debian**. Pensado para quienes disfrutan de un entorno Niri dinámico y minimalista desde *Vanilla*.

</div>

---

## 📋 Scripts Incluidos

Todos los scripts están pensados para ubicarse en `~/.local/bin/` y **no requieren extensión** para ejecutarse directamente.

* **`niri-custom-launcher`**: Lanzador CLI con acceso rápido a `btop` (monitor), `fastfetch` (información) y `nmtui` (red).
* **`fuzzel-power-menu`**: Menú interactivo de apagar, reiniciar, bloquear y suspender.
* **`fuzzel-launcher`**: Menú principal integrador (agrupa energía, herramientas CLI y selector de wallpapers).
* **`fuzzel-Wallpaper`**: Selector dinámico de Wallpapers (solo admite .webp) con soporte para subcarpetas en `~/Imágenes/Wallpapers/`, transiciones rápidas con `swaybg` y persistencia en `/tmp/last_wallpaper.txt`.
* **`lock-screen`**: Bloqueo con `swaylock` (colores oscuros OLED-friendly), apagado de pantallas y suspensión automática.
* **convertMyBackgrounds:** Convertidor CLI automatico de Imagenes con formatos distintos a .webp en ~/Imágenes/Wallpapers/ de forma recursiva (busca en subcarpetas), pide confirmación para eliminar archivos residuales (Imágenes con extension de formato ya convertidas a webp).
---

## 🔧 Requisitos e Instalación

### Dependencias

```bash
# Instalación en Debian
sudo apt install fuzzel swaybg swaylock kitty btop fastfetch nmtui
```

## 🐛 Solución de Problemas

    Fuzzel o Swaylock no abren: Verifica la instalación con which fuzzel o which swaylock.

    Los wallpapers no cambian: Revisa la ruta ~/Imágenes/Wallpapers/ y confirma que swaybg se esté ejecutando con ps aux | grep swaybg.

    Permisos denegados: Asegúrate de dar permisos de ejecución con chmod +x ~/.local/bin/*.

## 📄 Licencia y Contribuciones

Proyecto bajo la licencia GNU General Public License v3.0.

Copyright (C) 2026 SbiDev-447.

Las contribuciones son bienvenidas.

<div align="center">

Hecho con ❤️ para Debian + Niri por SbiDev-447

</div>
