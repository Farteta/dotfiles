# PATH
export PATH="$HOME/.local/bin:$PATH"

# Editor
export EDITOR="nvim"
export VISUAL="nvim"

# Autosuggestions (gray inline hints)
if [[ "$OSTYPE" == "darwin"* ]]; then
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
else
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null || \
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null || \
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
fi

# Starship prompt
eval "$(starship init zsh)"

# Welcome message (comment out if you don't want it every time)
command -v fastfetch &>/dev/null && fastfetch

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY          # Share history between sessions
setopt HIST_IGNORE_DUPS       # Don't record duplicates
setopt HIST_IGNORE_SPACE      # Ignore commands starting with space
setopt HIST_REDUCE_BLANKS     # Remove extra blanks
setopt HIST_VERIFY            # Show command before running from history

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select  # Interactive menu for completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"  # Colorful completion

# Better cd
setopt AUTO_CD
setopt AUTO_PUSHD            # Make cd push old directory onto stack
setopt PUSHD_IGNORE_DUPS     # Don't push duplicates
setopt PUSHD_SILENT          # Don't print directory stack

# Navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Quick access
alias g='git'
alias c='clear'
alias zshconfig='nvim ~/.zshrc'
alias kittyconfig='nvim ~/.config/kitty/kitty.conf'
alias dotfiles='cd ~/dotfiles'

# Better ls with eza
alias ls='eza --icons'
alias ll='eza -lah --icons --git'
alias lt='eza --tree --level=2 --icons'
alias la='eza -a --icons'

# Better cat with bat
alias cat='bat --style=auto'
alias bathelp='bat --plain --language=help'  # Better help pages
help() {
    "$@" --help 2>&1 | bathelp
}

# Git aliases (since you use 'g')
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias glog='git log --oneline --graph --decorate'

# Directory jumping with zoxide
eval "$(zoxide init zsh)"
alias cd='z'  # Replace cd with zoxide

# fzf fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# Better fzf defaults with bat preview
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --color=always --style=numbers --line-range=:500 {}'"

# Quick reload
alias reload='source ~/.zshrc'

# Auto-activate Python virtual environments
# export VIRTUAL_ENV_DISABLE_PROMPT=1
