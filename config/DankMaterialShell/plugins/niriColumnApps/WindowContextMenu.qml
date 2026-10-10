// The right-click menu from the stock RunningApps widget. Its Minimize entry is
// left out, because Niri windows cannot be minimized.

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets

PanelWindow {
    id: menuWindow

    property var parentScreen: null
    property var currentWindow: null
    readonly property real menuHeight: menuRect.height
    property bool isVisible: false
    property point anchorPos: Qt.point(0, 0)
    property bool isVertical: false
    property string edge: "top"

    property int triggerBarPosition: (SettingsData.getPrimaryBarConfig()?.position ?? SettingsData.Position.Top)
    property real triggerBarThickness: 0
    property real triggerBarSpacing: 0
    property var triggerBarConfig: null

    signal dismissed

    readonly property real effectiveBarThickness: {
        if (triggerBarThickness > 0 && triggerBarSpacing > 0)
            return triggerBarThickness + triggerBarSpacing;
        return Theme.barThickness(triggerBarConfig?.innerPadding ?? 4, CompositorService.getScreenScale(menuWindow.screen)) + (triggerBarConfig?.spacing ?? 4);
    }

    readonly property real barY: {
        if (!menuWindow.screen || !triggerBarConfig)
            return 0;
        return SettingsData.getBarBounds(menuWindow.screen, effectiveBarThickness, triggerBarPosition, triggerBarConfig).y;
    }

    function showAt(x, y, vertical, barEdge) {
        screen = parentScreen;
        anchorPos = Qt.point(x, y);
        isVertical = vertical ?? false;
        edge = barEdge ?? "top";
        isVisible = true;
        visible = true;
        if (screen)
            TrayMenuManager.registerMenu(screen.name, menuWindow);
    }

    function close() {
        isVisible = false;
        visible = false;
        if (screen)
            TrayMenuManager.unregisterMenu(screen.name);
        dismissed();
    }

    implicitWidth: 100
    implicitHeight: 40
    visible: false
    color: "transparent"

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    WindowBlur {
        targetWindow: menuWindow
        blurX: menuRect.x
        blurY: menuRect.y
        blurWidth: menuWindow.isVisible ? menuRect.width : 0
        blurHeight: menuWindow.isVisible ? menuRect.height : 0
        blurRadius: Theme.cornerRadius
    }

    Component.onDestruction: {
        if (screen)
            TrayMenuManager.unregisterMenu(screen.name);
    }

    Connections {
        target: PopoutManager
        function onPopoutOpening() {
            menuWindow.close();
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: menuWindow.close()
    }

    Rectangle {
        id: menuRect
        x: {
            if (menuWindow.isVertical) {
                if (menuWindow.edge === "left")
                    return Math.min(menuWindow.width - width - 10, menuWindow.anchorPos.x);
                return Math.max(10, menuWindow.anchorPos.x - width);
            }
            const want = menuWindow.anchorPos.x - width / 2;
            return Math.max(10, Math.min(menuWindow.width - width - 10, want));
        }
        y: {
            if (!menuWindow.isVertical)
                return menuWindow.anchorPos.y;
            const top = Math.max(menuWindow.barY, 10);
            const bottom = menuWindow.height - height - 10;
            const want = menuWindow.anchorPos.y - height / 2;
            return Math.max(top, Math.min(bottom, want));
        }
        width: 120
        height: closeItem.height + Theme.spacingXS * 2
        color: Theme.withAlpha(Theme.surfaceContainer, Theme.popupTransparency)
        radius: Theme.cornerRadius
        border.width: BlurService.borderWidth
        border.color: BlurService.borderColor

        Rectangle {
            id: closeItem
            anchors.top: parent.top
            anchors.topMargin: Theme.spacingXS
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - Theme.spacingXS * 2
            height: 28
            radius: Theme.cornerRadius
            color: closeMouseArea.containsMouse ? BlurService.hoverColor(Theme.widgetBaseHoverColor) : "transparent"

            StyledText {
                anchors.centerIn: parent
                text: I18n.tr("Close")
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.widgetTextColor
            }

            MouseArea {
                id: closeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (menuWindow.currentWindow)
                        menuWindow.currentWindow.close();
                    menuWindow.close();
                }
            }
        }
    }
}
