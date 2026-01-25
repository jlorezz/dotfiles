#!/usr/bin/env bash
set -e

DOTFILES="$HOME/dev/personal/dotfiles"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Auto-detect Windows username from WSL
WINDOWS_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r' || echo "")

# Prerequisite checks
command -v stow >/dev/null || { echo "Error: stow not installed. Run: sudo apt install stow"; exit 1; }

# Install oh-my-zsh plugins
install_zsh_plugins() {
    local plugins_dir="$ZSH_CUSTOM/plugins"
    mkdir -p "$plugins_dir"

    if [[ ! -d "$plugins_dir/zsh-autosuggestions" ]]; then
        echo "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$plugins_dir/zsh-autosuggestions"
    else
        echo "zsh-autosuggestions already installed"
    fi

    if [[ ! -d "$plugins_dir/zsh-syntax-highlighting" ]]; then
        echo "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$plugins_dir/zsh-syntax-highlighting"
    else
        echo "zsh-syntax-highlighting already installed"
    fi
}

# WSL only - goes to ~/.config
CONFIG_PACKAGES=(atuin nushell nvim starship tmux)

# WSL only - goes to ~/
HOME_PACKAGES=(zsh claude)

# Windows only - symlink to Windows .config
WINDOWS_PACKAGES=(wezterm)

echo "Setting up dotfiles..."
mkdir -p ~/.config

# Install zsh plugins first
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    install_zsh_plugins
else
    echo "Warning: oh-my-zsh not found. Install it first: https://ohmyz.sh/"
fi

# Stow to ~/.config
echo ""
echo "Stowing config packages to ~/.config..."
for pkg in "${CONFIG_PACKAGES[@]}"; do
    echo "  - $pkg"
    stow -d "$DOTFILES" -t ~/.config "$pkg"
done

# Stow to ~/
echo ""
echo "Stowing home packages to ~..."
for pkg in "${HOME_PACKAGES[@]}"; do
    echo "  - $pkg"
    stow -d "$DOTFILES" -t ~ "$pkg"
done

# Create Windows symlinks (requires admin PowerShell)
if [[ -n "$WINDOWS_USER" ]]; then
    WINDOWS_CONFIG="/mnt/c/Users/$WINDOWS_USER/.config"

    echo ""
    echo "For Windows apps, run these in an Admin PowerShell:"
    for pkg in "${WINDOWS_PACKAGES[@]}"; do
        if [[ ! -L "$WINDOWS_CONFIG/$pkg" && ! -d "$WINDOWS_CONFIG/$pkg" ]]; then
            echo "New-Item -ItemType SymbolicLink -Path \"\$env:USERPROFILE\\.config\\$pkg\" -Target \"\\\\wsl\$\\Ubuntu\\home\\$USER\\dev\\personal\\dotfiles\\$pkg\""
        else
            echo "# $pkg already exists"
        fi
    done
else
    echo ""
    echo "Warning: Could not detect Windows username. Skipping Windows package instructions."
fi

echo ""
echo "Done! Open a new terminal to apply changes."
