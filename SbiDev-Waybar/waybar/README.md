# Waybar — módulos y convenciones

Todos los módulos de la barra son **nativos** de Waybar. No queda ningún `custom/*`
que dependa de un script de esta carpeta: `config.jsonc` decide el orden y
`modules.json` define cada módulo.

| Módulo | Refresco |
|---|---|
| `pulseaudio#microphone`, `pulseaudio#sink` | eventos de PulseAudio (interno) |
| `backlight` | eventos udev del subsistema `backlight` |
| `battery`, `network`, `bluetooth`, `cpu`, `memory`, `temperature`, `clock`, `privacy`, `mpris`, `niri/workspaces` | interno de Waybar |
| `custom/cachy`, `custom/localsend`, `custom/dmenu`, `custom/power` | lanzadores de un clic: sin estado y **sin ningún proceso** (ver abajo) |

## Brillo: `backlight`

```json
"backlight": {
  "format": "{percent}% {icon}",
  "format-icons": ["󰃚", "󰃛", "󰃜", "󰃟", "󰃞", "󰃝", "󰃠"],
  "tooltip": false,
  "on-click": "brightnessctl --class=backlight set 10%+",
  "on-click-right": "brightnessctl --class=backlight set 10%-",
  "on-scroll-up": "brightnessctl --class=backlight set 5%+",
  "on-scroll-down": "brightnessctl --class=backlight set 5%-"
}
```

Antes esto era un `custom/brightness` con `scripts/backlight.sh` e `interval: 3`.
Ya no hace falta, y el motivo importa porque la versión anterior se justificaba con
una premisa equivocada:

- **El kernel SÍ emite eventos de brillo.** Cada escritura en
  `/sys/class/backlight/*/brightness` genera un uevent `change` del subsistema
  `backlight` (`SOURCE=sysfs`) — es de lo que se sirve
  `systemd-backlight@backlight:*`. Cómo comprobarlo:
  `udevadm monitor --subsystem-match=backlight` mientras corre
  `brightnessctl --class=backlight set 5%+`.
- **Lo que no emite es inotify.** Instrumentar con `inotifywait` sobre `sysfs` no ve
  nada, y de ahí salió la conclusión —falsa— de que había que sondear. Son dos planos
  distintos: `sysfs` no dispara inotify, pero sí uevent.
- El módulo nativo escucha esos uevent (`src/util/backlight_backend.cpp`) y repinta al
  instante. **`interval` ya no es el mecanismo de refresco**: es solo el timeout del
  `epoll_wait` que re-enumera dispositivos como red de seguridad (2 s por defecto), así
  que aquí no se declara a propósito.
- El refresco funciona en los dos sentidos: los escritores externos
  (`XF86MonBrightnessUp/Down` y `niri-idle.sh`, ambos con `brightnessctl`) también se
  reflejan sin esperas.

Detalles que no son obvios:

- **Iconos**: con 7 iconos Waybar reparte en tramos de `100 / 7 = 14`, así que el glifo
  lleno 󰃠 aparece desde el 84%. El script anterior usaba tramos de 16.7 y solo lo
  mostraba al 100%.
- **`--class=backlight`** en los handlers se conserva por claridad, pero esta máquina
  tiene un único dispositivo (`amdgpu_bl0`), así que el módulo nativo elige igual. Para
  `amdgpu_bl*` lee el atributo `brightness`, que es el correcto.
- **Sin `pkill -RTMIN+3`**: con el refresco por evento sobraba. Tampoco era peligroso:
  Waybar registra `SIGRTMIN+1`..`SIGRTMAX` en `src/main.cpp`.
- **Scroll sin `brightnessctl`**: si se quitan los cuatro `on-*`, el módulo cambia el
  brillo él mismo vía `SetBrightness` de systemd-logind, con `scroll-step` y
  `min-brightness`. Se mantienen los handlers para conservar los saltos actuales
  (5% por rueda, 10% por clic).
