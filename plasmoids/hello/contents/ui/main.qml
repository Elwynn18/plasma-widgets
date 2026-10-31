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

import "../code/i18n.js" as I18n

PlasmoidItem {
    id: root

    property int clicks: 0

    // Translations: these replace Plasma's i18n functions for this file and for every
    // view created from it, so that the "Language" setting is followed (see i18n.js).
    // Keep them in every new widget, along with the same functions in the settings pages.
    function i18n(text, ...args) {
        return I18n.tr(Plasmoid.configuration.language, "", text, args)
    }
    function i18nc(context, text, ...args) {
        return I18n.tr(Plasmoid.configuration.language, context, text, args)
    }
    function i18np(singular, plural, n, ...args) {
        return I18n.trp(Plasmoid.configuration.language, "", singular, plural, n, args)
    }
    function i18ncp(context, singular, plural, n, ...args) {
        return I18n.trp(Plasmoid.configuration.language, context, singular, plural, n, args)
    }

    // Tooltip shown when hovering the widget in a panel
    toolTipMainText: i18nc("@title", "Hello")
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
