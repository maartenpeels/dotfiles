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
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="$HOME/.tmux/plugins/:$PATH"

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
