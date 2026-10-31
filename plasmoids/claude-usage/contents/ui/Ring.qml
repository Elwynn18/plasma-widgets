/*
    SPDX-FileCopyrightText: 2026 Elwynn18 <oursbleu18@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Shapes

// A circular gauge: a faint full circle with a colored arc on top,
// starting at 12 o'clock and going clockwise.
Item {
    id: ring

    property real value: 0          // 0 – 100, negative = unknown
    property color color: "white"
    property color trackColor: "gray"
    property real thickness: 3

    readonly property real radius: (Math.min(width, height) - thickness) / 2
    readonly property real fraction: Math.max(0, Math.min(1, value / 100))

    property real animatedFraction: fraction
    Behavior on animatedFraction {
        NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: "transparent"
            strokeColor: ring.trackColor
            strokeWidth: ring.thickness
            PathAngleArc {
                centerX: ring.width / 2
                centerY: ring.height / 2
                radiusX: ring.radius
                radiusY: ring.radius
                startAngle: -90
                sweepAngle: 360
            }
        }

        ShapePath {
            fillColor: "transparent"
            // Hide the arc completely at 0 % (a round cap would still draw a dot)
            strokeColor: ring.animatedFraction > 0 ? ring.color : "transparent"
            strokeWidth: ring.thickness
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: ring.width / 2
                centerY: ring.height / 2
                radiusX: ring.radius
                radiusY: ring.radius
                startAngle: -90
                sweepAngle: 360 * ring.animatedFraction
            }
        }
    }
}
