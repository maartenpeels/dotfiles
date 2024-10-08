HOME_DOTFILES := .vim
CONFIG_DOTFILES := .tmux

# Get the operating system name
UNAME_S := $(shell uname -s)

.PHONY: help
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  install           Install packages for macOS or Linux"
	@echo "  link              Use stow to symlink dotfiles to the home directory and ~/.config"
	@echo "  clean             Unlink dotfiles"

.PHONY: all
all: install link

# Install packages for macOS or Linux
.PHONY: install
install:
	@if [ "$(UNAME_S)" = "Darwin" ]; then \
		echo "Installing packages for macOS..."; \
		if ! command -v brew >/dev/null; then \
			echo "Homebrew not found. Installing Homebrew..."; \
			/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		fi; \
		brew install git stow vim; \
	elif [ "$(UNAME_S)" = "Linux" ]; then \
		echo "Installing packages for Linux..."; \
		sudo apt-get update; \
		sudo apt-get install -y git stow vim curl; \
	fi

# Install Vim plugins
.PHONY: install_vim_plugins
install_vim_plugins:
	@echo "Installing Vim plugins..."
	@vim +PlugInstall +qall

# Install Tmux plugins
.PHONY: install_tmux_plugins
install_tmux_plugins:
	@echo "Installing Tmux plugins..."
	@~/.tmux/plugins/tpm/bin/install_plugins

# Use stow to symlink dotfiles to the home directory and ~/.config
.PHONY: link
link: link_home link_config install_vim_plugins install_tmux_plugins 

# Symlink dotfiles for home directory (e.g., ~/.zshrc)
.PHONY: link_home
link_home:
	@echo "Linking dotfiles for home directory..."
	@if [ -n "$(strip $(HOME_DOTFILES))" ]; then \
		stow --adopt $(HOME_DOTFILES); \
	fi
	@git reset --hard

# Symlink dotfiles for ~/.config directory (e.g., ~/.config/nvim)
.PHONY: link_config
link_config:
	@echo "Linking dotfiles for ~/.config..."
	@if [ -n "$(strip $(CONFIG_DOTFILES))" ]; then \
		mkdir -p ~/.config; \
		stow --adopt --target=$(HOME)/.config $(CONFIG_DOTFILES); \
	fi
	@git reset --hard

# Unlink dotfiles
.PHONY: clean
clean:
	@echo "Unlinking dotfiles..."
	@if [ -n "$(strip $(HOME_DOTFILES))" ]; then \
		stow -D $(HOME_DOTFILES); \
	fi
	@if [ -n "$(strip $(CONFIG_DOTFILES))" ]; then \
		stow -D --target=$(HOME)/.config $(CONFIG_DOTFILES); \
	fi