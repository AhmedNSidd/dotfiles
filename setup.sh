#!/bin/bash
set -e

DOTFILES_DIR="$HOME/dotfiles"

echo "==> Installing Homebrew..."
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "    Homebrew already installed."
fi

echo "==> Running brew bundle..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

echo "==> Installing kl..."
go install github.com/robinovitch61/kl@latest

echo "==> Installing oh-my-zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "    oh-my-zsh already installed."
fi

echo "==> Setting up symlinks..."
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES_DIR/nvim"         "$HOME/.config/nvim"
ln -sf "$DOTFILES_DIR/ghostty"      "$HOME/.config/ghostty"
ln -sf "$DOTFILES_DIR/kitty"        "$HOME/.config/kitty"
ln -sf "$DOTFILES_DIR/hammerspoon"  "$HOME/.hammerspoon"
ln -sf "$DOTFILES_DIR/p10k.zsh"     "$HOME/.p10k.zsh"
ln -sf "$DOTFILES_DIR/vimrc"        "$HOME/.vimrc"

echo "==> Generating SSH keys..."
mkdir -p "$HOME/.ssh"
if [ ! -f "$HOME/.ssh/github" ]; then
  ssh-keygen -t ed25519 -C "ahsiddiqui@equinix.com" -f "$HOME/.ssh/github" -N ""
  echo "    GitHub key generated. Add to: https://github.com/settings/keys"
else
  echo "    GitHub key already exists."
fi
if [ ! -f "$HOME/.ssh/nregit" ]; then
  ssh-keygen -t ed25519 -C "ahsiddiqui@equinix.com" -f "$HOME/.ssh/nregit" -N ""
  echo "    nregit key generated."
else
  echo "    nregit key already exists."
fi

echo "==> Writing SSH config..."
cat > "$HOME/.ssh/config" << 'EOF'
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/github

Host nregit.corp.equinix.com
  HostName nregit.corp.equinix.com
  User gitea
  IdentityFile ~/.ssh/nregit
  IdentitiesOnly yes

Host *
  IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
EOF
chmod 600 "$HOME/.ssh/config"

echo "==> Adding GitHub to known_hosts..."
ssh-keyscan github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null

echo "==> Writing .zshrc..."
cat > "$HOME/.zshrc" << 'ZSHRC'
# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Load SSH keys
ssh-add --apple-use-keychain ~/.ssh/nregit 2>/dev/null

# Go
export GOPATH=$(go env GOPATH)
export PATH="$HOME/go/bin:$PATH"

# Paths
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/Users/ahsiddiqui/.claude/local"

# Zscaler cert for Node.js
export NODE_EXTRA_CA_CERTS=~/.certs/Zscaler_Root_CA.crt

# API Keys
export TAVILY_API_KEY="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"

# Editor
export EDITOR=nvim

# p10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
ZSHRC

echo ""
echo "==> Done! Next steps:"
echo "    1. Add SSH keys to GitHub and nregit:"
echo "       cat ~/.ssh/github.pub"
echo "       cat ~/.ssh/nregit.pub"
echo "    2. Open a new terminal to load .zshrc"
echo "    3. Install UHF manually from the Mac App Store"
