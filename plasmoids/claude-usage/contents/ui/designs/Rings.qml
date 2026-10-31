/*
    SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick

import ".."

// Two concentric rings: outer = week, inner = 5-hour session.
// The session percentage is written in the middle.
Item {
    id: design

    property real sessionPercent: -1
    property real weeklyPercent: -1
    property UsageColors colors
    property bool showLabels: true
    property bool vertical: false

    implicitWidth: vertical ? width : height
    implicitHeight: vertical ? width : height

    readonly property real side: Math.min(width, height)
    readonly property real thickness: Math.max(2, Math.round(side * 0.1))
    readonly property real gap: Math.max(1, Math.round(side * 0.04))

    Ring {
        id: outer
        anchors.centerIn: parent
        width: design.side
        height: design.side
        thickness: design.thickness
        value: design.weeklyPercent
        color: design.colors.colorFor(design.weeklyPercent)
        trackColor: design.colors.trackColor
    }

    Ring {
        id: inner
        anchors.centerIn: parent
        width: design.side - 2 * (design.thickness + design.gap)
        height: width
        thickness: design.thickness
        value: design.sessionPercent
        color: design.colors.colorFor(design.sessionPercent)
        trackColor: design.colors.trackColor
    }

    Text {
        anchors.centerIn: parent
        width: inner.width - 2 * design.thickness
        height: width
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        fontSizeMode: Text.Fit
        minimumPixelSize: 6
        font.pixelSize: height * 0.6
        font.bold: true
        color: design.colors.textColor
        text: design.sessionPercent < 0 ? "–" : Math.round(design.sessionPercent)
    }
}
