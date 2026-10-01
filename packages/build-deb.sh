#!/usr/bin/env bash
# Build a .deb from a package source directory: build-deb.sh <package-dir> [output-dir]
set -euo pipefail

PACKAGE_DIR="$(cd "${1:?usage: build-deb.sh <package-dir> [output-dir]}" && pwd)"
OUTPUT_DIR="${2:-$(dirname "${BASH_SOURCE[0]}")/../build}"
mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"

STAGING_DIR="$(mktemp -d)"
trap 'rm -rf "$STAGING_DIR"' EXIT
cp -a "$PACKAGE_DIR/." "$STAGING_DIR/"

# Normalise modes: git and the umask do not give the modes a package needs.
chmod -R u=rwX,go=rX "$STAGING_DIR"
chmod 0755 "$STAGING_DIR"/DEBIAN/{preinst,postinst,prerm,postrm} 2>/dev/null || true
find "$STAGING_DIR/usr/libexec" "$STAGING_DIR/usr/share/regolith-compositor" \
    -type f -exec chmod 0755 {} +

dpkg-deb --root-owner-group --build "$STAGING_DIR" "$OUTPUT_DIR"
