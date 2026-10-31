/*
    SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

// The popup opened from the panel (also shown directly on the desktop).
ColumnLayout {
    id: full

    property var main   // the PlasmoidItem (main.qml)

    Layout.minimumWidth: Kirigami.Units.gridUnit * 16
    Layout.preferredWidth: Kirigami.Units.gridUnit * 20
    Layout.minimumHeight: implicitHeight
    Layout.maximumHeight: implicitHeight
    spacing: Kirigami.Units.largeSpacing

    ConfiguredColors {
        id: usageColors
    }

    // ── Header ────────────────────────────────────────────────
    RowLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Heading {
            level: 3
            text: i18nc("@title", "Claude usage")
        }

        // Plan badge ("Max", "Pro"…)
        Rectangle {
            visible: main.plan !== ""
            implicitWidth: planLabel.implicitWidth + 2 * Kirigami.Units.smallSpacing
            implicitHeight: planLabel.implicitHeight + Kirigami.Units.smallSpacing / 2
            radius: height / 2
            color: Qt.rgba(usageColors.baseColor.r, usageColors.baseColor.g, usageColors.baseColor.b, 0.2)

            PlasmaComponents.Label {
                id: planLabel
                anchors.centerIn: parent
                text: main.plan.charAt(0).toUpperCase() + main.plan.slice(1)
                font: Kirigami.Theme.smallFont
                color: usageColors.baseColor
            }
        }

        Item { Layout.fillWidth: true }

        PlasmaComponents.BusyIndicator {
            visible: main.loading
            running: visible
            Layout.preferredWidth: Kirigami.Units.iconSizes.small
            Layout.preferredHeight: Kirigami.Units.iconSizes.small
        }

        PlasmaComponents.ToolButton {
            icon.name: "view-refresh"
            enabled: !main.loading
            display: PlasmaComponents.AbstractButton.IconOnly
            text: i18nc("@action:button", "Refresh")
            onClicked: main.refresh()
            PlasmaComponents.ToolTip.text: text
            PlasmaComponents.ToolTip.visible: hovered
        }

        PlasmaComponents.ToolButton {
            icon.name: "configure"
            display: PlasmaComponents.AbstractButton.IconOnly
            text: i18nc("@action:button", "Settings…")
            onClicked: Plasmoid.internalAction("configure").trigger()
            PlasmaComponents.ToolTip.text: text
            PlasmaComponents.ToolTip.visible: hovered
        }
    }

    // ── Error ─────────────────────────────────────────────────
    Kirigami.InlineMessage {
        Layout.fillWidth: true
        visible: main.errorCode !== ""
        type: main.sessionPercent < 0 ? Kirigami.MessageType.Error : Kirigami.MessageType.Warning
        text: main.errorText
    }

    // ── Limits ────────────────────────────────────────────────
    UsageMeter {
        Layout.fillWidth: true
        title: i18nc("@label", "Session (5 hours)")
        percent: main.sessionPercent
        subtitle: main.session ? main.resetText(main.session.resetsAt)
                               : (main.usage ? i18n("No session in progress") : "")
        colors: usageColors
    }

    UsageMeter {
        Layout.fillWidth: true
        title: i18nc("@label", "Week")
        percent: main.weeklyPercent
        subtitle: main.weekly ? main.resetText(main.weekly.resetsAt) : ""
        colors: usageColors
    }

    // Model-specific weekly limits, when the plan has some
    Repeater {
        model: main.scopedLimits

        UsageMeter {
            required property var modelData
            Layout.fillWidth: true
            small: true
            title: i18nc("@label weekly limit for a given model, %1 is the model name", "Week · %1", modelData.name)
            percent: modelData.percent
            colors: usageColors
        }
    }

    // ── Where the weekly usage went ───────────────────────────
    ColumnLayout {
        Layout.fillWidth: true
        visible: main.breakdown.length > 0
        spacing: Kirigami.Units.smallSpacing

        PlasmaComponents.Label {
            text: i18nc("@label", "This week's usage by app")
            font: Kirigami.Theme.smallFont
            opacity: 0.7
        }

        // Stacked bar with one segment per app
        Row {
            id: stack
            Layout.fillWidth: true
            height: 6
            spacing: 2

            Repeater {
                model: main.breakdown

                Rectangle {
                    required property var modelData
                    required property int index
                    height: stack.height
                    radius: height / 2
                    width: Math.max(0, (stack.width - stack.spacing * (main.breakdown.length - 1)) * modelData.percent / 100)
                    visible: modelData.percent > 0
                    color: usageColors.baseColor
                    opacity: 1 - index * 0.22
                }
            }
        }

        Flow {
            Layout.fillWidth: true
            spacing: Kirigami.Units.largeSpacing

            Repeater {
                model: main.breakdown

                Row {
                    required property var modelData
                    required property int index
                    spacing: Kirigami.Units.smallSpacing

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 8
                        height: 8
                        radius: 4
                        color: usageColors.baseColor
                        opacity: 1 - parent.index * 0.22
                    }
                    PlasmaComponents.Label {
                        font: Kirigami.Theme.smallFont
                        text: i18nc("@label app name and percentage", "%1 %2%",
                                    main.appName(parent.modelData), parent.modelData.percent)
                    }
                }
            }
        }
    }

    // ── Footer ────────────────────────────────────────────────
    RowLayout {
        Layout.fillWidth: true

        PlasmaComponents.Label {
            Layout.fillWidth: true
            text: main.lastUpdate > 0 ? i18nc("@info", "Updated %1", main.timeAgo(main.lastUpdate)) : ""
            font: Kirigami.Theme.smallFont
            opacity: 0.6
            elide: Text.ElideRight
        }

        PlasmaComponents.ToolButton {
            icon.name: "internet-web-browser"
            text: i18nc("@action:button", "Details")
            font: Kirigami.Theme.smallFont
            onClicked: Qt.openUrlExternally("https://claude.ai/settings/usage")
            PlasmaComponents.ToolTip.text: i18nc("@info:tooltip", "Open the usage page on claude.ai")
            PlasmaComponents.ToolTip.visible: hovered
        }
    }
}
