/*
    SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

import "../code/i18n.js" as I18n

KCM.SimpleKCM {
    id: page

    // Each "cfg_<name>" property is bound to the <entry name="..."> of the same name in config/main.xml
    property alias cfg_message: messageField.text
    property alias cfg_showCounter: showCounterBox.checked
    property string cfg_language

    // This page follows the language chosen below as soon as it is picked (see i18n.js)
    function i18n(text, ...args) { return I18n.tr(cfg_language, "", text, args) }
    function i18nc(context, text, ...args) { return I18n.tr(cfg_language, context, text, args) }
    function i18np(singular, plural, n, ...args) { return I18n.trp(cfg_language, "", singular, plural, n, args) }
    function i18ncp(context, singular, plural, n, ...args) { return I18n.trp(cfg_language, context, singular, plural, n, args) }

    Kirigami.FormLayout {
        QQC2.TextField {
            id: messageField
            Kirigami.FormData.label: i18nc("@label:textbox", "Message:")
        }

        QQC2.CheckBox {
            id: showCounterBox
            text: i18nc("@option:check", "Show click counter")
        }

        Item { Kirigami.FormData.isSection: true }

        // Required in every widget: the language setting
        QQC2.ComboBox {
            Kirigami.FormData.label: i18nc("@label:listbox", "Language:")
            textRole: "text"
            valueRole: "value"
            model: [{ value: "auto", text: i18nc("@item language", "Automatic (system language)") }]
                   .concat(I18n.languageChoices)
            currentIndex: Math.max(0, model.findIndex(item => item.value === page.cfg_language))
            onActivated: page.cfg_language = currentValue
        }
    }
}
