# 🔧 Requisitos e Instalación

### Dependencias

```bash
# Dependencias core
sudo apt install fuzzel swaybg swaylock kitty foot btop fastfetch nmtui brightnessctl

# Para el rotador de wallpapers y notificaciones
sudo apt install libnotify-bin imagemagick

# Para el selector de emojis
# wl-copy pega en el portapapeles; wtype escribe el emoji en la ventana activa
sudo apt install wl-clipboard wtype

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

# Crear ~/.config si no existe; si no, el primer cp no crea la subcarpeta
mkdir -p ~/.config

# Copiar configuraciones
cp -r SbiDev-Niri/niri ~/.config/               # Config de Niri
cp -r SbiDev-Fuzzel/fuzzel ~/.config/           # Config de Fuzzel
cp -r SbiDev-Kitty/kitty ~/.config/             # Config de Kitty
cp -r SbiDev-Alacritty/alacritty ~/.config/     # Config de Alacritty
cp -r SbiDev-Foot/foot ~/.config/               # Config de Foot
cp -r SbiDev-Waybar/waybar ~/.config/           # Config de Waybar
cp -r SbiDev-NVIM/nvim ~/.config/               # Config de Neovim
mkdir -p ~/.config/fastfetch                    # Fastfetch usa su propia carpeta
cp -r SbiDev-Fastfetch/* ~/.config/fastfetch/   # Config de Fastfetch

# Enlazar los scripts a ~/.local/bin/
./install-scripts.sh
```

> **¿Cómo funciona `install-scripts.sh`?**
> Crea **enlaces simbólicos** de todos los ejecutables hacia `~/.local/bin/`
(que crea si no existe), para que los scripts se actualicen solos al hacer
`git pull` sin recapiar nada. Cubre 18 scripts de ocho carpetas:
>
> | Carpeta | Qué aporta |
> |---------|------------|
> | `SbiDev-CLI-Scripts/` | `updateallsystem`, `ufw-help`, `low-battery-notify.sh`, `convertMyBackgrounds` |
> | `SbiDev-Fuzzel/` | `dmenu`, `emojipicker.sh`, `fuzzel-custom-launcher`, `fuzzel-power-menu`, `fuzzel-Wallpaper` |
> | `SbiDev-Fuzzel/scripts/` | `toggle-theme-fuzzel.sh` |
> | `SbiDev-Niri/` | `swaylock-lock-screen`, `toggle-idle.sh`, `niri-idle.sh`, `niri_wallpaper.sh` |
> | `SbiDev-Kitty/scripts/` | `toggle-theme-kitty.sh` |
> | `SbiDev-Alacritty/scripts/` | `toggle-theme-alacritty.sh` |
> | `SbiDev-Waybar/scripts/` | `toggle-theme-waybar.sh` |
> | `SbiDev-NVIM/scripts/` | `toggle-theme-nvim.sh` |
>
> Los enlaces son **relativos**, así que puedes mover el repo de sitio sin romperlos.
>
> - Es **idempotente**: si un symlink ya apunta al repo, lo salta con `OK`.
> - Si **ya existe un archivo** con el mismo nombre, lo omite con `SKIP` para no sobrescribir nada.
> - Con `./install-scripts.sh --force` elimina los archivos existentes y los sustituye por symlinks al repo (útil tras migrar de copias a enlaces).

> **Nota**: algunos ficheros llevan rutas absolutas de mi máquina (`/home/sbi/`), y hay que ajustarlas a tu usuario:
>
> - `SbiDev-Kitty/kitty/kitty.conf` → `shell /home/sbi/.nix-profile/bin/zsh`
> - `SbiDev-Niri/niri/config.kdl` → invoca `niri_wallpaper.sh`, `niri-idle.sh`, `emojipicker.sh` y `swaylock-lock-screen` con ruta absoluta
>
> La alternativa más limpia para el `kitty.conf` y el `config.kdl` es sustituir las rutas por `~/.local/bin/...`, que es justo donde `install-scripts.sh` deja los enlaces.
>
> El symlink `SbiDev-Waybar/waybar/style.css` **sí es relativo** (`styles/dark.css`), a propósito: así sobrevive a un `git clone` en otra máquina. `toggle-theme-waybar.sh` lo mantiene relativo al cambiar de tema.