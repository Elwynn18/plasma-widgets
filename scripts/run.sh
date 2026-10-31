#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Open a widget in a standalone test window, straight from the source tree
# (no install needed). Requires plasmoidviewer from the plasma-sdk package.
# Usage: scripts/run.sh <widget> [panel|desktop]

source "$(dirname "$0")/common.sh"

dir="$(widget_dir "${1:-}")"
command -v plasmoidviewer >/dev/null \
    || die "plasmoidviewer not found. Install it with: sudo pacman -S plasma-sdk"

case "${2:-desktop}" in
    panel)   exec plasmoidviewer --applet "$dir" --location bottomedge --formfactor horizontal ;;
    desktop) exec plasmoidviewer --applet "$dir" --location floating --formfactor planar ;;
    *)       die "unknown mode '$2' (use panel or desktop)" ;;
esac