- **Tooltip**: desactivado con `"tooltip": false`; con `true` muestra el porcentaje.

## Volumen: `pulseaudio#microphone` y `pulseaudio#sink`

También nativos, y por el mismo motivo: el módulo `pulseaudio` se suscribe a los eventos
de PulseAudio, así que no necesita script, ni `interval`, ni `signal`. Cada cambio de
volumen o mute —hecho desde la barra, desde otra app o con las teclas— llega como evento
y la barra se repinta al instante.

Clave de CSS: el **nombre** del widget es el **nombre del módulo**, y el sufijo `#id` se
agrega como **clase**. Por eso `#pulseaudio` matchea sink y micrófono a la vez, y el sink
necesita id propio para poder apuntar `#pulseaudio.sink`.

## Por qué ya no hace falta ningún módulo `custom`

Waybar elige el worker de un módulo `custom` según las claves declaradas
(`src/modules/custom.cpp`):

| Declaración | Worker | Comportamiento |
|---|---|---|
| `signal` sin `interval` ni `restart-interval` | `waitingWorker` | ejecuta solo cuando llega la señal |
| `interval` | `delayWorker` | ejecuta, espera a que muera, duerme `interval`, repite |
| `exec` sin `interval` ni `signal` | `continuousWorker` | proceso vivo; cada línea de stdout actualiza |
| ni `exec`, ni `interval`, ni `signal` | **ninguno** | no lanza ningún proceso: es una etiqueta con handlers de clic |

Los tres primeros existen para **simular** lo que los módulos nativos ya hacen por dentro
(suscripción a eventos). Mientras haya un módulo nativo, el custom solo añade un proceso,
sondeo y handlers con `pkill` que hay que mantener sincronizados. La única razón válida
para un `custom` aquí son los lanzadores de un clic, y esos caen en el cuarto caso: no
declaran `exec`, así que **no arrancan ningún proceso** y no cuestan nada. Los cuatro son
`custom/cachy` (`setsid kitty` / `setsid alacritty`), `custom/localsend` (`flatpak run
org.localsend.localsend_app`) y dos scripts del repo enlazados en `~/.local/bin`:
`custom/dmenu` → `SbiDev-Fuzzel/dmenu` y `custom/power` → `SbiDev-Fuzzel/fuzzel-power-menu`.

## Batería

El módulo `battery` no usa scripts: se configura entero en `modules.json`.

```json
"format": "{capacity}% {icon}",
"format-charging": "{capacity}%  ",
"format-plugged": "{capacity}% ",
"format-critical": "{capacity}% 󰂃"
```

**El porcentaje va dentro de la barra**, no solo en el tooltip. Antes vivía en el tooltip
y la barra pintaba únicamente el icono. Al pasar el tooltip a mostrar solo el estado, el
número se movió al label. Por eso los cuatro formatos llevan `{capacity}` delante: los
formatos por estado **sustituyen** al `format` base, no lo completan.

### El tooltip dice solo el estado

```json
"tooltip-format": "Batería",
"tooltip-format-charging": "Cargando",
"tooltip-format-discharging": "Descargando",
"tooltip-format-full": "Cargado",
"tooltip-format-plugged": "Conectada",
"tooltip-format-not charging": "Sin cargar",
"tooltip-format-unknown": "Sin datos"
```

Dos detalles que no son evidentes:

- **No existe un placeholder `{status}`.** Los disponibles en el tooltip son `timeTo`,
  `power`, `capacity`, `time`, `cycles` y `health`. Por eso el estado hay que escribirlo
  como una clave literal por estado, en vez de confiar en una variable.
- **Las claves se resuelven por este orden** (`src/modules/battery.cpp`):
  `tooltip-format-<estado>-<situación>` → `tooltip-format-<estado>` →
  `tooltip-format-<situación>` → `tooltip-format`. Al existir el formato por estado, ese
  gana y el de situación se ignora.
- La clave `tooltip-format-not charging` **lleva espacio**, y es válida en JSON. No es
  una errata.

