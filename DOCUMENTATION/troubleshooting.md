# 🐛 Solución de Problemas

| Problema | Solución |
|---|---|
| Fuzzel o Swaylock no abren | Verifica la instalación con `which fuzzel` o `which swaylock` |
| Los wallpapers no cambian | Revisa la ruta `~/Imágenes/Wallpapers/` y confirma que `swaybg` esté activo: `ps aux \| grep swaybg` |
| Permisos denegados en scripts | Ejecuta `chmod +x ~/.local/bin/*` |
| Un script no aparece en `~/.local/bin` | `./install-scripts.sh` los enlaza todos; si sigue faltando, comprueba que sea ejecutable en el repo: `test -x <script>` |
| Avisos de batería no aparecen | Verifica el script y su bit de ejecución: `test -x ~/.local/bin/low-battery-notify.sh`, y confirma los eventos con el log de Waybar: `waybar -l debug` |
| Emoji picker no carga | Necesita las dos herramientas: `which wl-copy && which wtype` |
| La temperatura sale vacía | El módulo fija `hwmon-path` a un `hwmon` concreto. Busca el tuyo con `ls /sys/class/hwmon/` y corrígelo en `modules.json` |
| Alacritty no cambia de tema | Comprueba el script (`test -x ~/.local/bin/toggle-theme-alacritty.sh`) y que en `~/.config/alacritty/` estén los tres `.toml`: el principal, `alacritty-theme.toml` y `alacritty-theme-light.toml`. Si el toggle no marca error pero no se ve el cambio, mira que quede **una sola** línea `general.import` sin comentar dentro de los marcadores `# BEGIN_ALACRITTY_THEME` (si pierde el prefijo `general.`, el import desaparece del todo y el toggle se congela) y que `alacritty.toml` no tenga ningún bloque `[colors.*]` propio (ganaría al archivo importado) |
| Fuzzel no cambia de tema | Comprueba el script (`test -x ~/.local/bin/toggle-theme-fuzzel.sh`) y que los dos `.ini` existan en `~/.config/fuzzel/themes/` (`Owl47-Dark.ini` y `Turtle47-Light.ini`). Ojo: un valor de color que no sea **exactamente 8 dígitos hex** no rompe Fuzzel; solo hace que registre `err: config.c:611: ... not a valid color value` y caiga al color por defecto, así que la paleta se degrada en silencio |
| Idle daemon no funciona | Verifica `swayidle`: `which swayidle && pgrep swayidle` |
| Wallpaper rotador no inicia al arrancar | Revisa que `niri_wallpaper.sh` tenga permisos y que la línea de startup esté en `config.kdl` |
| Conversor de imágenes falla | ImageMagick debe estar instalado: `which convert` |