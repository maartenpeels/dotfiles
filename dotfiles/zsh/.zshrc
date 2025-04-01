export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
        git
)

source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Path
export PATH="$HOME/bin:/usr/local/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.tmux/plugins/:$PATH"
export PATH="$HOME/.config/git/commands:$PATH"

# Set locale to UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Set terminal to support 256 colors
export COLORTERM=truecolor

# Function to source plugin if it exists
source_if_exists() {
    if [ -f "$1" ]; then
        source "$1"
    fi
}

# Define paths based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS paths
    BREW_PREFIX=$(brew --prefix)
    P10K_THEME="$BREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme"
    SYNTAX_HIGHLIGHT="$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    AUTOSUGGESTIONS="$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
else
    # Linux paths
    P10K_THEME="/usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme"
    SYNTAX_HIGHLIGHT="/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    AUTOSUGGESTIONS="/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Source plugins
source_if_exists "$P10K_THEME"
source_if_exists "$SYNTAX_HIGHLIGHT"
source_if_exists "$AUTOSUGGESTIONS"

# FZF
if command -v fzf 2>/dev/null; then
	source <(fzf --zsh)
fi

if command -v direnv 2>/dev/null; then
	eval "$(direnv hook zsh)"
fi

# ZSH autocomplete
autoload -Uz compinit
compinit

# Helpful functions

## Check if a command exists
function exists() {
  command -v $1 &>/dev/null
  return $?
}

# Aliases

## Go back to the previous directory and ls
alias ..='popd &>/dev/null && ls'

## Enhanced ls command with eza or fallback to ls with color
function ls() {
  if exists eza; then
    eza --icons --git --ignore-glob='**/.git' --time-style=long-iso --group-directories-first -a $@
  elif [ $(uname) == "Darwin" ]; then
    command ls --color=auto -v -h -a -I .. -I . -I .git $@
  else
    command ls --color=auto -v -h -a -I .. -I . -I .git --group-directories-first $@
  fi
}

## Enhanced cd command that also runs ls and pushes directory to stack
## Go back to the previous directory with `..`
cd() {
  builtin cd "$@" && ls
  if [ $? -eq 0 ]; then
    pushd .
  fi
}
