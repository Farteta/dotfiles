# ============================================
# CUSTOM CONFIGURATION
# ============================================

# Fix terminal type for SSH from Kitty
if [[ "$TERM" == "xterm-kitty" ]]; then
    export TERM=xterm-256color
fi

# PATH
export PATH="/usr/local/bin:$HOME/.local/bin:$PATH"

# Editor
export EDITOR="micro"
export VISUAL="micro"

# Starship prompt (replaces bash-it theme)
if command -v starship &>/dev/null; then
    export BASH_IT_THEME=''  # Disable bash-it theme
    eval "$(starship init bash)"
fi

# Welcome message (comment out if annoying)
command -v fastfetch &>/dev/null && fastfetch

# ============================================
# NAVIGATION & DIRECTORY ALIASES
# ============================================

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'

# ============================================
# QUICK ACCESS
# ============================================

alias c='clear'
alias h='history'
alias bashconfig='micro ~/.bashrc'
alias dotfiles='cd ~/dotfiles'

# ============================================
# BETTER CLI TOOLS
# ============================================

# Better ls with eza (fallback to regular ls)
if command -v eza &>/dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -lah --icons --git --group-directories-first'
    alias lt='eza --tree --level=2 --icons'
    alias la='eza -a --icons --group-directories-first'
    alias l='eza -lh --icons --git --group-directories-first'
else
    alias ls='ls --color=auto --group-directories-first'
    alias ll='ls -lah --color=auto'
    alias la='ls -a --color=auto'
    alias l='ls -lh --color=auto'
fi

# Better cat with bat
if command -v batcat &>/dev/null; then
    alias bat='batcat'
    alias cat='batcat --style=auto'
    alias bathelp='batcat --plain --language=help'
elif command -v bat &>/dev/null; then
    alias cat='bat --style=auto'
    alias bathelp='bat --plain --language=help'
fi

# Better help pages
if command -v bat &>/dev/null || command -v batcat &>/dev/null; then
    help() {
        "$@" --help 2>&1 | bathelp
    }
fi

# ============================================
# GIT ALIASES
# ============================================

alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gds='git diff --staged'
alias glog='git log --oneline --graph --decorate --all'
alias gco='git checkout'
alias gb='git branch'
alias gcl='git clone'

# ============================================
# SYSTEM & UTILITIES
# ============================================

# Disk usage
alias df='df -h'
alias du='du -h'

# Quick editing
alias v='micro'
alias e='micro'

# Network
alias ports='netstat -tulanp'
alias ping='ping -c 5'

# Process management
alias ps='ps auxf'
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# ============================================
# DIRECTORY JUMPING & SEARCH
# ============================================

# zoxide - smart directory jumping
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash)"
    alias cd='z'
    alias cdi='zi'  # Interactive selection
fi

# fzf - fuzzy finder
if [ -f ~/.fzf.bash ]; then
    source ~/.fzf.bash
    # Better defaults with preview
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || cat {}'"
fi

# ============================================
# DOCKER ALIASES (if you use Docker)
# ============================================

if command -v docker &>/dev/null; then
    alias d='docker'
    alias dc='docker compose'
    alias dps='docker ps'
    alias dpsa='docker ps -a'
    alias di='docker images'
    alias dlog='docker logs -f'
    alias dex='docker exec -it'
fi

# ============================================
# SYSTEM FUNCTIONS
# ============================================

# Make and enter directory
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract archives easily
extract() {
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
            *) echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick reload
alias reload='source ~/.bashrc && echo "Bashrc reloaded!"'

# ============================================
# COMPLETION & HISTORY
# ============================================

# Better history
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=10000
export HISTFILESIZE=10000
shopt -s histappend

# Update history after each command
export PROMPT_COMMAND="history -a; history -n"
