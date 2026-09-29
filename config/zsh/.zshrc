# Powerlevel10k instant prompt. Keep close to the top.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

exists() { command -v "$1" &>/dev/null }
source_if_exists() { [[ -r "$1" ]] && source "$1" }

# Homebrew (macOS arm/intel, Linuxbrew) - sets PATH, MANPATH etc.
for brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [[ -x $brew ]] && { eval "$($brew shellenv)"; break }
done
unset brew

# Path
typeset -U path  # dedupe
path=("$HOME/.local/bin" "$HOME/.config/git/commands" "$HOME/go/bin" $path)
export GOBIN="$HOME/go/bin"

# oh-my-zsh - theme and custom plugins are cloned into $ZSH_CUSTOM by packages/oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
DISABLE_AUTO_UPDATE=true
ZSH_DISABLE_COMPFIX=true
zstyle ':omz:plugins:nvm' lazy yes
plugins=(
  git
  nvm                      # no-op when nvm isn't installed
  zsh-autosuggestions
  zsh-syntax-highlighting  # must be last
)
source "$ZSH/oh-my-zsh.sh"

source_if_exists "$HOME/.p10k.zsh"

# Locale / terminal
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export COLORTERM=truecolor

# Tool integrations - each only if the tool is installed
exists mise      && eval "$(mise activate zsh)"
exists fzf       && source <(fzf --zsh 2>/dev/null)
exists direnv    && eval "$(direnv hook zsh 2>/dev/null)"
exists terraform && { autoload -U +X bashcompinit && bashcompinit; complete -o nospace -C "$(command -v terraform)" terraform }

# Aliases / functions

## Enhanced ls: eza if available, otherwise coloured ls (replaces oh-my-zsh's ls alias)
unalias ls 2>/dev/null
function ls() {
  if exists eza; then
    eza --icons --git --ignore-glob='**/.git' --time-style=long-iso --group-directories-first -a "$@"
  elif [[ $OSTYPE == darwin* ]]; then
    command ls --color=auto -v -h -a "$@"
  else
    command ls --color=auto -v -h -a --group-directories-first "$@"
  fi
}

## cd also lists and pushes onto the dir stack; `..` goes back
function cd() { builtin cd "$@" && ls && pushd -q . }
alias ..='popd &>/dev/null && ls'

# Machine-specific config (not in the repo): SDK paths, installer-added lines, secrets
source_if_exists "$HOME/.zshrc.local"
