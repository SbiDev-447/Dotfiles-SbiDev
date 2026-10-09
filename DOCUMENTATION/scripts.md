# 🚀 Scripts

### Gestión de Energía y Pantalla

| Script | Descripción | Dependencias |
|--------|-------------|--------------|
| `swaylock-lock-screen` | Bloqueo con paleta OLED-friendly, apaga monitores y suspende | swaylock, niri, systemctl |
| `niri-idle.sh` | Daemon de inactividad: 180 s → brillo 30%, 300 s → brillo 10% y apaga monitores, 600 s → suspende. Al bloquear baja el brillo y apaga la pantalla; al desbloquear y al volver de suspender, la enciende y deja el brillo al 50% | swayidle, brightnessctl, niri, systemctl |
| `toggle-idle.sh` | Alterna swayidle on/off (modo presentación vs ahorro OLED) | pgrep/pkill, notify-send |
| `fuzzel-power-menu` | Menú interactivo: bloquear+suspender, reiniciar, apagar | fuzzel, systemctl |

### Lanzadores y Selector de Wallpapers

| Script | Descripción | Dependencias |
|--------|-------------|--------------|
| `dmenu` | Hub principal: energía, tema, emojis, utilidades y wallpapers | fuzzel |
| `fuzzel-custom-launcher` | Menú de utilidades: btop, fastfetch y nmtui, las tres dentro de Kitty | fuzzel, kitty, btop, fastfetch, nmtui |
| `fuzzel-Wallpaper` | Selector de wallpapers WebP con soporte de subcarpetas | fuzzel, swaybg, find |
| `niri_wallpaper.sh` | Rotador aleatorio de wallpapers con persistencia de shuffle | swaybg, shuf, notify-send |
| `convertMyBackgrounds` | Conversor recursivo de imágenes a WebP con confirmación | ImageMagick (convert) |
| `emojipicker.sh` | Selector de ~1500 emojis con búsqueda fuzzy; copia al portapapeles y lo escribe en la ventana activa | fuzzel, wl-clipboard, wtype |
| `toggle-theme-kitty.sh` | Alterna el tema de kitty commenting y descomentando el `include` de `kitty-theme.conf` / `kitty-theme-light.conf` dentro de los marcadores `# BEGIN_KITTY_THEME`. Recarga kitty con `SIGUSR1` | sed, grep, pkill |
| `toggle-theme-alacritty.sh` | Alterna el tema de Alacritty comentando y descomentando el `general.import` de `alacritty-theme.toml` / `alacritty-theme-light.toml` dentro de los marcadores `# BEGIN_ALACRITTY_THEME`. No envía ninguna señal: Alacritty se recarga solo al detectar el cambio | sed, grep |
| `toggle-theme-fuzzel.sh` | Alterna el tema de Fuzzel comentando y descomentando el `include=` de `Owl47-Dark.ini` / `Turtle47-Light.ini` dentro de los marcadores `# BEGIN_FUZZEL_THEME`. No recarga nada: Fuzzel relee la config en cada invocación | sed, grep |
| `toggle-theme-waybar.sh` | Alterna Waybar moviendo el symlink `style.css` entre `styles/dark.css` y `styles/light.css` y recarga la barra con `SIGUSR2` | sed, ln, readlink, pkill |
| `toggle-theme-nvim.sh` | Alterna el tema de Neovim comentando y descomentando el par `background` + `colorscheme` (`gentleman-kanagawa-blur` / `gruvbox`) dentro de los marcadores `-- BEGIN_NVIM_THEME` de `colorscheme.lua`. No recarga nada: Neovim lee su configuración en el arranque, así que el cambio se aplica en la próxima instancia | sed, grep |

### Utilidades CLI

| Script | Descripción |
|--------|-------------|
| `updateallsystem` | Actualizador completo: apt + flatpak + nix |
| `low-battery-notify.sh` | Avisos de batería al 30%, 20%, 10% y 5% descargando, y al alcanzar el techo de carga. Los dispara Waybar con `battery.events` al cambiar de estado: sin bucle `sleep`, sin `acpi` y sin `spawn-at-startup` |
| `ufw-help` | Hoja de referencia rápida para comandos UFW |