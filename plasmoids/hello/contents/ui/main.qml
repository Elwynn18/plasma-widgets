/*
    SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    property int clicks: 0

    // Tooltip shown when hovering the widget in a panel
    toolTipMainText: Plasmoid.title
    toolTipSubText: Plasmoid.configuration.message

    // In a panel: a simple icon that opens the popup
    compactRepresentation: Kirigami.Icon {
        source: Plasmoid.icon
        active: compactMouse.containsMouse

        MouseArea {
            id: compactMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.expanded = !root.expanded
        }
    }

    // On the desktop or in the popup: the full view
    fullRepresentation: ColumnLayout {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 12
        Layout.minimumHeight: Kirigami.Units.gridUnit * 8
        spacing: Kirigami.Units.largeSpacing

        Kirigami.Heading {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            text: Plasmoid.configuration.message
        }

        PlasmaComponents.Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            visible: Plasmoid.configuration.showCounter
            text: i18np("Clicked once", "Clicked %1 times", root.clicks)
        }

        PlasmaComponents.Button {
            Layout.alignment: Qt.AlignHCenter
            icon.name: "list-add"
            text: i18n("Click me")
            onClicked: root.clicks++
        }
    }
}
