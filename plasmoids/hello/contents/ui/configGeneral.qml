/*
    SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    // Each "cfg_<name>" property is bound to the <entry name="..."> of the same name in config/main.xml
    property alias cfg_message: messageField.text
    property alias cfg_showCounter: showCounterBox.checked

    Kirigami.FormLayout {
        QQC2.TextField {
            id: messageField
            Kirigami.FormData.label: i18nc("@label:textbox", "Message:")
        }

        QQC2.CheckBox {
            id: showCounterBox
            text: i18nc("@option:check", "Show click counter")
        }
    }
}
