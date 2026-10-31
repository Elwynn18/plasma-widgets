# SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Shared helpers, sourced by the other scripts.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLASMOIDS_DIR="$REPO_ROOT/plasmoids"

die() { echo "error: $*" >&2; exit 1; }

# widget_dir <name> -> prints the absolute path of plasmoids/<name>
widget_dir() {
    local name="${1:-}"
    [[ -n "$name" ]] || die "missing widget name (available: $(list_widgets | tr '\n' ' '))"
    local dir="$PLASMOIDS_DIR/$name"
    [[ -f "$dir/metadata.json" ]] || die "no widget '$name' in $PLASMOIDS_DIR"
    echo "$dir"
}

# widget_field <dir> <jq path> -> prints a metadata.json field
widget_field() {
    jq -r "$2" "$1/metadata.json"
}

list_widgets() {
    find "$PLASMOIDS_DIR" -mindepth 2 -maxdepth 2 -name metadata.json -printf '%P\n' \
        | sed 's|/metadata.json$||' | sort
}
