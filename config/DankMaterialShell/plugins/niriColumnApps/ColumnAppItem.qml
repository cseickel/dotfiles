// One bar item for one Niri column, showing the window NiriColumnApps chose for
// it and a count badge when the column holds more than one window. Its tooltip
// lists every window in the column from top to bottom, with the shown one in bold.

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: appItem

    required property var modelData
    required property var pill

    readonly property var windows: modelData.windows
    readonly property var focusedWindow: windows.find(w => w.activated) ?? null
    readonly property var shownWindow: modelData.shownWindow
    readonly property int windowCount: windows.length
    readonly property string appId: shownWindow.appId || ""
    readonly property string effectiveAppId: {
        pill._appIdSubstitutionsTrigger;
        return Paths.moddedAppId(appId);
    }
    readonly property var desktopEntry: {
        pill._desktopEntriesUpdateTrigger;
        return effectiveAppId ? DesktopEntries.heuristicLookup(effectiveAppId) : null;
    }
    readonly property string appName: effectiveAppId ? Paths.getAppName(effectiveAppId, desktopEntry) : "Unknown"
    readonly property string windowTitle: shownWindow.title || "(Unnamed)"
    readonly property var tooltipRows: {
        pill._desktopEntriesUpdateTrigger;
        pill._appIdSubstitutionsTrigger;
        return windows.map(w => tooltipRow(w));
    }
    readonly property real visualWidth: pill.compactMode ? pill.iconCellSize : (pill.iconCellSize + Theme.spacingXS + 120)
    readonly property real iconLeftMargin: pill.compactMode ? Math.round((visualWidth - pill.iconSize) / 2) : Theme.spacingXS

    width: pill.isVerticalOrientation ? pill.barThickness : visualWidth
    height: pill.isVerticalOrientation ? pill.iconCellSize : pill.barThickness

    function tooltipRow(window) {
        const moddedAppId = Paths.moddedAppId(window.appId || "");
        const entry = moddedAppId ? DesktopEntries.heuristicLookup(moddedAppId) : null;
        const name = moddedAppId ? Paths.getAppName(moddedAppId, entry) : "Unknown";
        return {
            "window": window,
            "icon": moddedAppId ? Paths.getAppIcon(moddedAppId, entry) : "",
            "text": name + " • " + (window.title || "(Unnamed)"),
            "shown": windowCount > 1 && window === shownWindow
        };
    }

    Component.onDestruction: {
        if (pill.hoveredItem === appItem)
            pill.hoveredItem = null;
        if (pill.tooltipItem === appItem)
            pill.hideTooltip();
    }

    Rectangle {
        id: visualContent
        width: appItem.visualWidth
        height: pill.iconCellSize
        anchors.centerIn: parent
        radius: Theme.cornerRadius
        color: {
            if (appItem.focusedWindow)
                return mouseArea.containsMouse ? Theme.primarySelected : Theme.withAlpha(Theme.primary, 0.45);
            return mouseArea.containsMouse ? BlurService.hoverColor(Theme.widgetBaseHoverColor) : Theme.withAlpha(BlurService.hoverColor(Theme.widgetBaseHoverColor), 0);
        }

        IconImage {
            id: iconImg
            anchors.left: parent.left
            anchors.leftMargin: appItem.iconLeftMargin
            anchors.verticalCenter: parent.verticalCenter
            width: pill.iconSize
            height: pill.iconSize
            source: appItem.effectiveAppId ? Paths.getAppIcon(appItem.effectiveAppId, appItem.desktopEntry) : ""
            smooth: true
            mipmap: true
            asynchronous: true
            visible: status === Image.Ready
            layer.enabled: appItem.appId === "org.quickshell" || appItem.appId === "com.danklinux.dms"
            layer.smooth: true
            layer.mipmap: true
            layer.effect: MultiEffect {
                saturation: 0
                colorization: 1
                colorizationColor: Theme.primary
            }
        }

        DankIcon {
            anchors.left: parent.left
            anchors.leftMargin: appItem.iconLeftMargin
            anchors.verticalCenter: parent.verticalCenter
            size: pill.iconSize
            name: "sports_esports"
            color: Theme.widgetTextColor
            visible: !iconImg.visible && Paths.isSteamApp(appItem.effectiveAppId)
        }

        StyledText {
            anchors.horizontalCenter: iconImg.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            visible: !iconImg.visible && !Paths.isSteamApp(appItem.effectiveAppId)
            text: appItem.effectiveAppId ? appItem.appName.charAt(0).toUpperCase() : "?"
            font.pixelSize: 10
            color: Theme.widgetTextColor
        }

        Rectangle {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: pill.compactMode ? -2 : 2
            anchors.bottomMargin: -2
            width: 14
            height: 14
            radius: 7
            color: Theme.primary
            visible: appItem.windowCount > 1
            z: 10

            StyledText {
                anchors.centerIn: parent
                text: appItem.windowCount > 9 ? "9+" : appItem.windowCount
                font.pixelSize: 9
                color: Theme.surface
            }
        }

        StyledText {
            anchors.left: iconImg.right
            anchors.leftMargin: Theme.spacingXS
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacingS
            anchors.verticalCenter: parent.verticalCenter
            visible: !pill.compactMode
            text: appItem.windowTitle
            font.pixelSize: Theme.barTextSize(pill.barThickness, pill.barConfig?.fontScale, pill.barConfig?.maximizeWidgetText)
            color: Theme.widgetTextColor
            elide: Text.ElideRight
            maximumLineCount: 1
        }

        DankRipple {
            id: itemRipple
            cornerRadius: Theme.cornerRadius
        }
    }

    // Reaches past the item to the bar's edges, so a click in the bar padding still lands.
    MouseArea {
        id: mouseArea
        y: pill.isVerticalOrientation ? 0 : -pill.topMargin
        x: pill.isVerticalOrientation ? -pill.leftMargin : 0
        width: parent.width + (pill.isVerticalOrientation ? pill.leftMargin + pill.rightMargin : 0)
        height: parent.height + (pill.isVerticalOrientation ? 0 : pill.topMargin + pill.bottomMargin)
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onPressed: mouse => {
            const pos = mapToItem(visualContent, mouse.x, mouse.y);
            itemRipple.trigger(pos.x, pos.y);
        }
        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                if (appItem.windowCount > 1) {
                    const focusedIndex = appItem.windows.indexOf(appItem.focusedWindow);
                    CompositorService.activateToplevel(focusedIndex === -1 ? appItem.shownWindow : appItem.windows[(focusedIndex + 1) % appItem.windowCount]);
                } else {
                    CompositorService.toggleToplevel(appItem.shownWindow);
                }
            } else if (mouse.button === Qt.RightButton) {
                pill.showContextMenu(appItem, appItem.shownWindow);
            } else if (mouse.button === Qt.MiddleButton) {
                if (typeof appItem.shownWindow.close === "function")
                    appItem.shownWindow.close();
            }
        }
        onEntered: {
            pill.hoveredItem = appItem;
            pill.showTooltip(appItem);
        }
        onExited: {
            if (pill.hoveredItem === appItem)
                pill.hoveredItem = null;
        }
    }
}
