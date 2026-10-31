#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Remove a widget installed with scripts/install.sh.
# Usage: scripts/uninstall.sh <widget>

source "$(dirname "$0")/common.sh"

dir="$(widget_dir "${1:-}")"
kpackagetool6 --type Plasma/Applet --remove "$(widget_field "$dir" .KPlugin.Id)"
