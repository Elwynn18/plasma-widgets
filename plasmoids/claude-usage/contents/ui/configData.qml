/*
    SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid

import "../code/i18n.js" as I18n

KCM.SimpleKCM {
    property alias cfg_refreshMinutes: refreshSpin.value
    property alias cfg_credentialsPath: pathField.text

    // Follow the widget's "Language" setting (see i18n.js)
    function i18n(text, ...args) { return I18n.tr(Plasmoid.configuration.language, "", text, args) }
    function i18nc(context, text, ...args) { return I18n.tr(Plasmoid.configuration.language, context, text, args) }
    function i18ncp(context, singular, plural, n, ...args) {
        return I18n.trp(Plasmoid.configuration.language, context, singular, plural, n, args)
    }

    Kirigami.FormLayout {
        QQC2.SpinBox {
            id: refreshSpin
            Kirigami.FormData.label: i18nc("@label:spinbox", "Refresh every:")
            from: 1
            to: 60
            textFromValue: (value) => i18ncp("@item:valuesuffix", "%1 minute", "%1 minutes", value)
            valueFromText: (text) => parseInt(text)
        }

        QQC2.TextField {
            id: pathField
            Kirigami.FormData.label: i18nc("@label:textbox", "Claude Code sign-in file:")
            Layout.preferredWidth: Kirigami.Units.gridUnit * 18
            placeholderText: "~/.claude/.credentials.json"
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.Label {
            Layout.preferredWidth: Kirigami.Units.gridUnit * 24
            wrapMode: Text.Wrap
            text: i18n("This widget uses your Claude Code sign-in to show the same numbers as its /usage command. "
                       + "Your sign-in only goes to Anthropic's servers and is never stored by the widget. "
                       + "If the numbers stop updating, open Claude Code once to renew the sign-in.")
        }

        QQC2.Label {
            Layout.preferredWidth: Kirigami.Units.gridUnit * 24
            wrapMode: Text.Wrap
            opacity: 0.7
            font: Kirigami.Theme.smallFont
            text: i18n("Unofficial widget, not affiliated with Anthropic.")
        }
    }
}
