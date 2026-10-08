# ============================================
# BASHRC - Gentleman Style
# ============================================

# ============================================
# 1. INTERACTIVIDAD Y SEGURIDAD
# ============================================

# Si no es interactivo, salir
[[ $- != *i* ]] && return

# ============================================
# 2. PATH Y ENTORNO (lo más importante)
# ============================================

# Nix (prioritario)
export PATH="$HOME/.nix-profile/bin:$PATH"

export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"
# Rust (via rustup)
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# NVM (Node Version Manager) — lazy load
# El PATH del alias default se monta a mano (lee ~/.nvm/alias/default: milisegundos)
# y nvm.sh solo se sourcea en la primera llamada real a `nvm` (~0.18 s menos por shell).
# Si el alias es raro ("lts/jod", "system") o el directorio no existe, carga completa.
export NVM_DIR="$HOME/.nvm"
_nvm_bin=""
if [ -r "$NVM_DIR/alias/default" ]; then
  _nvm_alias=$(tr -d '[:space:]' <"$NVM_DIR/alias/default")
  case "$_nvm_alias" in
  v* | [0-9]*)
    _nvm_pat="${_nvm_alias#v}"
    _nvm_bin=$(ls "$NVM_DIR/versions/node" 2>/dev/null | grep -E "^v${_nvm_pat}(\.|$)" | sort -V | tail -n1)
    ;;
  esac
  unset _nvm_alias _nvm_pat
fi
if [ -n "$_nvm_bin" ]; then
  PATH="$NVM_DIR/versions/node/$_nvm_bin/bin:$PATH"
  unset _nvm_bin
else
  unset _nvm_bin
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi
nvm() {
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm "$@"
}
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ============================================
# 3. HISTORIAL
# ============================================

HISTCONTROL=ignoreboth # No duplicados ni líneas con espacio
HISTSIZE=1000          # Historial en memoria
HISTFILESIZE=2000      # Historial en archivo
shopt -s histappend    # Añadir en lugar de sobrescribir
shopt -s checkwinsize  # Actualizar tamaño de ventana

# ============================================
# 4. PROMPT (simple pero informativo)
# ============================================

# Variable para chroot (si existe)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# Detectar colores
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# Prompt con colores (si hay soporte)
if [ "$color_prompt" = yes ]; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt

# Título de la ventana (para xterm)
case "$TERM" in
xterm* | rxvt*)
  PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
  ;;
esac

# ============================================
# 5. COMPLETADO Y COLORES
# ============================================

# Colores para ls (si dircolors está disponible)
if [ -x /usr/bin/dircolors ]; then
  [ -r ~/.dircolors ] && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# Completado automático (bash-completion)
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# ============================================
# 6. ALIASES
# ============================================

# Kitty
alias kicat='kitty +kitten icat'

# Listado con colores (si ls tiene soporte)
alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -A'
alias l='ls -CF'

# Git (solo los que usas en Bash, aunque uses Zsh principalmente)
alias g='git'
alias gs='git status'
alias gl='git log --oneline --decorate --graph'
alias gp='git push'
alias gpl='git pull'

# Utilidades
command -v bat &>/dev/null && alias cat='bat'
command -v delta &>/dev/null && alias diff='delta'

# Alias para WOFF2
alias wofcom='woff2_compress'
alias wofdecom='woff2_decompress'

# ============================================
# 7. FUNCIONES ÚTILES
# ============================================

# npm inteligente (usa pnpm si existe)
npm() {
  if command -v pnpm &>/dev/null; then
    pnpm "$@"
  else
    command npm "$@"
  fi
}

# Crear directorio y entrar
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Buscar archivos y directorios
ff() { find . -type f -name "*$1*" 2>/dev/null; }
fd() { find . -type d -name "*$1*" 2>/dev/null; }

# Extraer archivos comprimidos
extracton() {
  if [ -f "$1" ]; then
    case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz) tar xzf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.rar) unrar x "$1" ;;
    *.gz) gunzip "$1" ;;
    *.tar) tar xf "$1" ;;
    *.tbz2) tar xjf "$1" ;;
    *.tgz) tar xzf "$1" ;;
    *.zip) unzip "$1" ;;
    *.Z) uncompress "$1" ;;
    *.7z) 7z x "$1" ;;
    *) echo "No sé cómo extraer '$1'" ;;
    esac
  else
    echo "'$1' no es un archivo válido"
  fi
}

# ============================================
# 8. CARGA DE ALIASES PERSONALES (si existen)
# ============================================

[ -f ~/.bash_aliases ] && . ~/.bash_aliases

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME/bin:"*) ;;
*) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# opencode
export PATH="$HOME/.opencode/bin:$PATH"
