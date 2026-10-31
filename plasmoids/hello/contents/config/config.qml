/*
    SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick

import org.kde.plasma.configuration
import org.kde.plasma.plasmoid

import "../code/i18n.js" as I18n

ConfigModel {
    // Follow the widget's "Language" setting (see i18n.js)
    function i18nc(context, text) {
        let language = "auto"
        try {
            language = Plasmoid.configuration.language
        } catch (e) {
            // Plasmoid not reachable here: use the system language
        }
        return I18n.tr(language, context, text, [])
    }

    ConfigCategory {
        name: i18nc("@title", "General")
        icon: "configure"
        source: "configGeneral.qml"
    }
}
