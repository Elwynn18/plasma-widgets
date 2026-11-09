/*
    SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick

import org.kde.kirigami as Kirigami

// Colors used by the panel designs, the popup and the settings preview.
// It must be placed inside the view that uses it, so that the theme colors are
// those of that view, e.g. light text in a dark panel.
Item {
    visible: false

    // The theme is read from the visible view holding this object: in the panel,
    // the theme of a hidden item can keep its default colors (all black).
    property Item themeItem: parent
    readonly property var theme: themeItem ? themeItem.Kirigami.Theme : Kirigami.Theme

    property string mode: "terracotta"   // accent | terracotta | green | custom
    property color customColor: "#D97757"
    property bool bySeverity: true
    property int warning: 70
    property int critical: 90
    property string textMode: "auto"     // auto | light | dark | custom
    property color customTextColor: "#FFFFFF"

    readonly property color baseColor: {
        switch (mode) {
        case "accent": return theme.highlightColor
        case "green":  return theme.positiveTextColor
        case "custom": return customColor
        default:       return "#D97757"
        }
    }
    readonly property color textColor: {
        switch (textMode) {
        case "light":  return "#FCFCFC"
        case "dark":   return "#232629"
        case "custom": return customTextColor
        default:       return theme.textColor
        }
    }
    readonly property color dimTextColor: Qt.rgba(textColor.r, textColor.g, textColor.b, 0.6)
    readonly property color trackColor: Qt.rgba(textColor.r, textColor.g, textColor.b, 0.15)

    function colorFor(percent) {
        if (bySeverity && percent >= critical) {
            return theme.negativeTextColor
        }
        if (bySeverity && percent >= warning) {
            return theme.neutralTextColor
        }
        return baseColor
    }
}
