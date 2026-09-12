<div align="center">

# Dotfiles by SbiDev-447

![Debian](https://img.shields.io/badge/Debian-13%20Trixie-blue?logo=debian&style=for-the-badge)
![Wayland](https://img.shields.io/badge/Wayland-Niri-brightgreen?logo=wayland&style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT%20%26%20GPLv3-blue?style=for-the-badge)
![Neovim](https://img.shields.io/badge/Neovim-LazyVim-57A143?logo=neovim&style=for-the-badge)
![Fuzzel](https://img.shields.io/badge/Launcher-Fuzzel-orange?style=for-the-badge)

**Colección de dotfiles, configuraciones y scripts** diseñados para el compositor [Niri](https://github.com/YaLTeR/niri) en **Debian 13 Trixie**.  
Incluye personalización de entorno, gestión de energía, lanzadores rápidos con **Fuzzel**, editor **Neovim** potenciado con **LazyVim** (basado en GentlemanDots), y utilidades CLI propias.
</div>

---

## 🔑 Atajos de Teclado Principales (Niri)

| Atajo | Acción |
|-------|--------|
| `Mod+D` | Abrir Fuzzel (launcher principal) |
| `Mod+F1` | Menú integrador (dmenu) |
| `Mod+W` | Selector de wallpapers (fuzzel-Wallpaper) |
| `Mod+Shift+W` | Wallpaper aleatorio siguiente |
| `Mod+E` | Selector de emojis |
| `Mod+Shift+T` | Alternar modo ahorro OLED / presentación |
| `Mod+Shift+Q` | Bloquear pantalla |
| `Mod+Shift+P` | Apagar monitores |
| `Mod+N` | Alternar temperatura de color (wlsunset) |
| `Mod+BackSpace` | Abrir kitty + tmux + nvim en `~/turtleShell` |
| `Mod+O` | Vista general de ventanas |
| `Mod+Q` | Cerrar ventana |
| `Mod+H/J/K/L` | Mover foco (izq/abajo/arriba/der) |
| `Mod+Arrow` | Mover ventana |
| `Mod+1-9` | Cambiar workspace |
| `Print` | Screenshot de toda la pantalla |
| `Ctrl+Print` | Screenshot de ventana activa |
| `Alt+Print` | Screenshot de selección |
| `Mod+Shift+Escape` | Salir de Niri |

> Consulta `~/.config/niri/config.kdl` para la lista completa de binds.

---

## 🚀 Scripts Detallados

### Gestión de Energía y Pantalla

| Script | Descripción | Dependencias |
|--------|-------------|--------------|
| `swaylock-lock-screen` | Bloqueo con paleta OLED-friendly, apaga monitores y suspende | swaylock, niri, systemctl |
| `niri-idle.sh` | Daemon de inactividad: 180s→brillo 30%, 300s→monitores off, 600s→suspend | swayidle, brightnessctl, niri |
| `toggle-idle.sh` | Alterna swayidle on/off (modo presentación vs ahorro OLED) | pgrep/pkill, notify-send |
| `fuzzel-power-menu` | Menú interactivo: bloquear+suspender, reiniciar, apagar | fuzzel, systemctl |

### Lanzadores y Selector de Wallpapers

| Script | Descripción | Dependencias |
|--------|-------------|--------------|
| `dmenu` | Hub principal: energía, utilidades, wallpapers | fuzzel |
| `fuzzel-custom-launcher` | Menú de utilidades: btop, fastfetch, nmtui, conversor | fuzzel, kitty, btop, nmtui |
| `fuzzel-Wallpaper` | Selector de wallpapers WebP con soporte de subcarpetas | fuzzel, swaybg, find |
| `niri_wallpaper.sh` | Rotador aleatorio de wallpapers con persistencia de shuffle | swaybg, shuf, notify-send |
| `convertMyBackgrounds` | Conversor recursivo de imágenes a WebP con confirmación | ImageMagick (convert) |
| `emojipicker.sh` | Selector de ~1500 emojis con búsqueda fuzzy, copia al clipboard | fuzzel, wl-copy |

### Utilidades CLI

| Script | Descripción |
|--------|-------------|
| `updateallsystem` | Actualizador completo: apt + flatpak + nix |
| `low-battery-notify.sh` | Notificaciones en 20%, 10% y 5% de batería (polling cada 60s) |
| `ufw-help` | Hoja de referencia rápida para comandos UFW |

---

## ⚙️ Configuraciones Incluidas

### Niri (`config.kdl`)
- **Outputs**: eDP-1 (1920x1080) + HDMI-A-1 (1920x1080, offset 1280,0)
- **Layout**: gaps 6, focus-ring con gradiente, esquinas redondeadas (radio 8)
- **Startup**: wlsunset, waybar, wallpaper rotator, swaync, idle daemon
- **Reglas de ventana**: floating para calculadora, Bluetooth, PuP para Firefox/LibreWolf/Chromium, bloqueo de captura en KeePassXC
- **Cursor**: Win7OS-cursors (size 40)

### Fuzzel (`fuzzel.ini`)
- Fuente: IosevkaTerm Nerd Font 14pt
- Match mode: fuzzy (fzf-style)
- Terminal: kitty
- 2 temas incluidos:
  - **Turtle47-Light**: paleta clara con fondo crema
  - **Owl47-Dark**: paleta oscura estilo Catppuccin

### Neovim (LazyVim)
- Distribución: LazyVim starter (basado en GentlemanDots)
- Plugins: Oil, Fzflua, Twilight, vim-tmux-navigation, live-server, markdown, DAP
- Spellcheck: vocabulario personalizado EN/ES

### Fastfetch
- Logo ASCII personalizado (`logoSbiDev.txt`)
- Módulos: OS, Kernel, Terminal, Packages (apt), Uptime, CPU, Memory, Disk, Battery

---

## 🔧 Requisitos e Instalación

### Dependencias

```bash
# Dependencias core
sudo apt install fuzzel swaybg swaylock kitty btop fastfetch nmtui brightnessctl

# Para el rotador de wallpapers y notificaciones
sudo apt install libnotify-bin imagemagick

# Para el selector de emojis
# Necesita wl-copy (parte de wl-clipboard)
sudo apt install wl-clipboard

# Para la gestión de energía
sudo apt install swayidle wlsunset playerctl

# Neovim (LazyVim)
# Seguir los pasos de GentlemanDots o la página oficial de LazyVim
```

### Instalación

```bash
# Clonar el repositorio
git clone https://github.com/SbiDev-447/Dotfiles-SbiDev.git
cd Dotfiles-SbiDev

# Copiar configuraciones
cp -r SbiDev-Niri/niri ~/.config/          # Config de Niri
cp -r SbiDev-Fuzzel/fuzzel ~/.config/      # Config de Fuzzel
cp -r SbiDev-NVIM/nvim ~/.config/          # Config de Neovim
cp -r SbiDev-Fastfetch/* ~/.config/fastfetch/ # Config de Fastfetch

# Enlazar los scripts a ~/.local/bin/
./install-scripts.sh
```

> **¿Cómo funciona `install-scripts.sh`?**
> Crea **enlaces simbólicos** de todos los ejecutables de `SbiDev-CLI-Scripts/`, `SbiDev-Fuzzel/` y `SbiDev-Niri/` hacia `~/.local/bin/` (lo crea si no existe). Así los scripts se actualizan automáticamente al hacer `git pull`, sin necesidad de recopiar.
> - Es **idempotente**: si un symlink ya apunta al repo, lo salta con `OK`.
> - Si **ya existe un archivo** con el mismo nombre, lo omite con `SKIP` para no sobrescribir nada.
> - Con `./install-scripts.sh --force` elimina los archivos existentes y los sustituye por symlinks al repo (útil tras migrar de copias a enlaces).

> **Nota**: Algunos scripts hacen referencia a rutas absolutas como `/home/sbi/`. Ajusta las rutas en los scripts o en `config.kdl` según tu usuario.

---

## 🐛 Solución de Problemas

| Problema | Solución |
|----------|----------|
| Fuzzel o Swaylock no abren | Verifica la instalación con `which fuzzel` o `which swaylock` |
| Los wallpapers no cambian | Revisa la ruta `~/Imágenes/Wallpapers/` y confirma que `swaybg` esté activo: `ps aux \| grep swaybg` |
| Permisos denegados en scripts | Ejecuta `chmod +x ~/.local/bin/*` |
| Notificaciones de batería no aparecen | Verifica que `acpi` esté instalado: `sudo apt install acpi` |
| Emoji picker no carga | Confirma que `wl-copy` esté instalado: `which wl-copy` |
| Idle daemon no funciona | Verifica `swayidle`: `which swayidle && pgrep swayidle` |
| Wallpaper rotador no inicia al arrancar | Revisa que `niri_wallpaper.sh` tenga permisos y que la línea de startup esté en `config.kdl` |
| Conversor de imágenes falla | ImageMagick debe estar instalado: `which convert` |

---

## 📄 Licencia

Este repositorio usa **dos licencias** diferentes:

- **MIT**: Aplica a todos los archivos de configuración (nvim, niri, fuzzel, etc.) y a los scripts que no indiquen lo contrario.
- **GPL-3.0**: Aplica específicamente a los scripts que incluyan la cabecera GPL en su interior:
  - `convertMyBackgrounds`
  - `dmenu`
  - `emojipicker.sh`
  - `fuzzel-Wallpaper`
  - `niri_wallpaper.sh`

Cada archivo con licencia GPL tiene una cabecera que lo indica claramente.

Las contribuciones son bienvenidas.

<div align="center">

**Hecho con ❤️ por SbiDev-447**

Inspirado por el queridisimo [Gentleman Programming / Alan Buscaglia](https://github.com/Gentleman-Programming/Gentleman.Dots).

Copyright (c) 2026 SbiDev-447.

</div>

![Wallpapers](./Files/image.webp)
