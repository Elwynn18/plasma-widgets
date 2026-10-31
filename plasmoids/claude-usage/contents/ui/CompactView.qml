/*
    SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

// What is shown in the panel. Left click opens the details, middle click refreshes.
MouseArea {
    id: compact

    property var main   // the PlasmoidItem (main.qml)

    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property bool hasData: main.sessionPercent >= 0

    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
    hoverEnabled: true

    Layout.minimumWidth: vertical || !view.item ? -1 : view.item.implicitWidth
    Layout.preferredWidth: Layout.minimumWidth
    Layout.minimumHeight: !vertical || !view.item ? -1 : view.item.implicitHeight
    Layout.preferredHeight: Layout.minimumHeight

    onClicked: mouse => {
        if (mouse.button === Qt.MiddleButton) {
            main.refresh()
        } else {
            main.expanded = !main.expanded
        }
    }

    ConfiguredColors {
        id: usageColors
        inPanel: true
    }

    DesignLoader {
        id: view
        anchors.fill: parent
        opacity: compact.hasData ? 1 : 0.5
        design: Plasmoid.configuration.design
        sessionPercent: main.sessionPercent
        weeklyPercent: main.weeklyPercent
        colors: usageColors
        showLabels: Plasmoid.configuration.showLabels
        vertical: compact.vertical
    }

    // Small warning badge when the data could not be refreshed
    Kirigami.Icon {
        visible: main.errorCode !== ""
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: Math.round(Math.min(parent.width, parent.height) * 0.45)
        height: width
        source: "dialog-warning"
    }
}
