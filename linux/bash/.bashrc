# shellcheck shell=bash
# shellcheck disable=SC2034

# If not running interactively, don't do anything
case $- in
	*i*) ;;
	*) return ;;
esac

# Path to the bash it configuration
BASH_IT="$HOME/.bash_it"

# Check if bash-it is installed
if [ ! -d "$BASH_IT" ]; then
    echo "Warning: bash-it not installed. Run ./install-packages-proxmox-debian.sh first."
    echo "Continuing with basic bash configuration..."
    BASH_IT_INSTALLED=false
else
    BASH_IT_INSTALLED=true
    # Lock and Load a custom theme file.
    # Leave empty to disable theming.
    # location "$BASH_IT"/themes/
    export BASH_IT_THEME='bobby'
fi

# Some themes can show whether `sudo` has a current token or not.
# Set `$THEME_CHECK_SUDO` to `true` to check every prompt:
#THEME_CHECK_SUDO='true'

# (Advanced): Change this to the name of your remote repo if you
# cloned bash-it with a remote other than origin such as `bash-it`.
#BASH_IT_REMOTE='bash-it'

# (Advanced): Change this to the name of the main development branch if
# you renamed it or if it was changed for some reason
#BASH_IT_DEVELOPMENT_BRANCH='master'

# Your place for hosting Git repos. I use this for private repos.
#GIT_HOSTING='git@git.domain.com'

# Don't check mail when opening terminal.
unset MAILCHECK

# Change this to your console based IRC client of choice.
export IRC_CLIENT='irssi'

# Set this to the command you use for todo.txt-cli
TODO="t"

# Set this to the location of your work or project folders
#BASH_IT_PROJECT_PATHS="${HOME}/Projects:/Volumes/work/src"

# Set this to false to turn off version control status checking within the prompt for all themes
#SCM_CHECK=true

# Set to actual location of gitstatus directory if installed
#SCM_GIT_GITSTATUS_DIR="$HOME/gitstatus"
# per default gitstatus uses 2 times as many threads as CPU cores, you can change this here if you must
#export GITSTATUS_NUM_THREADS=8

# If your theme use command duration, uncomment this to
# enable display of last command duration.
#BASH_IT_COMMAND_DURATION=true
# You can choose the minimum time in seconds before
# command duration is displayed.
#COMMAND_DURATION_MIN_SECONDS=1

# Set Xterm/screen/Tmux title with shortened command and directory.
# Uncomment this to set.
#SHORT_TERM_LINE=true

# Set vcprompt executable path for scm advance info in prompt (demula theme)
# https://github.com/djl/vcprompt
#VCPROMPT_EXECUTABLE=~/.vcprompt/bin/vcprompt

# (Advanced): Uncomment this to make Bash-it reload itself automatically
# after enabling or disabling aliases, plugins, and completions.
# BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1

# Uncomment this to make Bash-it create alias reload.
# BASH_IT_RELOAD_LEGACY=1

# Load Bash It (if installed)
if [ "$BASH_IT_INSTALLED" = true ]; then
    source "$BASH_IT/bash_it.sh"
fi

# ============================================
# CUSTOM CONFIGURATION (add at the end)
# ============================================

# Fix terminal type for SSH from Kitty
if [[ "$TERM" == "xterm-kitty" ]]; then
    export TERM=xterm-256color
fi

# PATH - ensure local bins are available
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

# Editor
export EDITOR="micro"
export VISUAL="micro"

# Starship prompt (replaces bash-it theme if both installed)
if command -v starship &>/dev/null; then
    if [ "$BASH_IT_INSTALLED" = true ]; then
        export BASH_IT_THEME=''  # Disable bash-it theme
    fi
    eval "$(starship init bash)"
fi

# Welcome message
command -v fastfetch &>/dev/null && fastfetch

# Navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Quick access
alias g='git'
alias c='clear'
alias bashconfig='micro ~/.bashrc'
alias dotfiles='cd ~/dotfiles'

# Better ls with eza
if command -v eza &>/dev/null; then
    alias ls='eza --icons'
    alias ll='eza -lah --icons --git'
    alias lt='eza --tree --level=2 --icons'
    alias la='eza -a --icons'
else
    alias ls='ls --color=auto'
    alias ll='ls -lah --color=auto'
    alias la='ls -a --color=auto'
fi

# Better cat with bat
if command -v batcat &>/dev/null; then
    alias bat='batcat'
    alias cat='batcat --style=auto'
fi

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias glog='git log --oneline --graph --decorate'

# Directory jumping with zoxide
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash)"
    alias cd='z'
fi

# fzf fuzzy finder
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Quick reload
alias reload='source ~/.bashrc'
