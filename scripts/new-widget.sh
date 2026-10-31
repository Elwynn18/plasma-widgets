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
    | .KPlugin.Version = "0.1.0"
    | .KPlugin.Name = $title
    | .KPlugin["Name[fr]"] = $title | .KPlugin["Name[es]"] = $title | .KPlugin["Name[nb]"] = $title
    | .KPlugin.Description = "TODO: describe this widget in one line"
    | .KPlugin["Description[fr]"] = "TODO" | .KPlugin["Description[es]"] = "TODO" | .KPlugin["Description[nb]"] = "TODO"
' "$src/metadata.json" > "$tmp"
mv "$tmp" "$dest/metadata.json"
sed -i "s/io\.github\.elwynn18\.hello/$id/g" "$dest"/po/*.po "$dest"/po/template.pot

# Store material, required before the widget can pass scripts/lint.sh (see CONTRIBUTING.md)
mkdir -p "$dest/screenshots"
cat > "$dest/STORE.md" <<STORE
# KDE Store page

- Page: TODO (link once published)
- Product name: $title
- Category: Plasma 6 Applets
- Tags: plasma6, widget, TODO
- License: GPL-2.0-or-later
- Source link: https://github.com/Elwynn18/plasma-widgets/tree/main/plasmoids/$name
- Logo: \`screenshots/logo.png\` (512×512) · Gallery: TODO (1200×675 images in \`screenshots/\`)

## Description

\`\`\`
TODO: English only. What the widget shows, its features, its requirements.

Source code and bug reports: https://github.com/Elwynn18/plasma-widgets
\`\`\`
STORE

echo "Created $dest ($id)"
echo
echo "Before it can pass scripts/lint.sh:"
echo "  - translate the names and descriptions in metadata.json (fr, es, nb)"
echo "  - after changing texts: scripts/translations.sh update $name, then complete po/fr.po, po/es.po, po/nb.po"
echo "  - fill STORE.md, add screenshots/logo.png (512×512) and a presentation image"
echo
echo "Try it with: scripts/run.sh $name"
