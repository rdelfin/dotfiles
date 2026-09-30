#!/usr/bin/env bash
# Set up a fresh machine from this repo. Safe to run more than once.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_SRC_DIR="$REPO_DIR/claude"
CLAUDE_DEST_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
OH_MY_ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
OH_MY_ZSH_REPO="https://github.com/ohmyzsh/ohmyzsh.git"
BACKUP_SUFFIX=".bak.$(date +%Y%m%d%H%M%S)"
REQUIRED_COMMANDS=(git zsh tmux pipx)

require_commands() {
    local missing=()
    for cmd in "${REQUIRED_COMMANDS[@]}"; do
        command -v "$cmd" >/dev/null || missing+=("$cmd")
    done
    if ((${#missing[@]})); then
        echo "Missing commands: ${missing[*]}" >&2
        echo "Install them first, e.g.: sudo apt install git zsh tmux pipx" >&2
        exit 1
    fi
}

backup_if_present() {
    local path="$1"
    if [[ -e "$path" || -L "$path" ]]; then
        mv "$path" "$path$BACKUP_SUFFIX"
        echo "backup  $path -> $path$BACKUP_SUFFIX"
    fi
}

link() {
    local src="$1" dest="$2"
    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
        echo "ok      $dest"
        return
    fi
    backup_if_present "$dest"
    ln -s "$src" "$dest"
    echo "link    $dest -> $src"
}

copy_file() {
    local src="$1" dest="$2"
    if [[ -f "$dest" && ! -L "$dest" ]] && cmp -s "$src" "$dest"; then
        echo "ok      $dest"
        return
    fi
    backup_if_present "$dest"
    cp "$src" "$dest"
    echo "copy    $src -> $dest"
}

install_shell_configs() {
    copy_file "$REPO_DIR/zshrc" "$HOME/.zshrc"
    copy_file "$REPO_DIR/tmux.conf" "$HOME/.tmux.conf"
}

install_oh_my_zsh() {
    if [[ -d "$OH_MY_ZSH_DIR" ]]; then
        echo "ok      $OH_MY_ZSH_DIR"
        return
    fi
    git clone --depth 1 "$OH_MY_ZSH_REPO" "$OH_MY_ZSH_DIR"
}

install_powerline() {
    if pipx list --short | grep -q '^powerline-status '; then
        echo "ok      powerline-status"
        return
    fi
    pipx install powerline-status
}

# Top-level files are linked as-is. For skills/, commands/ and agents/,
# each child is linked, so tools can still add their own entries there.
install_claude_config() {
    mkdir -p "$CLAUDE_DEST_DIR"
    local entry name child
    for entry in "$CLAUDE_SRC_DIR"/*; do
        name="$(basename "$entry")"
        if [[ -d "$entry" ]]; then
            mkdir -p "$CLAUDE_DEST_DIR/$name"
            for child in "$entry"/*; do
                [[ -e "$child" ]] || continue
                link "$child" "$CLAUDE_DEST_DIR/$name/$(basename "$child")"
            done
        else
            link "$entry" "$CLAUDE_DEST_DIR/$name"
        fi
    done
}

require_commands
install_oh_my_zsh
install_powerline
install_shell_configs
install_claude_config
