# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Dotfiles profile (work | personal), written by setup.sh
DOTFILES_PROFILE="$(cat ~/.config/dotfiles/profile 2>/dev/null || echo personal)"

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)
[[ "$DOTFILES_PROFILE" == work ]] && plugins+=(kubectl)
source $ZSH/oh-my-zsh.sh

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Go
export GOPATH=$(go env GOPATH)
export PATH="$HOME/go/bin:$PATH"

# Paths
export PATH="$HOME/.local/bin:$PATH"

# Aliases
alias projects='cd ~/workspace/projects'

claude() {
  ~/dotfiles/claude/sync-settings.sh
  command claude --dangerously-skip-permissions "$@"
}

# Editor
export EDITOR=nvim

# Profile-specific config
[[ ! -f ~/dotfiles/zsh/$DOTFILES_PROFILE.zsh ]] || source ~/dotfiles/zsh/$DOTFILES_PROFILE.zsh

# Machine-local config and secrets (API keys etc.) — not tracked in the repo
[[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local

# p10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
