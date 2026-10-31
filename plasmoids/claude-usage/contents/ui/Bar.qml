/*
    SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick

// A rounded horizontal progress bar.
Rectangle {
    id: bar

    property real value: 0          // 0 – 100, negative = unknown
    property color fillColor: "white"
    property color trackColor: "gray"

    readonly property real fraction: Math.max(0, Math.min(1, value / 100))

    color: trackColor
    radius: height / 2
    implicitHeight: 6

    Rectangle {
        height: parent.height
        radius: parent.radius
        color: bar.fillColor
        visible: bar.fraction > 0
        // Never narrower than a dot, so a small value stays visible
        width: Math.max(height, parent.width * bar.fraction)
        Behavior on width {
            NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
        }
    }
}
