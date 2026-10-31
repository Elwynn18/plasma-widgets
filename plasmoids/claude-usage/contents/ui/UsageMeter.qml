/*
    SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

// One limit in the popup: title, big percentage, bar and reset time.
ColumnLayout {
    id: meter

    property string title
    property real percent: -1
    property string subtitle
    property UsageColors colors
    property bool small: false

    spacing: Kirigami.Units.smallSpacing

    RowLayout {
        Layout.fillWidth: true

        PlasmaComponents.Label {
            Layout.fillWidth: true
            text: meter.title
            font.bold: !meter.small
            elide: Text.ElideRight
        }

        PlasmaComponents.Label {
            text: meter.percent < 0
                  ? "–"
                  : i18nc("@label percentage, %1 is a number", "%1%", Math.round(meter.percent))
            font.pixelSize: meter.small ? Kirigami.Theme.defaultFont.pixelSize
                                        : Math.round(Kirigami.Theme.defaultFont.pixelSize * 1.6)
            font.bold: true
            font.features: { "tnum": 1 }
            color: meter.percent < 0 ? meter.colors.dimTextColor : meter.colors.colorFor(meter.percent)
        }
    }

    Bar {
        Layout.fillWidth: true
        implicitHeight: meter.small ? 4 : 8
        value: meter.percent
        fillColor: meter.colors.colorFor(meter.percent)
        trackColor: meter.colors.trackColor
    }

    PlasmaComponents.Label {
        Layout.fillWidth: true
        visible: text !== ""
        text: meter.subtitle
        font: Kirigami.Theme.smallFont
        opacity: 0.7
        elide: Text.ElideRight
    }
}
