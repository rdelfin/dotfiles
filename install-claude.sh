#!/usr/bin/env bash
# Symlink the tracked Claude Code config in ./claude into ~/.claude.
# Top-level files are linked as-is. For skills/, commands/ and agents/,
# each child is linked, so tools can still add their own entries there.
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/claude"
DEST_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
BACKUP_SUFFIX=".bak.$(date +%Y%m%d%H%M%S)"

link() {
    local src="$1" dest="$2"
    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
        echo "ok      $dest"
        return
    fi
    if [[ -e "$dest" || -L "$dest" ]]; then
        mv "$dest" "$dest$BACKUP_SUFFIX"
        echo "backup  $dest -> $dest$BACKUP_SUFFIX"
    fi
    ln -s "$src" "$dest"
    echo "link    $dest -> $src"
}

mkdir -p "$DEST_DIR"

for entry in "$SRC_DIR"/*; do
    name="$(basename "$entry")"
    if [[ -d "$entry" ]]; then
        mkdir -p "$DEST_DIR/$name"
        for child in "$entry"/*; do
            [[ -e "$child" ]] || continue
            link "$child" "$DEST_DIR/$name/$(basename "$child")"
        done
    else
        link "$entry" "$DEST_DIR/$name"
    fi
done
