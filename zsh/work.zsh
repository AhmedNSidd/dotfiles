# Work profile — sourced by zshrc when ~/.config/dotfiles/profile is "work"

unalias kl 2>/dev/null  # use robinovitch61/kl instead of kubectl logs

# Load SSH keys
ssh-add --apple-use-keychain ~/.ssh/nregit 2>/dev/null

# Zscaler cert for Node.js
export NODE_EXTRA_CA_CERTS=~/.certs/Zscaler_Root_CA.crt

# Java
export JAVA_HOME="/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"
