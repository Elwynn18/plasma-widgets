/*
    SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick

import org.kde.plasma.plasmoid

// UsageColors following the widget settings.
UsageColors {
    // The text color setting only applies to the panel; the popup keeps the theme's text color
    property bool inPanel: false

    mode: Plasmoid.configuration.colorMode
    customColor: Plasmoid.configuration.customColor
    bySeverity: Plasmoid.configuration.colorBySeverity
    warning: Plasmoid.configuration.warningThreshold
    critical: Plasmoid.configuration.criticalThreshold
    textMode: inPanel ? Plasmoid.configuration.textColorMode : "auto"
    customTextColor: Plasmoid.configuration.customTextColor
}
