/*
    SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick

import org.kde.kirigami as Kirigami

import ".."

// Two rings side by side (stacked in a vertical panel), each with its percentage.
Item {
    id: design

    property real sessionPercent: -1
    property real weeklyPercent: -1
    property UsageColors colors
    property bool showLabels: true
    property bool vertical: false

    readonly property real spacing: Math.round(Kirigami.Units.smallSpacing * 1.5)
    readonly property real side: vertical ? width : height

    implicitWidth: vertical ? width : 2 * side + spacing
    implicitHeight: vertical ? 2 * side + spacing : height

    Grid {
        anchors.centerIn: parent
        columns: design.vertical ? 1 : 2
        spacing: design.spacing

        Repeater {
            model: [design.sessionPercent, design.weeklyPercent]

            Item {
                required property real modelData
                width: design.side
                height: design.side

                Ring {
                    id: ring
                    anchors.fill: parent
                    thickness: Math.max(2, Math.round(design.side * 0.11))
                    value: parent.modelData
                    color: design.colors.colorFor(parent.modelData)
                    trackColor: design.colors.trackColor
                }

                Text {
                    anchors.centerIn: parent
                    width: parent.width - 3 * ring.thickness
                    height: width
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 6
                    font.pixelSize: height * 0.6
                    font.bold: true
                    color: design.colors.textColor
                    text: parent.modelData < 0 ? "–" : Math.round(parent.modelData)
                }
            }
        }
    }
}
