#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Check every widget. Used by the CI too.
#   - metadata.json: valid, required fields, unique id, name/description in every language
#   - QML syntax (qmllint, when available)
#   - translations: fr, es, nb complete and up to date (scripts/translations.sh check)
#   - KDE Store material: STORE.md filled in, 512×512 logo, presentation image
#     (not required for the "hello" template, which is never published)
# Usage: scripts/lint.sh

source "$(dirname "$0")/common.sh"

LANGUAGES=(fr es nb)
TEMPLATE="hello"

# png_size <file> -> prints "<width>x<height>"
png_size() {
    python3 -I -c 'import struct, sys
d = open(sys.argv[1], "rb").read(24)
print("%dx%d" % struct.unpack(">II", d[16:24]) if d[:8] == b"\x89PNG\r\n\x1a\n" else "not-a-png")' "$1"
}

total_errors=0
declare -A seen_ids

while IFS= read -r name; do
    dir="$PLASMOIDS_DIR/$name"
    meta="$dir/metadata.json"
    errors=0
    id=""
    fail() { echo "✗ $name: $*"; errors=$((errors + 1)); }

    # ── metadata.json ──
    if ! jq empty "$meta" 2>/dev/null; then
        fail "metadata.json is not valid JSON"
    else
        for field in .KPackageStructure .KPlugin.Id .KPlugin.Name .KPlugin.Version .KPlugin.License .KPlugin.Authors \
                     .KPlugin.Description; do
            [[ -n "$(jq -r "$field // empty" "$meta")" ]] || fail "metadata.json is missing $field"
        done
        for lang in "${LANGUAGES[@]}"; do
            for key in Name Description; do
                [[ -n "$(jq -r --arg k "$key[$lang]" '.KPlugin[$k] // empty' "$meta")" ]] \
                    || fail "metadata.json is missing $key[$lang]"
            done
        done
        grep -q 'TODO' "$meta" && fail "metadata.json still contains TODO"

        id="$(jq -r .KPlugin.Id "$meta")"
        [[ -z "${seen_ids[$id]:-}" ]] || fail "id $id is already used by ${seen_ids[$id]}"
        seen_ids[$id]="$name"
    fi

    # ── QML ──
    [[ -f "$dir/contents/ui/main.qml" ]] || fail "contents/ui/main.qml is missing"
    # qmllint only fails on real errors (e.g. syntax); warnings are printed but tolerated.
    if command -v qmllint >/dev/null; then
        while IFS= read -r qml; do
            qmllint "$qml" || fail "${qml#"$dir/"} has QML errors"
        done < <(find "$dir/contents" -name '*.qml')
    else
        echo "  (qmllint not found, QML files of $name not checked)"
    fi

    # ── Translations ──
    while IFS= read -r problem; do
        fail "$problem"
    done < <("$REPO_ROOT/scripts/translations.sh" check "$name")

    # ── KDE Store material ──
    if [[ "$name" != "$TEMPLATE" ]]; then
        if [[ ! -f "$dir/STORE.md" ]]; then
            fail "STORE.md is missing (store description, category, tags)"
        elif grep -q 'TODO' "$dir/STORE.md"; then
            fail "STORE.md still contains TODO"
        fi
        logo="$dir/screenshots/logo.png"
        if [[ ! -f "$logo" ]]; then
            fail "screenshots/logo.png is missing (512×512 PNG)"
        elif [[ "$(png_size "$logo")" != "512x512" ]]; then
            fail "screenshots/logo.png must be 512×512 (it is $(png_size "$logo"))"
        fi
        find "$dir/screenshots" -maxdepth 1 -name '*.png' ! -name logo.png 2>/dev/null | grep -q . \
            || fail "screenshots/ needs at least one presentation image besides the logo"
    fi

    [[ $errors -gt 0 ]] || echo "✓ $name (${id:-?})"
    total_errors=$((total_errors + errors))
done < <(list_widgets)

[[ $total_errors -eq 0 ]]