### Los estados que de verdad existen

El `status` que usa Waybar **no es** el texto crudo de `/sys/class/power_supply/*/status`.
Lo combina con el estado del adaptador, y de ahí salen seis valores:

| Estado | Cuándo |
|---|---|
| `Charging` | cargando |
| `Discharging` | descargando |
| `Full` | al 100% |
| `Plugged` | conectado a la red sin cargar (techo de carga alcanzado) |
| `Not charging` | conectado sin cargar y sin adaptador en línea |
| `Unknown` | sin batería legible |

`Plugged` se lleva prioridad sobre `Not charging` cuando hay adaptador en línea, así que
con el techo de carga al 80% lo normal es ver `Plugged`.

### El CSS depende del estado, y del orden

```css
#battery            { background: @color6; }
#battery.discharging{ background: @color7; }
#battery.plugged    { background: @color4; }   /* light.css: @color14 */
#battery.charging   { background: @color2; }   /* light.css: @color13 */
#battery.warning    { background: @color9; }   /* < 30% */
#battery.critical,
#battery.danger,
#battery.empty      { background: @color1; }   /* < 20% */
```

Todas tienen la misma especificidad, así que **gana la que aparece más abajo en el
archivo**. Por eso los avisos de batería baja van los últimos: una batería descargando al
15% lleva a la vez `.discharging` y `.critical`, y el rojo tiene que ganar sobre el color
de descarga. Si añades un estado, decide en qué punto lo colocas.

## CSS: píldoras y geometría

Las píldoras reutilizan la paleta del tema, sin colores literales nuevos:

```css
#pulseaudio.sink { color: @background; background: @color2; padding: 6px 10px; }
#backlight       { color: @background; background: @color9; padding: 6px 10px; }
```

En `light.css` los mismos bloques usan `@foreground` como color y `@color13` (sink) y
`@color3` (brillo) como fondo.

Dos cosas importantes:

- El `padding: 6px 10px` no es decorativo. La barra mide 26px y el `margin: -2.5px 5px`
  del selector `*` compensa el alto: con esos valores la píldora queda en 25px, igual que
  el bloque del reloj. Si cambias el `padding`, la geometría deja de cuadrar y el bloque
  se desborda de la barra.
- Para esquinas completamente redondeadas hay que añadir `border-radius: 12px`, porque el
  selector `*` fuerza `border-radius: 0` a todo.

`styles/dark.css` y `styles/light.css` reciben además `@import "./styles/colors-*.css"`.
`style.css` es un symlink versionado que `toggle-theme-waybar.sh` mueve entre los dos,
y las rutas del `@import` se resuelven contra el directorio del `style.css` (no del
destino del symlink), por eso el link relativo funciona.

## Requisitos

- `brightnessctl` en el `PATH` (handlers de brillo) y `pactl` (micrófono).
- Una **Nerd Font** para los iconos (aquí `IosevkaTerm Nerd Font`). Los glifos están en
  el rango de uso privado de Unicode: con una fuente normal se ven en blanco o ilegibles.
- El módulo de temperatura fija `hwmon-path` a una ruta de esta máquina; en otro equipo
  hay que apuntarla al `hwmon` correcto.

## Advertencia sobre las pruebas ⚠

Los módulos tienen manejadores de clic y rueda **con efectos reales**: cambian el
volumen, el brillo, abren terminales o `pavucontrol` y lanzan el apagado.

No pruebes cambios en la barra lanzando una segunda instancia de Waybar por encima de la
que ya está corriendo:

```bash
waybar -c ~/.config/waybar/config.jsonc   # NO hacer esto con módulos interactivos
```

Esa instancia temporal se queda encima, intercepta los clics y la rueda que apuntan a la
barra real y **ejecuta los handlers dos veces**: el brillo da saltos de 5% en 5%, el
volumen se mueve solo. Para validar el CSS o la configuración usa un `config.json`
temporal sin los módulos interactivos, o `niri msg` para inspeccionar el estado.
