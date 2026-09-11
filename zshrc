# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git kubectl)
source $ZSH/oh-my-zsh.sh
unalias kl 2>/dev/null  # use robinovitch61/kl instead of kubectl logs

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

# Aliases
alias projects='cd ~/workspace/projects'

claude() {
  ~/dotfiles/claude/sync-settings.sh
  command claude --dangerously-skip-permissions "$@"
}

# Editor
export EDITOR=nvim

# p10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export JAVA_HOME="/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"
