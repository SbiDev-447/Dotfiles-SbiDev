# ⚙️ Configuraciones Incluidas

### Niri (`config.kdl`)
- **Outputs**: eDP-1 (1920x1080) en `x=0` y HDMI-A-1 (1920x1080) en `x=1920`, uno al lado del otro
- **Layout**: modelo de columnas, `gaps 6`, sin borde ni sombra
- **Focus-ring**: grosor 2.5; inactivo gris `#505050`, activo con degradado `#FFBF00` → `#9381FF`
- **Tamaños**: anchos de columna en presets de 1/3, 1/2 y 2/3 (por defecto 1/2); alturas de ventana igual
- **Cursor**: Win7OS-cursors, tamaño 40
- **Autostart**: solo cuatro procesos — `wlsunset` (curva de temperatura por hora), `waybar`, el rotador de wallpapers y el daemon de inactividad. Los avisos de batería no arrancan desde aquí: Waybar los dispara con `battery.events`
- **Sin `window-rule`**: esta configuración no define reglas por aplicación. El flotado se controla a mano con `Mod+V` y `Mod+Shift+V`

### Fuzzel (`fuzzel.ini`)
- Fuente: IosevkaTerm Nerd Font 14pt
- Match mode: fuzzy (fzf-style)
- Terminal: kitty
- **Temas**: hay dos paletas en `themes/`, `Owl47-Dark` y `Turtle47-Light`. `toggle-theme-fuzzel.sh` alterna la línea `include=` entre ambas dentro de los marcadores `# BEGIN_FUZZEL_THEME`. `Owl47-Dark.ini` queda activa por defecto. La ruta del `include` es absoluta (`~/`) por necesidad: Fuzzel la resuelve tal cual, así que hay que copiar la carpeta a `~/.config/fuzzel/` en lugar de usar una ruta relativa

### Neovim (LazyVim)
- Distribución: LazyVim (basado en GentlemanDots), con `lazyvim.json` declarando 11 extras oficiales
- **Extras**: `dap.core`, `harpoon2`, `mini-files`, `mini-surround`, y los lenguajes `clangd`, `cmake`, `go`, `json`, `markdown`, `typescript` y `typescript.biome`
- **Plugins propios** en `lua/plugins/`: blink (autocompletado), oil, fzflua, twilight, live-server, markdown, nvim-dap, rip, vim-tmux-navigation y which-key, más los de interfaz y editor (`ui`, `editor`, `colorscheme`, `overrides`)
- `lua/plugins/disabled.lua` desactiva a propósito bufferline, avante, CopilotChat, opencode, codecompanion, precognition, smear-cursor y claudecode
- Spellcheck: vocabularios personalizados EN/ES en `spell/`

### Waybar (`config.jsonc` + `modules.json`)
- **Posición**: arriba y en capa superior (`position: top`, `layer: top`)
- **17 módulos**: workspaces de Niri, reloj, CPU, memoria, temperatura, privacidad, MPRIS, red, Bluetooth, micrófono, batería, volumen, brillo y cuatro lanzadores de un clic (dmenu, menú de energía, LocalSend y CachyOS)
- **Volumen y brillo**: módulos `custom` con script propio. Muestran `NN%` junto al icono, sobre una píldora de color, y sin tooltip. El brillo se lee con `brightnessctl --class=backlight`
- **Batería**: el porcentaje va en la barra, no en el tooltip. Waybar lanza `low-battery-notify.sh` mediante `battery.events`, así que no hace falta ningún proceso de avisos aparte
- **CSS**: `style.css` es un symlink que `toggle-theme-waybar.sh` mueve entre `styles/dark.css` y `styles/light.css`, y cada uno importa su paleta (`styles/colors-dark.css` o `styles/colors-light.css`)
- **`setsid` en los `on-click` que lanzan terminales**: `custom/cachy` y `cpu` lanzan `kitty` y `alacritty` con `setsid`, así que cada terminal abre su propia sesión y se desprende de la de Waybar. Sin esto, `toggle-theme-waybar.sh` recarga la barra con `pkill -SIGUSR2 waybar` y esa señal alcanza también a los procesos hijos de Waybar: las terminales lanzadas desde la barra morían con `SIGTERM` al alternar el tema

> ⚠️ **El módulo de temperatura fija `hwmon-path` a `/sys/class/hwmon/hwmon5/temp1_input`**, que es específico de esta máquina. En otro equipo hay que apuntarlo al `hwmon` correcto o el módulo se queda en blanco. Umbrales: aviso a 70 °C, crítico a 80 °C.

### Kitty (`kitty.conf`)
- Tema SbiDev con dos variantes: `kitty-theme.conf` (oscuro) y `kitty-theme-light.conf` (claro)
- Fuente: IosevkaTerm Nerd Font 14pt
- **Rendimiento**: `scrollback_lines 10000`, `repaint_delay 10`, `input_delay 3`, `sync_to_monitor yes`
- **Transparencia**: `background_opacity 0.9`
- `allow_remote_control yes` está activo para poder mandar órdenes desde Neovim. Ojo: falta `listen_address`, así que el socket remoto sigue sin habilitarse; si lo necesitas, añade `listen_address unix:/tmp/kitty`
- Tabs con `cmd+1-9`, copiar/pegar con `ctrl+shift+c/v`

### Alacritty (`alacritty.toml`)
- Tema SbiDev con dos variantes: `alacritty-theme.toml` (oscuro) y `alacritty-theme-light.toml` (claro), elegidas por la línea `general.import` dentro de los marcadores `# BEGIN_ALACRITTY_THEME` (solo una puede estar activa: TOML no admite claves duplicadas). Se usa `general.import` y no `import` a secas porque Alacritty 0.15 ya deprecó la forma corta y avisa por log
- La paleta vive en los archivos importados y **no** en `alacritty.toml`: Alacritty da prioridad al archivo que importa, así que cualquier `[colors.*]` en el principal anularía el tema. Lo mismo pasa con `[font]`, que se queda en `alacritty.toml`
- Fuente: IosevkaTerm NF 14
- El tema claro es la misma paleta que el tema claro de Kitty y el de Foot: fondo crema `#f5efe6`, texto `#2a2a2a`, cursor mostaza `#d9b45a`, selección azul `#2a3d5c`
- **Lo que no se traduce**: el `url_color` de Kitty y los colores de sus tabs no tienen equivalente en Alacritty 0.15, así que los temas solo definen `primary`, `cursor`, `selection` y los 16 colores ANSI

### Foot (`foot.ini`)
- Terminal Wayland minimalista con el **tema claro SbiDev** (la misma paleta que el tema claro de Kitty)
- Fuente: IosevkaTerm Nerd Font 14pt
- Paleta: fondo crema `#f5efe6`, texto `#2a2a2a`, `alpha 0.925`, selección azul `#2a3d5c`
- **Cursor**: bloque mostaza `#d9b45a`, con blink
- **Rendimiento**: `scrollback_lines 10000`

### Fastfetch
- Logos ASCII personalizados (`logoSbiDev.txt`, `logoGengarASCII.txt`, `logoRowlet.txt`, `logoSamurott.txt`, `logoSnorlax.txt`)
- Módulos: OS, Kernel, Terminal, Packages (apt), Uptime, CPU, Memory, Disk, Battery