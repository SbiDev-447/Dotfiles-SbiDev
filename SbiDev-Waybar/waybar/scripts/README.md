# Scripts de Waybar

Estos scripts son **módulos custom de Waybar** para el volumen y el brillo. No se
limitan a imprimir un icono: también son los que muestran el porcentaje en la
propia barra, sin necesidad de pasar el ratón por encima.

| Script | Módulo | Depende de |
|---|---|---|
| `audio.sh` | `custom/audio` | `pactl` (PipeWire/PulseAudio) |
| `backlight.sh` | `custom/brightness` | `brightnessctl` |

## Cómo funciona el contrato de salida

Un módulo custom de Waybar interpreta la salida del script así:

- **Línea 1** → lo que se ve en la barra.
- **Líneas 2+** → el tooltip.

Ese contrato es todo el truco. Para mostrar el porcentaje en la barra, el script
imprime una única línea con el número delante y el icono detrás:

```
86% 󰕾
```

El orden es porcentaje y después icono: el número a la izquierda, el glifo a la derecha.

Si el sink está muteado, `audio.sh` imprime **solo el icono**. Un sink muteado sigue
reportando su volumen, así que `86% 󰝟` se leería como "sonando al 86%".

## Integración en `modules.json`

Los módulos se declaran como un objeto `nombre → definición` en
`waybar/modules.json`, y luego se enumeran en `config.jsonc`:

```json
"custom/audio": {
  "exec": "$HOME/.config/waybar/scripts/audio.sh",
  "interval": 1,
  "signal": 3,
  "on-click": "pactl set-sink-mute @DEFAULT_SINK@ toggle; pkill -RTMIN+3 waybar",
  "on-click-right": "pavucontrol -t 3",
  "on-scroll-up": "pactl set-sink-volume @DEFAULT_SINK@ +5%; pkill -RTMIN+3 waybar",
  "on-scroll-down": "pactl set-sink-volume @DEFAULT_SINK@ -5%; pkill -RTMIN+3 waybar",
  "tooltip": false
},
"custom/brightness": {
  "exec": "$HOME/.config/waybar/scripts/backlight.sh",
  "interval": 1,
  "signal": 3,
  "on-click": "brightnessctl --class=backlight set 10%+; pkill -RTMIN+3 waybar",
  "on-click-right": "brightnessctl --class=backlight set 10%-; pkill -RTMIN+3 waybar",
  "on-scroll-up": "brightnessctl --class=backlight set 5%+; pkill -RTMIN+3 waybar",
  "on-scroll-down": "brightnessctl --class=backlight set 5%-; pkill -RTMIN+3 waybar",
  "tooltip": false
}
```

El `"tooltip": false` es explícito a propósito. Los módulos custom traen tooltip
activado por defecto y, aunque aquí el script solo imprime una línea (y por tanto no
hay segunda línea que se muestre), dejarlo declarado evita que un tooltip vacío o un
cambio futuro en el script muestre un cuadro vacío al pasar el ratón.

Después, en `waybar/config.jsonc`, colócalos donde quieras:

```json
"modules-right": [
  "custom/audio",
  "custom/brightness"
]
```

### Por qué `interval` y `signal`

- `interval: 1` refresca el módulo **cada segundo**, para que el número siga a los
  cambios hechos con las teclas de volumen o brillo del teclado.
- `signal: 3` hace que cada acción de ratón mande `pkill -RTMIN+3 waybar` para que el
  módulo se re-ejecute **al instante**, sin esperar al siguiente tick. Sin esa parte,
  la barra se sentiría lenta aunque `interval` fuese 1.

## Estilos en `style.css`

Las píldoras reutilizan la paleta del tema, sin colores literales nuevos:

```css
/* custom/audio */
#custom-audio {
  color: @background;
  background: @color2;   /* #A6E3A1 */
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

Si las quieres completamente redondeadas, añade `border-radius: 12px`, porque el `*`
selector fuerza `border-radius: 0` a todo.

## La batería sigue la misma regla

El módulo `battery` no es un custom, así que no usa scripts: se configura entero en
`modules.json`. Se le aplicó la misma idea que a volumen y brillo.

```json
"format": "{capacity}% {icon}",
"format-charging": "{capacity}%  ",
"format-plugged": "{capacity}%  ",
"format-critical": "{capacity}% 󰂃"
```

**El porcentaje va ahora dentro de la barra, no en el tooltip.** Antes vivía solo en
el tooltip (`"Charge: {capacity}%"`) y la barra pintaba únicamente el icono. Al pasar
el tooltip a mostrar solo el estado, el número habría desaparecido de los dos sitios,
así que se movió al label. Por eso los cuatro formatos llevan `{capacity}` delante: los
formatos por estado **sustituyen** al `format` base, no lo completan, así que si
añades uno nuevo tienes que repetir el `{capacity}% ` en él.

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

Si algún día quieres la barra de bloques otra vez, basta con imprimir una línea más.
El script no necesita más cambios:

```bash
filled=$(( (vol + 5) / 10 ))
bar=""
i=0
while [ "$i" -lt 10 ]; do
  if [ "$i" -lt "$filled" ]; then bar+="▰"; else bar+="▱"; fi
  i=$(( i + 1 ))
done

printf '%s\n%s %s%%\n' "$label" "$bar" "$vol"
```

## Requisitos

- `pactl` y `brightnessctl` en el `PATH`.
- Los scripts con bit ejecutable: `chmod +x audio.sh backlight.sh`.
- Una **Nerd Font** para los iconos (aquí `IosevkaTerm Nerd Font`). Los glifos están
  en el rango de uso privado de Unicode, así que con una fuente normal verás
  caracteres en blanco o ilegibles.

## Advertencia sobre las pruebas ⚠

Estos módulos tienen manejadores de clic y rueda **con efectos reales**: cambian el
volumen, el brillo, abren `pavucontrol` o lanzan el apagado.

No pruebes cambios en la barra lanzando una segunda instancia de Waybar por encima de
la que ya está corriendo:

```bash
waybar -c ~/.config/waybar/config.jsonc   # NO hacer esto con módulos interactivos
```

Esa instancia temporal se queda encima, intercepta los clics y la rueda que apuntan
a la barra real y **ejecuta los handlers dos veces**: el brillo da saltos de 5% en 5%, el
volumen se mueve solo. Para validar el CSS o la configuración usa un `config.json`
temporal sin los módulos interactivos, o `niri msg` para inspeccionar el estado.
