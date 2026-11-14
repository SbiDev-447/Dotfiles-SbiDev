# 🚀 Scripts

### Gestión de Energía y Pantalla

| Script | Descripción | Dependencias |
|--------|-------------|--------------|
| `swaylock-lock-screen` | Bloqueo con paleta OLED-friendly, apaga monitores y suspende | swaylock, niri/swaymsg, systemctl |
| `niri-idle.sh` | Cadena de inactividad **compartida por Niri y Sway**; detecta el compositor por `NIRI_SOCKET`. Niri: 180 s → brillo 30%, 300 s → bloquea + brillo 10% + apaga monitores, 600 s → suspende; el brillo se restaura al volver la actividad y se bloquea antes de suspender. Sway: 300 s → bloquea, 600 s → apaga monitores, bloquea antes de suspender | swayidle, brightnessctl, swaylock, niri/swaymsg, systemctl |
| `toggle-idle.sh` | Alterna swayidle on/off (modo presentación vs ahorro OLED) en ambos compositores | pgrep/pkill, notify-send |
| `fuzzel-power-menu` | Menú interactivo: bloquear+suspender, cerrar sesión (Niri o Sway), reiniciar, apagar | fuzzel, systemctl, niri/swaymsg |

### Lanzadores y Selector de Wallpapers

| Script | Descripción | Dependencias |
|--------|-------------|--------------|
| `dmenu` | Hub principal: energía, tema, emojis, utilidades y wallpapers | fuzzel |
| `fuzzel-custom-launcher` | Menú de utilidades: btop, fastfetch y nmtui, las tres dentro de Kitty | fuzzel, kitty, btop, fastfetch, nmtui |
| `fuzzel-Wallpaper` | Selector de wallpapers WebP con soporte de subcarpetas | fuzzel, swaybg, find |
| `niri_wallpaper.sh` | Rotador aleatorio de wallpapers con persistencia de shuffle | swaybg, shuf, notify-send |
| `convertToWebp` | Conversor recursivo de imágenes a WebP con confirmación. Rechaza `/`, `/home`, `/root` y el HOME del usuario para evitar conversiones masivas accidentales | ImageMagick (convert) |
| `emojipicker.sh` | Selector de ~1500 emojis con búsqueda fuzzy; copia al portapapeles y lo escribe en la ventana activa | fuzzel, wl-clipboard, wtype |
| `toggle-theme-kitty.sh` | Alterna el tema de kitty commenting y descomentando el `include` de `kitty-theme.conf` / `kitty-theme-light.conf` dentro de los marcadores `# BEGIN_KITTY_THEME`. Recarga kitty con `SIGUSR1` | sed, grep, pkill |
| `toggle-theme-alacritty.sh` | Alterna el tema de Alacritty comentando y descomentando el `general.import` de `alacritty-theme.toml` / `alacritty-theme-light.toml` dentro de los marcadores `# BEGIN_ALACRITTY_THEME`. No envía ninguna señal: Alacritty se recarga solo al detectar el cambio | sed, grep |
| `toggle-theme-fuzzel.sh` | Alterna el tema de Fuzzel comentando y descomentando el `include=` de `Owl47-Dark.ini` / `Turtle47-Light.ini` dentro de los marcadores `# BEGIN_FUZZEL_THEME`. No recarga nada: Fuzzel relee la config en cada invocación | sed, grep |
| `toggle-theme-waybar.sh` | Alterna Waybar reescribiendo in situ la línea `@import` de `style.css` entre `styles/dark.css` y `styles/light.css`. Waybar la vigila (`reload_style_on_change: true`) y recarga solo el CSS, sin recrear la barra. Migra instalaciones antiguas donde `style.css` era un symlink | grep, printf, readlink |
| `toggle-theme-nvim.sh` | Alterna el tema de Neovim comentando y descomentando el par `background` + `colorscheme` (`gentleman-kanagawa-blur` / `gruvbox`) dentro de los marcadores `-- BEGIN_NVIM_THEME` de `colorscheme.lua`. No recarga nada: Neovim lee su configuración en el arranque, así que el cambio se aplica en la próxima instancia | sed, grep |
| `toggle-theme-gtk.sh` | Alterna el tema GTK del sistema entre `TurtleGlasses-GTK-Dark` y `TurtleGlasses-GTK` escribiendo `org.gnome.desktop.interface gtk-theme`. Es el único toggle **sin fichero marcador**: el estado se lee de gsettings, que es la única fuente de verdad, así que sigue funcionando aunque cambies el tema a mano con GNOME Tweaks. Las ventanas nuevas salen con el tema nuevo; algunas aplicaciones ya abiertas necesitan reabrirse. Los temas no están versionados, viven en `~/.local/share/themes/` | gsettings |

### Utilidades CLI

| Script | Descripción |
|--------|-------------|
| `updateallsystem` | Actualizador completo: apt + flatpak + nix |
| `low-battery-notify.sh` | Avisos de batería al 30%, 20%, 10% y 5% descargando, y al alcanzar el techo de carga. Los dispara Waybar con `battery.events` al cambiar de estado: sin bucle `sleep`, sin `acpi` y sin `spawn-at-startup` |
| `ufw-help` | Hoja de referencia rápida para comandos UFW |
| `niri-pick-color.sh` | Captura un color de la pantalla con `niri msg pick-color` y lo entrega como RGB (`rgb(r, g, b)`) o HEX (`#rrggbb`), copiándolo además al portapapeles con `wl-copy`. El formato se elige por menú o con `rgb`/`hex`. Alias: `npc` |