#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Check every widget: valid metadata.json, unique ids, and (if available)
# QML syntax via qmllint. Used by the CI too.
# Usage: scripts/lint.sh

source "$(dirname "$0")/common.sh"

total_errors=0
declare -A seen_ids

while IFS= read -r name; do
    dir="$PLASMOIDS_DIR/$name"
    meta="$dir/metadata.json"
    errors=0
    fail() { echo "✗ $name: $*"; errors=$((errors + 1)); }

    if ! jq empty "$meta" 2>/dev/null; then
        fail "metadata.json is not valid JSON"
    else
        for field in .KPackageStructure .KPlugin.Id .KPlugin.Name .KPlugin.Version .KPlugin.License .KPlugin.Authors; do
            [[ -n "$(jq -r "$field // empty" "$meta")" ]] || fail "metadata.json is missing $field"
        done

        id="$(jq -r .KPlugin.Id "$meta")"
        [[ -z "${seen_ids[$id]:-}" ]] || fail "id $id is already used by ${seen_ids[$id]}"
        seen_ids[$id]="$name"
    fi

    [[ -f "$dir/contents/ui/main.qml" ]] || fail "contents/ui/main.qml is missing"

    # qmllint only fails on real errors (e.g. syntax); warnings are printed but tolerated.
    if command -v qmllint >/dev/null; then
        while IFS= read -r qml; do
            qmllint "$qml" || fail "${qml#"$dir/"} has QML errors"
        done < <(find "$dir/contents" -name '*.qml')
    else
        echo "  (qmllint not found, QML files of $name not checked)"
    fi

    [[ $errors -gt 0 ]] || echo "✓ $name (${id:-?})"
    total_errors=$((total_errors + errors))
done < <(list_widgets)

[[ $total_errors -eq 0 ]]
