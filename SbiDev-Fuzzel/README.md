<div align="center">

# 🎛️ Fuzzel Scripts Collection

</div>

---
---

## 📖 Descripción General

Colección de scripts y configuraciones para **Fuzzel**,
un lanzador de aplicaciones para Wayland, diseñados
para mejorar la productividad y personalización en entornos como Niri y Sway.

## 🛠️ Scripts Disponibles

### 1. fuzzel-launcher (Lanzador Principal)

Lanzador principal que ofrece acceso rápido a todas las funcionalidades.

Opciones:

    ⚙️ Menú PowerSession - Gestión de energía (bloquear, suspender, reiniciar, apagar)

    📜 ScriptsTerminal - Acceso a comandos y utilidades de terminal

    🖼️ Wallpapers Swaybg - Selector de fondos de pantalla

    🚪 Salir - Cerrar el lanzador

#### 2. fuzzel-power-menu (Menú de Energía)

Control rápido de energía del sistema.

Opciones:

    🔒 Bloquear y 💤 Suspender - Bloquea la pantalla y suspende el sistema

    🔄 Reiniciar - Reinicia el sistema

    ⏻ Apagar - Apaga el sistema

#### 3. fuzzel-custom-launcher (Lanzador Personalizado)

Acceso rápido a herramientas útiles.

Opciones:

    📊 Btop - Monitor de recursos (necesita kitty)

    💻 Fastfetch - Información del sistema (necesita kitty)

    🌐 nmtui - Configuración de red (necesita kitty)

    🌄 ConvertBackgroundToWebp - Convertir fondos de pantalla a WebP

#### 4. fuzzel-Wallpaper (Selector de Wallpapers)

Navegador de fondos de pantalla con soporte para WebP.

Características:

    Busca automáticamente en ~/Imágenes/Wallpapers o ~/Pictures/Wallpapers

    Soporta organización por carpetas

    Muestra nombres formateados: [carpeta] nombre.webp

    Transiciones suaves con swaybg

    Guarda el último wallpaper usado

#### 5. emojipicker.sh (Selector de Emojis)

Buscador, copiador y pegador de emojis.

Características:

    Busca emojis por nombre o descripción

    Al elegir con Enter, pega el emoji en la ventana que tenía el foco (wtype)

    Copia automáticamente al portapapeles (wl-copy)

    Interfaz intuitiva con búsqueda en tiempo real

    Más de 1000 emojis disponibles

    Esc cancela sin copiar ni pegar nada

## ⚙️ Instalación

### Requisitos Previos

- Fuzzel (>= 1.10)
- wl-copy y wtype (para emojis)
- swaybg (para wallpapers)
- kitty (para scripts de terminal)

## 📝 Notas Importantes

> - Los scripts están diseñados para Wayland
> - Asegúrate de que swaybg esté instalado para el cambio de wallpapers
> - El selector de emojis usa wl-copy y wtype (requiere Wayland).
Espera a que el compositor devuelva el foco a la ventana anterior antes de escribir;
si el pegado no es fiable, ajusta EMOJI_PICKER_FOCUS_DELAY (por defecto 0.2s)
> - Los scripts terminal necesitan kitty o modificar el terminal
