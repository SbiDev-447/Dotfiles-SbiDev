# 🔑 Atajos de Teclado (Niri)

### Lanzadores y sistema

| Atajo | Acción |
|-------|--------|
| `Mod+D` | Abrir Fuzzel (launcher principal) |
| `Mod+F1` | Menú integrador (dmenu) |
| `Mod+W` | Selector de wallpapers (fuzzel-Wallpaper) |
| `Mod+Shift+W` | Wallpaper aleatorio siguiente |
| `Mod+E` | Selector de emojis |
| `Mod+BackSpace` | Abrir kitty + tmux + nvim en `~/turtleShell` |
| `Mod+Space` | Gestor de archivos (Thunar) |
| `Mod+Shift+T` | Alternar modo ahorro OLED / presentación |
| `Mod+Shift+Q` | Bloquear pantalla |
| `Mod+Shift+P` | Apagar monitores |
| `Mod+N` | Alternar temperatura de color (wlsunset) |
| `Mod+Shift+Escape` | Salir de Niri |

### Navegación — modelo de columnas

Niri no reparte las ventanas en un mosaico libre: las agrupa en **columnas**. Cada columna
es una pila vertical y la pantalla las coloca una junto a otra. Entender este modelo es lo
que da sentido a todos los atajos de navegación.

| Atajo | Acción |
|-------|--------|
| `Mod+Left` / `Mod+Right` | Foco: columna de la izquierda / de la derecha |
| `Mod+Up` / `Mod+Down` | Foco: ventana de arriba / de abajo **dentro** de la columna |
| `Mod+H` / `Mod+L` | Igual que `Left` / `Right` (atajos vim) |
| `Mod+J` / `Mod+K` | Igual que `Down` / `Up` (atajos vim) |
| `Mod+Shift+flechas` | Foco: monitor de la izquierda / de la derecha |
| `Mod+Ctrl+Left` / `Mod+Ctrl+Right` | **Mover** la columna hacia un lado |
| `Mod+Ctrl+Up` / `Mod+Ctrl+Down` | **Mover** la ventana dentro de su columna |
| `Mod+Ctrl+Shift+flechas` | Mover la columna a otro monitor |
| `Mod+1-9` / `Mod+Shift+1-9` | Ir al workspace / mover la columna a ese workspace |
| `Mod+Comma` / `Mod+Period` | Absorber en la columna la ventana de la derecha / expulsar la de abajo |
| `Mod+V` / `Mod+Shift+V` | Flotar la ventana / alternar entre flotante y mosaico |
| `Mod+C` | Centrar la columna en la pantalla |
| `Mod+Minus` / `Mod+Plus` | Estrechar o ensanchar la columna un 10 % |
| `Mod+Shift+Minus` / `Mod+Shift+Plus` | Bajar o subir la ventana un 10 % |
| `Mod+R` / `Mod+Shift+R` | Ancho de columna: preset siguiente / preset anterior |
| `Mod+Ctrl+Shift+R` | Alto de ventana: preset siguiente |
| `Mod+Ctrl+R` | Restablecer el alto de la ventana al automático |
| `Mod+B` | Vista de pestañas dentro de la columna |
| `Mod+O` | Vista general de columnas |
| `Mod+Q` | Cerrar la ventana |

> 💡 Ojo al reparto: los atajos de **ancho** (`Mod+R`, `Mod+Minus`, `Mod+Plus`) actúan
> sobre la **columna** entera, mientras que los de **alto** (`Mod+Ctrl+Shift+R`,
> `Mod+Ctrl+R`, `Mod+Shift+Plus`) actúan solo sobre la **ventana enfocada**. Por eso no
> existe un `set-column-height`: la columna se ajusta con su ancho.

### Capturas y sistema

| Atajo | Acción |
|-------|--------|
| `Print` | Abrir el overlay de captura (eliges región o ventana) |
| `Ctrl+Print` | Capturar la pantalla completa al instante |
| `Alt+Print` | Capturar la ventana activa al instante |

> Consulta `~/.config/niri/config.kdl` para la lista completa de binds.