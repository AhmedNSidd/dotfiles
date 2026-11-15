#!/bin/bash
set -e

DOTFILES_DIR="$HOME/dotfiles"
PROFILE_FILE="$HOME/.config/dotfiles/profile"

# Profile: work | personal. Taken from the first argument, else the profile
# saved by a previous run.
PROFILE="${1:-$(cat "$PROFILE_FILE" 2>/dev/null || true)}"
case "$PROFILE" in
  work|personal) ;;
  *) echo "Usage: $0 <work|personal>" >&2; exit 1 ;;
esac
echo "==> Profile: $PROFILE"
mkdir -p "$(dirname "$PROFILE_FILE")"
echo "$PROFILE" > "$PROFILE_FILE"

# Several casks (and --adopt) need sudo. Ask once up front and keep the
# credential alive for the rest of the run so nothing stalls mid-install.
if [ ! -t 0 ]; then
  echo "setup.sh needs an interactive terminal for sudo; run it from Ghostty/Terminal." >&2
  exit 1
fi
echo "==> Requesting sudo (needed by some casks)..."
sudo -v
while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &

echo "==> Installing Homebrew..."
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "    Homebrew already installed."
fi

echo "==> Adopting manually-installed apps into Homebrew..."
# brew bundle errors on casks whose .app already exists but wasn't installed
# by brew; --adopt takes ownership of the existing app instead.
adopt_cask() {
  local cask="$1" app="$2"
  if [ -d "/Applications/$app" ] && ! brew list --cask "$cask" &>/dev/null; then
    brew install --cask --adopt "$cask"
  fi
}
adopt_cask 1password "1Password.app"
adopt_cask ghostty   "Ghostty.app"

echo "==> Running brew bundle..."
brew bundle --file="$DOTFILES_DIR/Brewfile"
brew bundle --file="$DOTFILES_DIR/Brewfile.$PROFILE"

echo "==> Installing oh-my-zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
else
  echo "    oh-my-zsh already installed."
fi

echo "==> Linking powerlevel10k theme..."
mkdir -p "$HOME/.oh-my-zsh/custom/themes"
ln -sfn "$(brew --prefix)/opt/powerlevel10k/share/powerlevel10k" "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"

echo "==> Setting up symlinks..."
mkdir -p "$HOME/.config"
ln -sfn "$DOTFILES_DIR/nvim"         "$HOME/.config/nvim"
ln -sfn "$DOTFILES_DIR/ghostty"      "$HOME/.config/ghostty"
ln -sfn "$DOTFILES_DIR/karabiner"    "$HOME/.config/karabiner"
ln -sfn "$DOTFILES_DIR/kitty"        "$HOME/.config/kitty"
ln -sfn "$DOTFILES_DIR/hammerspoon"  "$HOME/.hammerspoon"
ln -sf  "$DOTFILES_DIR/p10k.zsh"     "$HOME/.p10k.zsh"
ln -sf  "$DOTFILES_DIR/vimrc"        "$HOME/.vimrc"

# settings.json is merged into place, not symlinked — ~/.claude also holds
# runtime state (history, sessions, projects) that must not enter the repo,
# and Claude Code replaces symlinks with real files when it writes settings.
# See claude/sync-settings.sh; the `claude` shell function re-runs this merge
# on every launch so drift self-heals.
"$DOTFILES_DIR/claude/sync-settings.sh"

echo "==> Configuring git..."
git config --global user.name "Ahmed Siddiqui"
if [ "$PROFILE" = work ]; then
  GIT_EMAIL="ahsiddiqui@equinix.com"
else
  GIT_EMAIL="jesuisahmedn@gmail.com"
fi
git config --global user.email "$GIT_EMAIL"

echo "==> Writing SSH config..."
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [ "$PROFILE" = work ]; then
  for key in github nregit; do
    if [ ! -f "$HOME/.ssh/$key" ]; then
      ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$HOME/.ssh/$key" -N ""
      echo "    $key key generated."
    else
      echo "    $key key already exists."
    fi
  done
  cat > "$HOME/.ssh/config" << 'SSHEOF'
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
SSHEOF
else
  # Personal: keys live in 1Password, nothing on disk.
  cat > "$HOME/.ssh/config" << 'SSHEOF'
Host *
  IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
SSHEOF
fi
chmod 600 "$HOME/.ssh/config"

echo "==> Adding GitHub to known_hosts..."
touch "$HOME/.ssh/known_hosts"
if ! ssh-keygen -F github.com -f "$HOME/.ssh/known_hosts" &>/dev/null; then
  ssh-keyscan github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null || true
fi

echo "==> Linking .zshrc..."
ln -sf "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
touch "$HOME/.zshrc.local"

echo ""
echo "==> Done ($PROFILE)! Next steps:"
if [ "$PROFILE" = work ]; then
  echo "    1. Add SSH keys to GitHub and nregit:"
  echo "       cat ~/.ssh/github.pub"
  echo "       cat ~/.ssh/nregit.pub"
  echo "    2. Install the Zscaler root cert to ~/.certs/Zscaler_Root_CA.crt"
else
  echo "    1. 1Password > Settings > Developer: enable 'Use the SSH agent'."
  echo "       Create/import an SSH key in 1Password and add its public key to"
  echo "       https://github.com/settings/keys, then test: ssh -T git@github.com"
  echo "    2. Put API keys / machine-local exports in ~/.zshrc.local"
fi
echo "    3. Open a new terminal to load .zshrc"
echo "    4. Install UHF manually from the Mac App Store"
echo "    5. Launch Bluesnooze and enable 'Start Bluesnooze at login'"
