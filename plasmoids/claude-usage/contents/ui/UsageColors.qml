/*
    SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick

import org.kde.kirigami as Kirigami

// Colors used by the panel designs, the popup and the settings preview.
// It must be placed inside the view that uses it: it is an Item (not a
// QtObject) so that Kirigami.Theme follows the colors of that view's parent,
// e.g. light text in a dark panel.
Item {
    visible: false

    property string mode: "terracotta"   // accent | terracotta | green | custom
    property color customColor: "#D97757"
    property bool bySeverity: true
    property int warning: 70
    property int critical: 90
    property string textMode: "auto"     // auto | light | dark | custom
    property color customTextColor: "#FFFFFF"

    readonly property color baseColor: {
        switch (mode) {
        case "accent": return Kirigami.Theme.highlightColor
        case "green":  return Kirigami.Theme.positiveTextColor
        case "custom": return customColor
        default:       return "#D97757"
        }
    }
    readonly property color textColor: {
        switch (textMode) {
        case "light":  return "#FCFCFC"
        case "dark":   return "#232629"
        case "custom": return customTextColor
        default:       return Kirigami.Theme.textColor
        }
    }
    readonly property color dimTextColor: Qt.rgba(textColor.r, textColor.g, textColor.b, 0.6)
    readonly property color trackColor: Qt.rgba(textColor.r, textColor.g, textColor.b, 0.15)

    function colorFor(percent) {
        if (bySeverity && percent >= critical) {
            return Kirigami.Theme.negativeTextColor
        }
        if (bySeverity && percent >= warning) {
            return Kirigami.Theme.neutralTextColor
        }
        return baseColor
    }
}
