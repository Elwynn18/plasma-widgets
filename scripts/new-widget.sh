#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Create a new widget by copying the "hello" example.
# Usage: scripts/new-widget.sh <folder-name> "<Display Name>"
#   e.g. scripts/new-widget.sh weather "Weather"

source "$(dirname "$0")/common.sh"

name="${1:-}"
title="${2:-}"
[[ "$name" =~ ^[a-z][a-z0-9-]*$ ]] || die "folder name must be lowercase letters, digits or dashes (got '$name')"
[[ -n "$title" ]] || die "missing display name, e.g. scripts/new-widget.sh $name \"My Widget\""

src="$PLASMOIDS_DIR/hello"
dest="$PLASMOIDS_DIR/$name"
[[ ! -e "$dest" ]] || die "$dest already exists"

id="io.github.elwynn18.${name//-/}"
cp -r "$src" "$dest"

tmp="$(mktemp)"
jq --arg id "$id" --arg title "$title" '
    .KPlugin.Id = $id
    | .KPlugin.Name = $title
    | .KPlugin.Version = "0.1.0"
    | .KPlugin.Description = "TODO: describe this widget"
    | del(.KPlugin["Name[fr]"], .KPlugin["Description[fr]"])
' "$src/metadata.json" > "$tmp"
mv "$tmp" "$dest/metadata.json"

echo "Created $dest ($id)"
echo "Try it with: scripts/run.sh $name"
