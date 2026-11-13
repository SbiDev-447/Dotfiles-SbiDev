# RULES FOR AGENTS

## Scope: You are not allowed to push.

- Only the actual user may perform a push; do not attempt other methods or look for ways to execute a push.

## Scope: This configuration file (*dotfile*) is intended for NiriWM (primary) and Sway (secondary). Both are Wayland compositors. When working on this repository:

- Assume Niri as the primary compositor and Sway as the secondary one; do not generate configurations or utilities specific to X11 or XFCE.

- Configs shared between the two compositors (Waybar, Fuzzel, Kitty, Alacritty, Foot, Mako, Neovim) must keep working under **both**. Put compositor-specific differences behind an explicit, per-compositor file (e.g. `config-niri.jsonc` / `config-sway.jsonc`) instead of duplicating the whole config.

- `SbiDev-Sway/` mirrors the Niri layout. When a change touches shared behaviour, check whether the Sway equivalent needs the same edit.

- Do not modify files in `~/.config/xfce4/`, `~/.config/autostart/`, or other XDG paths shared across desktop environments unless explicitly requested.

- Prioritize Niri's native mechanisms (KDL configuration, `niri msg`, *layer-shell*) over generic X11 tools.

- Reusing existing system infrastructure (portals, systemd user units, Wayland protocols) is acceptable, but customize it rather than duplicating it. We do not want to negatively impact other desktop environments simply by prioritizing Niri.

- If a change might affect another desktop environment, indicate this before applying it.

## Scope: Do not clutter with verbose or overly declarative comments.

- Leave information regarding changes, issues, designs, and other relevant details in the appropriate files—specifically those located under DOCUMENTATION.
