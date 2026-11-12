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

    // The fraction is animated rather than the width: a new value slides from the
    // previous one, and resizing the bar (layout, popup opening) is not animated.
    property real animatedFraction: fraction
    Behavior on animatedFraction {
        NumberAnimation { duration: 900; easing.type: Easing.OutCubic }
    }

    color: trackColor
    radius: height / 2
    implicitHeight: 6

    Rectangle {
        height: parent.height
        radius: parent.radius
        color: bar.fillColor
        visible: bar.animatedFraction > 0
        // Never narrower than a dot, so a small value stays visible
        width: Math.max(height, parent.width * bar.animatedFraction)
    }
}
