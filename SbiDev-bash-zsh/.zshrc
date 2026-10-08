# ============================================
# ZSH CONFIGURACIÓN - Gentleman Style (Optimizado)
# ============================================

# ============================================
# 1. PATH Y ENTORNO (lo más importante primero)
# ============================================

# Cargar el entorno de Nix (Determinate Nix)
if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
fi

# Construir PATH
export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$HOME/.config/carapace/bin:$HOME/.local/kitty.app/bin:$HOME/.cargo/bin:/usr/local/bin:/usr/bin:/bin"
# NVM (Node Version Manager) — lazy load
# El PATH del alias default se monta a mano (lee ~/.nvm/alias/default: milisegundos)
# y nvm.sh solo se sourcea en la primera llamada real a `nvm` (~0.3 s menos por shell).
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

export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# Cargar powerlevel10k desde Nix (SIEMPRE primero)
if [ -f "$HOME/.nix-profile/share/zsh-powerlevel10k/powerlevel10k.zsh-theme" ]; then
    source "$HOME/.nix-profile/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
fi

# Cargar configuración de Powerlevel10k (si existe)
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# ============================================
# 2. OH-MY-ZSH Y PLUGINS (desde Nix)
# ============================================

# Usar Oh-My-Zsh de Nix directamente
export ZSH="$HOME/.nix-profile/share/oh-my-zsh"
ZSH_THEME=""

# Plugins de Oh-My-Zsh
plugins=(
    git
    fzf
    sudo
    copyfile
    copypath
    colored-man-pages
    history
    docker
    docker-compose
)

# Cargar Oh-My-Zsh
source $ZSH/oh-my-zsh.sh

# Plugins adicionales (desde Nix)
# Zsh Syntax Highlighting
if [ -f "$HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "$HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Zsh Autosuggestions
if [ -f "$HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "$HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# ============================================
# 3. HERRAMIENTAS INTELIGENTES
# ============================================

# Zoxide - Navegación rápida
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# Atuin - Historial mejorado
command -v atuin &>/dev/null && eval "$(atuin init zsh)"

# Carapace - Autocompletado avanzado
if command -v carapace &>/dev/null; then
    export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
    zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
    source <(carapace _carapace)
fi

# ============================================
# 4. CONFIGURACIÓN DE HERRAMIENTAS
# ============================================

# FZF
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Historial
HISTSIZE=50000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

# ============================================
# 5. ALIASES (Tus aliases de siempre)
# ============================================

# Git (los más usados primero)
alias g='git'
alias gs='git status'
alias gss='git status -s'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gd='git diff'
alias gl='git log --oneline --decorate --graph'
alias gp='git push'
alias gpl='git pull'
alias gb='git branch'
alias gba='git branch --all'
alias gst='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'

# Utilidades (herramientas modernas de Nix)
alias ls='eza'
alias ll='eza -l'
alias la='eza -la'
alias lt='eza --tree'
alias tree='eza --tree'
alias treedir='eza -l --icons --tree --level 1'
alias cat='bat'
alias diff='delta'

# Kitty
alias kssh='kitty +kitten ssh'
alias kicat='kitty +kitten icat'

# Nix
alias nix-clean='nix profile wipe-history --older-than 30d && nix-collect-garbage -d && echo "✅ Nix cleaned: $(du -sh /nix/store | cut -f1) used"'
alias nix-list='nix profile list'
alias nix-count='nix profile list | grep -c "^Name:"'
alias nix-info='echo "📦 Paquetes: $(nix profile list | grep -c "^Name:")" && echo "💾 Espacio: $(du -sh /nix/store | cut -f1)"'

# Alias para WOFF2
alias wofcom='woff2_compress'
alias wofdecom='woff2_decompress'

# ============================================
# 6. FUNCIONES ÚTILES
# ============================================

# Crear directorio y entrar
mkcd() { mkdir -p "$1" && cd "$1"; }

# Extraer archivos
extracton() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "No sé cómo extraer '$1'" ;;
        esac
    else
        echo "'$1' no es un archivo válido"
    fi
}

# Buscar archivos y directorios
ff() { find . -type f -name "*$1*" 2>/dev/null; }
fdir() { find . -type d -name "*$1*" 2>/dev/null; }

# npm inteligente (usa pnpm si existe)
npm() {
    if command -v pnpm &>/dev/null; then
        pnpm "$@"
    else
        command npm "$@"
    fi
}



# ========== AGREGADOS =================

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# ============================================
# 8. FIN - Mensaje de éxito (solo si no está en script)
# ============================================

# Si es una terminal interactiva, mostrar mensaje
if [[ -o interactive ]]; then
    echo "󰏒  ZSH IS ONLINE FROM NIX 󰏒 "
fi
export PATH="$PATH:/sbin"
