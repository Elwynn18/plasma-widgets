/*
    SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick

import org.kde.kirigami as Kirigami

import ".."

// Just the numbers, colored: "5h 23% · 7d 34%" (two lines in a vertical panel).
Item {
    id: design

    property real sessionPercent: -1
    property real weeklyPercent: -1
    property UsageColors colors
    property bool showLabels: true
    property bool vertical: false

    readonly property real fontSize: vertical
        ? Math.max(7, Math.min(Kirigami.Theme.defaultFont.pixelSize, width / 4.5))
        : Math.max(7, Math.min(Kirigami.Theme.defaultFont.pixelSize * 1.5, height * 0.45))

    implicitWidth: vertical ? width : content.implicitWidth + 2 * Kirigami.Units.smallSpacing
    implicitHeight: vertical ? content.implicitHeight + 2 * Kirigami.Units.smallSpacing : height

    component Value: Row {
        id: value
        property string label
        property real percent: -1
        spacing: Math.round(design.fontSize * 0.3)

        Text {
            visible: design.showLabels
            anchors.baseline: number.baseline
            font.pixelSize: Math.round(design.fontSize * 0.8)
            color: design.colors.dimTextColor
            text: value.label
        }
        Text {
            id: number
            font.pixelSize: design.fontSize
            font.bold: true
            font.features: { "tnum": 1 }
            color: value.percent < 0 ? design.colors.dimTextColor : design.colors.colorFor(value.percent)
            text: value.percent < 0
                  ? "–"
                  : i18nc("@label percentage, %1 is a number", "%1%", Math.round(value.percent))
        }
    }

    Grid {
        id: content
        anchors.centerIn: parent
        columns: design.vertical ? 1 : 3
        columnSpacing: Math.round(design.fontSize * 0.4)
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter

        Value {
            label: i18nc("@label short for 5-hour session, keep very short", "5h")
            percent: design.sessionPercent
        }
        Text {
            visible: !design.vertical
            font.pixelSize: design.fontSize
            color: design.colors.dimTextColor
            text: "·"
        }
        Value {
            label: i18nc("@label short for 7-day week, keep very short", "7d")
            percent: design.weeklyPercent
        }
    }
}
