# Scripts de Waybar

Este directorio queda con un único módulo custom: el **brillo**. El volumen del sink
pasó al módulo **nativo `pulseaudio`** de Waybar, que es event-driven (escucha los
eventos de PulseAudio) y por tanto ya no necesita script. El resto de módulos de la
barra también son nativos.

`backlight.sh` no se limita a imprimir un icono: también es el que muestra el
porcentaje en la propia barra, sin necesidad de pasar el ratón por encima.

| Script | Módulo | Depende de |
|---|---|---|
| `backlight.sh` | `custom/brightness` | `brightnessctl` |

## Cómo funciona el contrato de salida

Un módulo custom de Waybar interpreta la salida del script así:

- **Línea 1** → lo que se ve en la barra.
- **Líneas 2+** → el tooltip.

Ese contrato es todo el truco. Para mostrar el porcentaje en la barra, `backlight.sh`
imprime una única línea con el número delante y el icono detrás:

```
86% 󰃝
```

El orden es porcentaje y después icono: el número a la izquierda,
el glifo a la derecha.

## Integración en `modules.json`

Los módulos se declaran como un objeto `nombre → definición` en
`waybar/modules.json`, y luego se enumeran en `config.jsonc`:

```json
"pulseaudio#sink": {
  "format": "{volume}% {icon}",
  "format-muted": "󰝟",
  "format-icons": ["󰕿", "󰖀", "󰕾"],
  "on-click": "pactl set-sink-mute @DEFAULT_SINK@ toggle",
  "on-click-right": "pavucontrol -t 3",
  "on-scroll-up": "pactl set-sink-volume @DEFAULT_SINK@ +5%",
  "on-scroll-down": "pactl set-sink-volume @DEFAULT_SINK@ -5%",
  "tooltip": false
},
"custom/brightness": {
  "exec": "$HOME/.config/waybar/scripts/backlight.sh",
  "interval": 3,
  "signal": 3,
  "on-click": "brightnessctl --class=backlight set 10%+; pkill -RTMIN+3 waybar",
  "on-click-right": "brightnessctl --class=backlight set 10%-; pkill -RTMIN+3 waybar",
  "on-scroll-up": "brightnessctl --class=backlight set 5%+; pkill -RTMIN+3 waybar",
  "on-scroll-down": "brightnessctl --class=backlight set 5%-; pkill -RTMIN+3 waybar",
  "tooltip": false
}
```

El `"tooltip": false` es explícito a propósito en ambos casos. El módulo nativo
`pulseaudio#sink` trae un tooltip con información del sink que aquí no queremos, así
que se desactiva. En el custom `custom/brightness` pasa algo parecido: los módulos
custom traen tooltip activado por defecto y, aunque el script solo imprime una línea,
dejarlo declarado evita un tooltip vacío o un cambio futuro que muestre un cuadro al
pasar el ratón.

Después, en `waybar/config.jsonc`, colócalos donde quieras:

```json
"modules-right": [
  "pulseaudio#sink",
  "custom/brightness"
]
```

### Por qué `pulseaudio#sink` no lleva `interval` y `brightness` sí

El volumen del sink **ya no es un módulo custom**: es el módulo **nativo `pulseaudio`**
de Waybar, que se suscribe directamente a los eventos de PulseAudio. Por eso **no
necesita script, ni `interval`, ni `signal`**: cada cambio de volumen o mute (hecho
desde la barra, desde otra app o con las teclas) llega como evento y la barra se
repinta al instante en los dos sentidos. Antes de esta migración eso mismo lo
simulaba un script a mano con `pactl subscribe`; ahora lo aporta el propio módulo
nativo.

El brillo, en cambio, sigue siendo un módulo custom y la elección del worker —
gestionada por Waybar a partir de las claves declaradas (`src/modules/custom.cpp`) —
no es cosmética:

| Declaración | Worker | Comportamiento |
|---|---|---|
| `interval` | `delayWorker` | ejecuta, espera a que muera, duerme `interval`, repite |
| `signal` sin `interval` | `waitingWorker` | ejecuta solo cuando llega la señal |
| ni `interval` ni `signal` | `continuousWorker` | proceso vivo; **cada línea de stdout actualiza** |

- **`custom/brightness` sondea a 3 s con señal.** El sysfs de backlight no emite
  eventos observables (comprobado: `inotifywait` sobre
  `/sys/class/backlight/*/brightness` no captura nada mientras `brightnessctl`
  escribe), así que solo queda sondear — y hay escritores externos que reflejar
  (swayidle). `interval: 3` + `signal: 3` + `pkill -RTMIN+3` en los handlers: los
  cambios externos se ven en ≤3 s, y los tuyos desde la barra al instante porque la
  señal interrumpe el sleep del worker.
- **`pulseaudio#sink` es nativo.** No aparece en la tabla anterior porque no pasa por
  el worker de los módulos custom: su refresco es interno y dirigido por eventos, así
  que declarar `interval` o `signal` aquí no tendría sentido.

## Estilos en `style.css`

