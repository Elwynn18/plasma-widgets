/*
    SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick

// Loads one of the panel designs from designs/ by its config name.
// Used by the panel view and by the previews in the settings.
Loader {
    id: loader

    property string design: "rings"
    property real sessionPercent: -1
    property real weeklyPercent: -1
    property UsageColors colors
    property bool showLabels: true
    property bool vertical: false

    readonly property var files: ({
        rings: "Rings.qml",
        twinRings: "TwinRings.qml",
        bars: "Bars.qml",
        text: "TextOnly.qml"
    })

    readonly property url designUrl: Qt.resolvedUrl("designs/" + (files[design] || files.rings))

    // The design gets its values at creation (no null colors on the first frame),
    // then follows them through the bindings set in onLoaded.
    function load() {
        if (!colors) {
            return
        }
        setSource(designUrl, {
            sessionPercent: sessionPercent,
            weeklyPercent: weeklyPercent,
            colors: colors,
            showLabels: showLabels,
            vertical: vertical
        })
    }

    Component.onCompleted: load()
    onDesignUrlChanged: load()
    onColorsChanged: if (!item) load()

    onLoaded: {
        item.sessionPercent = Qt.binding(() => loader.sessionPercent)
        item.weeklyPercent = Qt.binding(() => loader.weeklyPercent)
        item.colors = Qt.binding(() => loader.colors)
        item.showLabels = Qt.binding(() => loader.showLabels)
        item.vertical = Qt.binding(() => loader.vertical)
    }
}
