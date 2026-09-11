#!/usr/bin/env bash
# Merges dotfiles/claude/settings.json into the live ~/.claude/settings.json.
#
# Not a symlink: Claude Code replaces symlinks with real files whenever it
# writes settings (e.g. /config, UI toggles), which silently drops anything
# not in that write (most notably "model"). Instead we merge on every
# `claude` invocation: dotfiles values win on key conflicts, but any key the
# live file has picked up that dotfiles doesn't know about (e.g. attribution
# tweaks made via /config) is preserved rather than clobbered.
set -euo pipefail

DOTFILES_SETTINGS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/settings.json"
LIVE_SETTINGS="$HOME/.claude/settings.json"

mkdir -p "$HOME/.claude"

if [[ ! -f "$LIVE_SETTINGS" ]]; then
  cp "$DOTFILES_SETTINGS" "$LIVE_SETTINGS"
  exit 0
fi

merged=$(jq -s '.[0] * .[1]' "$LIVE_SETTINGS" "$DOTFILES_SETTINGS")
printf '%s\n' "$merged" > "$LIVE_SETTINGS.tmp"
mv "$LIVE_SETTINGS.tmp" "$LIVE_SETTINGS"