Las píldoras reutilizan la paleta del tema, sin colores literales nuevos:

```css
/* pulseaudio#sink (módulo nativo) */
#pulseaudio.sink {
  color: @background;    /* en light.css es @foreground */
  background: @color2;   /* dark.css; en light.css es @color13 */
  padding: 6px 10px;
}

/* custom/brightness */
#custom-brightness {
  color: @background;
  background: @color4;   /* #7fb4ca */
  padding: 6px 10px;
}
```

El `padding: 6px 10px` no es decorativo: la barra mide 26px y el margen global
`margin: -2.5px 5px` del `*` selector compensa el alto. Con esos valores la píldora
queda en 25px, igual que el bloque del reloj. Si cambias el `padding`, la geometría
deja de cuadrar y el bloque se desborda de la barra.

Si las quieres completamente redondeadas, añade `border-radius: 12px`,
porque el `*` selector fuerza `border-radius: 0` a todo.

## La batería sigue la misma regla

El módulo `battery` no es un custom, así que no usa scripts: se configura
entero en `modules.json`. Se le aplicó la misma idea que a volumen y brillo.

```json
"format": "{capacity}% {icon}",
"format-charging": "{capacity}%  ",
"format-plugged": "{capacity}%  ",
"format-critical": "{capacity}% 󰂃"
```

**El porcentaje va dentro de la barra.** Antes vivía solo en el
tooltip (`"Charge: {capacity}%"`) y la barra pintaba únicamente el icono. Al pasar
el tooltip a mostrar solo el estado, el número habría desaparecido de los dos sitios,
así que se movió al label. Por eso los cuatro formatos llevan `{capacity}`
delante: los formatos por estado **sustituyen** al `format` base, no lo completan,
así que si añades uno nuevo tienes que repetir el `{capacity}%` en él.

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
  `power`, `capacity`, `time`, `cycles` y `health`. Por eso el estado hay que
  escribirlo como una clave literal por estado, en vez de confiar en una variable.
- **Las claves se resuelven por este orden** (`src/modules/battery.cpp`):
  `tooltip-format-<estado>-<situación>` → `tooltip-format-<estado>` →
  `tooltip-format-<situación>` → `tooltip-format`. Al existir el formato por estado,
  ese gana y el de situación se ignora. Es lo que quieres: "Cargando" también cuando
  está cargando y baja del 30%.

El `tooltip-format` base queda como red de seguridad por si aparece un estado no
listado; por eso dice algo neutro y no un estado que podría ser falso.

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

Dos cosas se cuelan fácil aquí:

- `Plugged` se lleva prioridad sobre `Not charging` cuando hay adaptador en línea, así
  que con el techo de carga al 80% lo normal es ver `Plugged`, no `Not charging`.
- La clave `tooltip-format-not charging` **lleva espacio**, y es válida en JSON. No es
  una errata.

### El CSS depende del estado, y del orden

```css
#battery {
  color: @background;
  background: @color6;
  padding: 6px 10px;
}

#battery.discharging { background: @color7; }
#battery.plugged     { background: @color4; }
#battery.charging    { background: @color2; }
#battery.warning     { background: @color9; }   /* < 30% */

#battery.critical,
#battery.danger,
#battery.empty {
  background: @color1;                          /* < 20% */
}
```

Todas tienen la misma especificidad, así que **gana la que aparece más abajo en el
archivo**. Por eso los avisos de batería baja van los últimos: una batería descargando
al 15% lleva a la vez `.discharging` y `.critical`, y el rojo tiene que ganar sobre el
color de descarga. Si añades un estado, decide en qué punto lo colocas.

## Recuperar el tooltip

El módulo nativo `pulseaudio#sink` trae su propio tooltip, pero aquí está desactivado
con `"tooltip": false`. Para volver a mostrarlo basta con poner `"tooltip": true` en
`modules.json`: Waybar mostrará el estado del sink y su volumen por defecto, sin tocar
ningún script.

## Requisitos

- `pactl` y `brightnessctl` en el `PATH`.
- El script con bit ejecutable: `chmod +x backlight.sh`.
- Una **Nerd Font** para los iconos (aquí `IosevkaTerm Nerd Font`). Los glifos están
  en el rango de uso privado de Unicode, así que con una fuente normal verás
  caracteres en blanco o ilegibles.

## Advertencia sobre las pruebas ⚠

Estos módulos tienen manejadores de clic y rueda **con efectos reales**: cambian
el volumen, el brillo, abren `pavucontrol` o lanzan el apagado.

No pruebes cambios en la barra lanzando una segunda instancia de Waybar por
encima de la que ya está corriendo:

```bash
waybar -c ~/.config/waybar/config.jsonc   # NO hacer esto con módulos interactivos
```

Esa instancia temporal se queda encima, intercepta los clics y la rueda
que apuntan a la barra real y **ejecuta los handlers dos veces**: el brillo
da saltos de 5% en 5%, el volumen se mueve solo. Para validar el CSS o
la configuración usa un `config.json` temporal sin los módulos interactivos,
o `niri msg` para inspeccionar el estado.
