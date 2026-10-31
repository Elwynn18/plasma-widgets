/*
    SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kquickcontrols as KQuickControls

import "../code/i18n.js" as I18n

KCM.SimpleKCM {
    id: page

    // Bound by name to the entries of config/main.xml
    property string cfg_design
    property string cfg_colorMode
    property alias cfg_customColor: colorButton.color
    property alias cfg_colorBySeverity: severityBox.checked
    property alias cfg_warningThreshold: warningSpin.value
    property alias cfg_criticalThreshold: criticalSpin.value
    property alias cfg_showLabels: labelsBox.checked
    property string cfg_textColorMode
    property alias cfg_customTextColor: textColorButton.color
    property string cfg_language

    // This page follows the language chosen below as soon as it is picked (see i18n.js)
    function i18n(text, ...args) { return I18n.tr(cfg_language, "", text, args) }
    function i18nc(context, text, ...args) { return I18n.tr(cfg_language, context, text, args) }
    function i18np(singular, plural, n, ...args) { return I18n.trp(cfg_language, "", singular, plural, n, args) }
    function i18ncp(context, singular, plural, n, ...args) { return I18n.trp(cfg_language, context, singular, plural, n, args) }

    // Sample values for the previews: the week is past the default warning level
    readonly property real sampleSession: 42
    readonly property real sampleWeekly: 76

    UsageColors {
        id: previewColors
        mode: page.cfg_colorMode
        customColor: colorButton.color
        bySeverity: severityBox.checked
        warning: warningSpin.value
        critical: criticalSpin.value
        textMode: page.cfg_textColorMode
        customTextColor: textColorButton.color
    }

    // Background of the previews: something the chosen text color is readable on
    readonly property color previewBackground: {
        switch (cfg_textColorMode) {
        case "light": return "#2A2E32"
        case "dark":  return "#EFF0F1"
        case "custom": {
            const c = textColorButton.color
            return 0.299 * c.r + 0.587 * c.g + 0.114 * c.b > 0.5 ? "#2A2E32" : "#EFF0F1"
        }
        default: return Kirigami.Theme.alternateBackgroundColor
        }
    }

    Kirigami.FormLayout {
        // ── Design ───────────────────────────────────────────
        GridLayout {
            Kirigami.FormData.label: i18nc("@label", "Design:")
            Kirigami.FormData.buddyFor: null
            columns: 2
            rowSpacing: Kirigami.Units.largeSpacing
            columnSpacing: Kirigami.Units.largeSpacing

            Repeater {
                model: [
                    { id: "rings",     name: i18nc("@item design", "Rings") },
                    { id: "twinRings", name: i18nc("@item design", "Twin rings") },
                    { id: "bars",      name: i18nc("@item design", "Bars") },
                    { id: "text",      name: i18nc("@item design", "Text") }
                ]

                QQC2.ItemDelegate {
                    id: card
                    required property var modelData
                    readonly property bool selected: page.cfg_design === modelData.id

                    implicitWidth: Kirigami.Units.gridUnit * 9
                    implicitHeight: Kirigami.Units.gridUnit * 5
                    padding: Kirigami.Units.smallSpacing
                    highlighted: selected
                    onClicked: page.cfg_design = modelData.id

                    contentItem: ColumnLayout {
                        spacing: Kirigami.Units.smallSpacing

                        // A slice of "panel" with the design inside
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Kirigami.Units.gridUnit * 2.2
                            radius: Kirigami.Units.cornerRadius
                            color: page.previewBackground
                            border.width: card.selected ? 2 : 1
                            border.color: card.selected ? Kirigami.Theme.highlightColor
                                                        : Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g,
                                                                  Kirigami.Theme.textColor.b, 0.15)

                            DesignLoader {
                                anchors.centerIn: parent
                                height: parent.height - 2 * Kirigami.Units.smallSpacing
                                width: item ? Math.min(item.implicitWidth, parent.width - 8) : 0
                                design: card.modelData.id
                                sessionPercent: page.sampleSession
                                weeklyPercent: page.sampleWeekly
                                colors: previewColors
                                showLabels: labelsBox.checked
                            }
                        }

                        QQC2.Label {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            text: card.modelData.name
                            font.bold: card.selected
                        }
                    }
                }
            }
        }

        QQC2.CheckBox {
            id: labelsBox
            text: i18nc("@option:check", "Show “5h” and “7d” labels")
            enabled: page.cfg_design === "bars" || page.cfg_design === "text"
        }

        Item { Kirigami.FormData.isSection: true }

        // ── Colors ───────────────────────────────────────────
        RowLayout {
            Kirigami.FormData.label: i18nc("@label:listbox", "Color:")

            QQC2.ComboBox {
                id: colorCombo
                textRole: "text"
                valueRole: "value"
                model: [
                    { value: "terracotta", text: i18nc("@item color", "Terracotta") },
                    { value: "accent",     text: i18nc("@item color", "Theme accent color") },
                    { value: "green",      text: i18nc("@item color", "Green") },
                    { value: "custom",     text: i18nc("@item color", "Custom…") }
                ]
                currentIndex: Math.max(0, model.findIndex(item => item.value === page.cfg_colorMode))
                onActivated: page.cfg_colorMode = currentValue
            }

            KQuickControls.ColorButton {
                id: colorButton
                visible: page.cfg_colorMode === "custom"
                dialogTitle: i18nc("@title:window", "Choose a Color")
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18nc("@label:listbox", "Text color:")

            QQC2.ComboBox {
                textRole: "text"
                valueRole: "value"
                model: [
                    { value: "auto",   text: i18nc("@item text color", "Automatic (panel theme)") },
                    { value: "light",  text: i18nc("@item text color", "Light") },
                    { value: "dark",   text: i18nc("@item text color", "Dark") },
                    { value: "custom", text: i18nc("@item text color", "Custom…") }
                ]
                currentIndex: Math.max(0, model.findIndex(item => item.value === page.cfg_textColorMode))
                onActivated: page.cfg_textColorMode = currentValue
            }

            KQuickControls.ColorButton {
                id: textColorButton
                visible: page.cfg_textColorMode === "custom"
                dialogTitle: i18nc("@title:window", "Choose a Text Color")
            }
        }

        QQC2.CheckBox {
            id: severityBox
            text: i18nc("@option:check", "Turn orange, then red, near the limit")
        }

        QQC2.SpinBox {
            id: warningSpin
            Kirigami.FormData.label: i18nc("@label:spinbox", "Orange from:")
            enabled: severityBox.checked
            from: 1
            to: 100
            textFromValue: (value) => i18nc("@label percentage, %1 is a number", "%1%", value)
            valueFromText: (text) => parseInt(text)
        }

        QQC2.SpinBox {
            id: criticalSpin
            Kirigami.FormData.label: i18nc("@label:spinbox", "Red from:")
            enabled: severityBox.checked
            from: 1
            to: 100
            textFromValue: (value) => i18nc("@label percentage, %1 is a number", "%1%", value)
            valueFromText: (text) => parseInt(text)
        }

        Item { Kirigami.FormData.isSection: true }

        // ── Language ─────────────────────────────────────────
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
