#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Install (or upgrade) a widget for the current user.
# Usage: scripts/install.sh <widget>

source "$(dirname "$0")/common.sh"

dir="$(widget_dir "${1:-}")"
id="$(widget_field "$dir" .KPlugin.Id)"

if kpackagetool6 --type Plasma/Applet --show "$id" >/dev/null 2>&1; then
    kpackagetool6 --type Plasma/Applet --upgrade "$dir"
else
    kpackagetool6 --type Plasma/Applet --install "$dir"
fi

echo
echo "Installed $id. If Plasma still shows the old version, restart it:"
echo "  systemctl --user restart plasma-plasmashell"
