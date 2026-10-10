// DMS's DankTooltip with one clickable row per window, each with the app icon,
// because the stock tooltip shows a single line of text.
// Source: /usr/share/quickshell/dms/Widgets/DankTooltip.qml

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

PanelWindow {
    id: root

    WlrLayershell.namespace: "dms:tooltip"

    readonly property int iconSize: Math.round(Theme.fontSizeSmall * 1.4)
    readonly property real maxTextWidth: 300 - Theme.spacingXS * 2 - Theme.spacingS * 3 - iconSize
    readonly property bool pointerInside: hoverHandler.hovered

    // Each row is { window, icon, text, shown }. The shown row is drawn in bold.
    property var rows: []
    property real targetX: 0
    property real targetY: 0
    property var targetScreen: null
    // Where the tooltip sits relative to (targetX, targetY): "below", "above", "left" or "right".
    property string side: "below"

    signal windowClicked(var window)

    function show(anchor) {
        targetScreen = anchor.screen ?? null;
        targetX = anchor.x;
        targetY = anchor.y;
        side = anchor.side;
        visible = true;
    }

    function hide() {
        visible = false;
    }

    screen: targetScreen
    implicitWidth: Math.max(120, rowColumn.implicitWidth + Theme.spacingXS * 2)
    implicitHeight: rowColumn.implicitHeight + Theme.spacingXS * 2
    color: "transparent"
    visible: false
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1

    anchors {
        top: true
        left: true
    }

    margins {
        left: {
            const screenWidth = targetScreen?.width ?? Screen.width;
            let left = targetX - implicitWidth / 2;
            if (side === "right")
                left = targetX;
            else if (side === "left")
                left = targetX - implicitWidth;
            return Math.round(Math.max(Theme.spacingS, Math.min(screenWidth - implicitWidth - Theme.spacingS, left)));
        }
        top: {
            const screenHeight = targetScreen?.height ?? Screen.height;
            let top = targetY - implicitHeight / 2;
            if (side === "below")
                top = targetY;
            else if (side === "above")
                top = targetY - implicitHeight;
            return Math.round(Math.max(Theme.spacingS, Math.min(screenHeight - implicitHeight - Theme.spacingS, top)));
        }
    }

    WindowBlur {
        targetWindow: root
        blurX: 0
        blurY: 0
        blurWidth: root.visible ? root.width : 0
        blurHeight: root.visible ? root.height : 0
        blurRadius: Theme.cornerRadius
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.withAlpha(Theme.surfaceContainerHigh, Theme.popupTransparency)
        radius: Theme.cornerRadius
        border.width: BlurService.borderWidth
        border.color: BlurService.borderColor

        HoverHandler {
            id: hoverHandler
        }

        ColumnLayout {
            id: rowColumn

            anchors.fill: parent
            anchors.margins: Theme.spacingXS
            spacing: 0

            Repeater {
                model: root.rows

                Rectangle {
                    id: tooltipRow

                    required property var modelData

                    Layout.fillWidth: true
                    implicitWidth: rowContent.implicitWidth + Theme.spacingS * 2
                    implicitHeight: rowContent.implicitHeight + Theme.spacingXS * 2
                    radius: Theme.cornerRadius
                    color: rowMouseArea.containsMouse ? BlurService.hoverColor(Theme.widgetBaseHoverColor) : "transparent"

                    Row {
                        id: rowContent

                        x: Theme.spacingS
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.spacingS

                        IconImage {
                            anchors.verticalCenter: parent.verticalCenter
                            width: root.iconSize
                            height: root.iconSize
                            source: tooltipRow.modelData.icon
                            smooth: true
                            mipmap: true
                            asynchronous: true
                        }

                        StyledText {
                            anchors.verticalCenter: parent.verticalCenter
                            text: tooltipRow.modelData.text
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: tooltipRow.modelData.shown ? Font.Bold : Font.Normal
                            color: Theme.surfaceText
                            wrapMode: Text.NoWrap
                            maximumLineCount: 1
                            elide: Text.ElideRight
                            width: Math.min(implicitWidth, root.maxTextWidth)
                        }
                    }

                    MouseArea {
                        id: rowMouseArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.windowClicked(tooltipRow.modelData.window)
                    }
                }
            }
        }
    }
}
