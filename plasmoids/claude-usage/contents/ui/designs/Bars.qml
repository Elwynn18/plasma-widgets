/*
    SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import ".."

// Two thin stacked bars: "5h ▬▬▬── 23%" over "7d ▬▬▬▬─ 34%".
Item {
    id: design

    property real sessionPercent: -1
    property real weeklyPercent: -1
    property UsageColors colors
    property bool showLabels: true
    property bool vertical: false

    // In a vertical panel there is little width: the percentages are dropped.
    readonly property bool showPercent: !vertical || width >= Kirigami.Units.gridUnit * 4
    readonly property real rowHeight: Math.min(height / 2, Kirigami.Units.gridUnit * 1.2)
    readonly property real fontSize: Math.max(7, Math.round(rowHeight * 0.75))

    implicitWidth: vertical ? width : Kirigami.Units.gridUnit * (showLabels ? 6.5 : 5)
    implicitHeight: vertical ? Kirigami.Units.gridUnit * 2 : height

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Math.round(Kirigami.Units.smallSpacing / 2)
        spacing: 0

        Repeater {
            model: [
                { label: i18nc("@label short for 5-hour session, keep very short", "5h"), value: design.sessionPercent },
                { label: i18nc("@label short for 7-day week, keep very short", "7d"), value: design.weeklyPercent }
            ]

            RowLayout {
                required property var modelData
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Kirigami.Units.smallSpacing

                Text {
                    visible: design.showLabels
                    Layout.minimumWidth: design.fontSize * 1.4
                    font.pixelSize: design.fontSize
                    color: design.colors.dimTextColor
                    text: parent.modelData.label
                }

                Bar {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(3, Math.round(design.rowHeight * 0.32))
                    value: parent.modelData.value
                    fillColor: design.colors.colorFor(parent.modelData.value)
                    trackColor: design.colors.trackColor
                }

                Text {
                    visible: design.showPercent
                    Layout.minimumWidth: design.fontSize * 2.4
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: design.fontSize
                    font.bold: true
                    font.features: { "tnum": 1 }
                    color: design.colors.textColor
                    text: parent.modelData.value < 0
                          ? "–"
                          : i18nc("@label percentage, %1 is a number", "%1%", Math.round(parent.modelData.value))
                }
            }
        }
    }
}
