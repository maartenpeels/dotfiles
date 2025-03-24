#/!bin/bash

BASE_PACKAGES=(git stow fzf vim eza tmux)
FULL_PACKAGES=(zsh neovim)

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    if [ "$(uname)" == "Darwin" ]; then
        echo "Error: This script should not be run as root on macOS"
        echo "Homebrew should be run as a non-root user"
        exit 1
    fi
fi

# For Linux, ensure we have sudo if not root
if [ "$(uname)" == "Linux" ] && [ "$EUID" -ne 0 ]; then
    if ! command -v sudo >/dev/null 2>&1; then
        echo "Error: This script requires sudo on Linux"
        exit 1
    fi
fi

# Parse command line arguments
if [ $# -lt 1 ]; then
  echo "Usage: $0 <bare|full>"
  exit 1
fi

# Check if the type is valid
if [ "$1" != "bare" ] && [ "$1" != "full" ]; then
  echo "Error: Invalid type: $1. Valid types are: bare, full"
  exit 1
fi

# Set the type
TYPE=$1

# Detect the OS
OS=$(uname)

# Set the default package manager
if [ "$OS" == "Darwin" ]; then
  PACKAGE_MANAGER="brew"
elif [ "$OS" == "Linux" ]; then
  # Detect the distribution
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" == "ubuntu" ]; then
      PACKAGE_MANAGER="apt"
    else
      echo "Unsupported distribution: $ID"
      exit 1
    fi
  else
    echo "Error: /etc/os-release not found"
    exit 1
  fi
else
  echo "Unsupported OS: $OS"
  exit 1
fi

# Helper to check if a package is installed
is_installed() {
  if [ "$PACKAGE_MANAGER" == "brew" ]; then
    brew list -1 | grep "^$1\$" >/dev/null 2>&1
  elif [ "$PACKAGE_MANAGER" == "apt" ]; then
    dpkg -l | grep "^ii  $1 " >/dev/null 2>&1
  fi
}

# Install the required packages
echo "Installing required packages..."
if [ "$PACKAGE_MANAGER" == "brew" ]; then
  for package in "${BASE_PACKAGES[@]}"; do
    is_installed "$package" && echo "$package is already installed." || brew install "$package"
  done
  
  if [ "$TYPE" == "full" ]; then
    for package in "${FULL_PACKAGES[@]}"; do
      is_installed "$package" && echo "$package is already installed." || brew install "$package"
    done
  fi
elif [ "$PACKAGE_MANAGER" == "apt" ]; then
  sudo apt update
  for package in "${BASE_PACKAGES[@]}"; do
    is_installed "$package" && echo "$package is already installed." || sudo apt install -y "$package"
  done
  
  if [ "$TYPE" == "full" ]; then
    for package in "${FULL_PACKAGES[@]}"; do
      is_installed "$package" && echo "$package is already installed." || sudo apt install -y "$package"
    done
  fi
fi

# Install Oh-My-Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh-My-Zsh..."
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"

  # Install plugins
  echo "Installing Oh-My-Zsh plugins..."

  # Define plugins
  ZSH_ROOT="${ZSH_ROOT:-$HOME/.oh-my-zsh}"
  PLUGINS=(
    "zsh-autosuggestions"
    "zsh-syntax-highlighting"
    "powerlevel10k"
  )

  # Install custom plugins
  for plugin in "${PLUGINS[@]}"; do
    plugin_dir="$ZSH_ROOT/plugins/$plugin"
    theme_dir="$ZSH_ROOT/themes"
    
    case "$plugin" in
      "zsh-autosuggestions")
        if [ ! -d "$plugin_dir" ]; then
          echo "Installing $plugin..."
          git clone https://github.com/zsh-users/zsh-autosuggestions "$plugin_dir"
        fi
        ;;
      "zsh-syntax-highlighting")
        if [ ! -d "$plugin_dir" ]; then
          echo "Installing $plugin..."
          git clone https://github.com/zsh-users/zsh-syntax-highlighting "$plugin_dir"
        fi
        ;;
      "powerlevel10k")
        if [ ! -d "$theme_dir/powerlevel10k" ]; then
          echo "Installing $plugin..."
          git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme_dir/powerlevel10k"
        fi
        ;;
    esac
  done

  # Set the default shell to Zsh
  if [ "$OS" == "Darwin" ]; then
    sudo dscl . -create /Users/$USER UserShell /usr/local/bin/zsh
  elif [ "$OS" == "Linux" ]; then
    sudo chsh -s "$(command -v zsh)" "$USER"
  fi
  
  # Remove the default .zshrc
  rm -f "$HOME/.zshrc"
else
  echo "Oh-My-Zsh is already installed."
fi

# Install NerdFonts
if [ ! "$(fc-list | grep -i "JetBrainsMonoNL")" ]; then
  echo "Installing JetBrains Mono Nerd Font..."
  if [ "$OS" == "Darwin" ]; then
    brew install font-jetbrains-mono-nerd-font
  elif [ "$OS" == "Linux" ]; then
    wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip \
      && cd ~/.local/share/fonts \
      && unzip JetBrainsMono.zip \
      && rm JetBrainsMono.zip \
      && fc-cache -fv
  fi
else
  echo "JetBrains Mono Nerd Font is already installed."
fi

# Backup existing dotfiles
backup_dir="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
echo "Backing up existing dotfiles to $backup_dir"
mkdir -p "$backup_dir"

# set defaults
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}

# setup some directories
mkdir -p "$XDG_CONFIG_HOME"
mkdir -p "$HOME/.local/bin"

# Install the dotfiles
echo "Installing dotfiles..."
STOW_DIR="$HOME/dotfiles/dotfiles"
cd "$STOW_DIR" || exit 1

if [ "$TYPE" == "bare" ] || [ "$TYPE" == "full" ]; then
  stow -v -t "$HOME" git
  stow -v -t "$HOME" zsh
  stow -v -t "$HOME" tmux
fi

if [ "$TYPE" == "full" ]; then
  stow -v -t "$HOME" nvim
  stow -v -t "$HOME" p10k
fi
