#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Build .plasmoid archives (ready for the KDE Store / GitHub releases) in dist/.
# Usage: scripts/package.sh [widget...]   (no argument = all widgets)

source "$(dirname "$0")/common.sh"

widgets=("$@")
[[ ${#widgets[@]} -gt 0 ]] || mapfile -t widgets < <(list_widgets)

mkdir -p "$REPO_ROOT/dist"
for name in "${widgets[@]}"; do
    dir="$(widget_dir "$name")"
    "$REPO_ROOT/scripts/translations.sh" build "$name"
    id="$(widget_field "$dir" .KPlugin.Id)"
    version="$(widget_field "$dir" .KPlugin.Version)"
    out="$REPO_ROOT/dist/$id-$version.plasmoid"
    rm -f "$out"
    (cd "$dir" && zip -qr "$out" metadata.json contents)
    echo "$out"
done
