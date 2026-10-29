#!/usr/bin/env bash
# Set up a fresh machine from this repo. Safe to run more than once.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_SRC_DIR="$REPO_DIR/claude"
CLAUDE_DEST_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
OH_MY_ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
OH_MY_ZSH_REPO="https://github.com/ohmyzsh/ohmyzsh.git"
BACKUP_SUFFIX=".bak.$(date +%Y%m%d%H%M%S)"
REQUIRED_APT_COMMANDS=(git zsh tmux pipx)
REQUIRED_CARGO_COMMANDS=(wpaperd)
PICOM_PACKAGE_DIR="$REPO_DIR/packages/picom-autowakeup"
PICOM_PACKAGE_NAME="picom-autowakeup"
REGOLITH_COMPOSITOR_PACKAGE="regolith-compositor-picom-glx"
BUILD_DIR="$REPO_DIR/build"

require_commands() {
  local missing_apt=() missing_cargo=() cmd
  for cmd in "${REQUIRED_APT_COMMANDS[@]}"; do
    command -v "$cmd" >/dev/null || missing_apt+=("$cmd")
  done
  for cmd in "${REQUIRED_CARGO_COMMANDS[@]}"; do
    command -v "$cmd" >/dev/null || missing_cargo+=("$cmd")
  done
  if ((${#missing_apt[@]})); then
    echo "Missing commands: ${missing_apt[*]}" >&2
    echo "Install them first, e.g.: sudo apt install ${missing_apt[*]}" >&2
  fi
  if ((${#missing_cargo[@]})); then
    echo "Missing commands: ${missing_cargo[*]}" >&2
    echo "Install Rust (https://rustup.rs), then run:" >&2
    echo "  sudo apt install pkg-config libwayland-dev libegl-dev libdav1d-dev" >&2
    echo "  cargo install --locked ${missing_cargo[*]}" >&2
  fi
  if ((${#missing_apt[@]} + ${#missing_cargo[@]})); then
    exit 1
  fi
}

create_folders_if_missing() {
  local folder="$1"
  if [[ ! -d "$folder" ]]; then
    mkdir -p "$folder"
    echo "mkdir   $folder"
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

install_regolith_configs() {
  create_folders_if_missing "$HOME/.config/regolith3"
  create_folders_if_missing "$HOME/.config/regolith3/i3status-rust"
  create_folders_if_missing "$HOME/.config/regolith3/sway/config.d"
  create_folders_if_missing "$HOME/.config/wpaperd"

  link "$REPO_DIR/regolith/Xresources" "$HOME/.config/regolith3/Xresources"
  link "$REPO_DIR/regolith/i3status-rust/config.toml" "$HOME/.config/regolith3/i3status-rust/config.toml"
  link "$REPO_DIR/regolith/sway/config.d/80_swaybg" "$HOME/.config/regolith3/sway/config.d/80_swaybg"
  link "$REPO_DIR/regolith/sway/config.d/90_wpaperd" "$HOME/.config/regolith3/sway/config.d/90_wpaperd"
  link "$REPO_DIR/wpaperd/config.toml" "$HOME/.config/wpaperd/config.toml"
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

# Needs sudo. Only applies to machines that run Regolith.
install_picom_package() {
  if ! dpkg -s "$REGOLITH_COMPOSITOR_PACKAGE" >/dev/null 2>&1; then
    echo "skip    $PICOM_PACKAGE_NAME ($REGOLITH_COMPOSITOR_PACKAGE is not installed)"
    return
  fi
  rm -f "$BUILD_DIR/${PICOM_PACKAGE_NAME}_"*.deb
  "$REPO_DIR/packages/build-deb.sh" "$PICOM_PACKAGE_DIR" "$BUILD_DIR"
  sudo apt-get install -y --reinstall "$BUILD_DIR/${PICOM_PACKAGE_NAME}_"*_all.deb
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
install_picom_package
install_claude_config
install_regolith_configs
