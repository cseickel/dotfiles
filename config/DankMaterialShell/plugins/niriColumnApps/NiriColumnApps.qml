// A copy of DMS's RunningApps bar widget that shows one item per Niri column
// instead of one per window. The stock widget lives at
// /usr/share/quickshell/dms/Modules/DankBar/Widgets/RunningApps.qml.
//
// The root is a BasePill, like the stock widget, so the bar hosts it the same
// way: WidgetHost binds the bar properties onto whatever item the plugin loads.

import QtQuick
import Quickshell
import qs.Common
import qs.Modules.Plugins
import qs.Services

BasePill {
    id: root

    enableBackgroundHover: false
    enableCursor: false
    section: "left"

    property var widgetData: null
    property var hoveredItem: null
    // The bar item whose windows the open tooltip lists. It stays set while the
    // pointer moves off the item and onto the tooltip.
    property var tooltipItem: null
    readonly property bool isAutoHideBar: barConfig?.autoHide ?? false

    readonly property real effectiveBarThickness: {
        if (barThickness > 0 && barSpacing > 0)
            return barThickness + barSpacing;
        return Theme.barThickness(barConfig?.innerPadding ?? 4, CompositorService.getScreenScale(parentScreen)) + (barConfig?.spacing ?? 4);
    }

    readonly property real minTooltipY: {
        if (!parentScreen || !isVerticalOrientation || isAutoHideBar)
            return 0;
        return parentScreen.y > 0 ? effectiveBarThickness : 0;
    }

    property int _desktopEntriesUpdateTrigger: 0
    property int _toplevelsUpdateTrigger: 0
    property int _appIdSubstitutionsTrigger: 0

    readonly property bool _currentWorkspace: SettingsData.getPluginSetting("nirColumnApps", "currentWorkspace", false)
    readonly property bool _currentMonitor: SettingsData.getPluginSetting("niriColumnApps", "currentMonitor", true)
    readonly property bool compactMode: SettingsData.getPluginSetting("niriColumnApps", "compactMode", false)

    readonly property var sortedToplevels: {
        _toplevelsUpdateTrigger;
        let toplevels = CompositorService.sortedToplevels;
        if (!toplevels || toplevels.length === 0)
            return [];

        if (_currentWorkspace)
            toplevels = CompositorService.filterCurrentWorkspace(toplevels, parentScreen?.name) || [];
        if (_currentMonitor)
            toplevels = CompositorService.filterCurrentDisplay(toplevels, parentScreen?.name) || [];
        return toplevels;
    }

    // Niri window id to the order it was last focused in. Niri's IPC does not
    // report which window is active inside each column, so the plugin tracks it.
    property var focusOrder: ({})
    property int _focusCount: 0

    function recordFocus(windowId) {
        if (windowId === null || windowId === undefined)
            return;
        _focusCount++;
        focusOrder = Object.assign({}, focusOrder, {
            [windowId]: _focusCount
        });
    }

    function mostRecentlyFocused(windows) {
        return windows.reduce((best, w) => (focusOrder[w.niriWindowId] ?? 0) > (focusOrder[best.niriWindowId] ?? 0) ? w : best);
    }

    Component.onCompleted: recordFocus(NiriService.lastFocusedWindowId)

    Connections {
        target: NiriService
        function onLastFocusedWindowIdChanged() {
            root.recordFocus(NiriService.lastFocusedWindowId);
        }
    }

    // sortedToplevels is ordered by workspace, column, then row, so each group's
    // windows are in row order. A floating window has no column and gets its own group.
    // A group shows its focused window, else the one focused most recently, else the top one.
    readonly property var columnGroups: {
        const niriWindows = new Map(NiriService.windows.map(w => [w.id, w]));
        const groups = new Map();
        sortedToplevels.forEach((toplevel, index) => {
            const pos = niriWindows.get(toplevel.niriWindowId)?.layout?.pos_in_scrolling_layout;
            const key = pos ? toplevel.niriWorkspaceId + ":" + pos[0] : (toplevel.niriWindowId !== undefined ? "window:" + toplevel.niriWindowId : "toplevel:" + index);
            if (!groups.has(key))
                groups.set(key, {
                    "key": key,
                    "windows": []
                });
            groups.get(key).windows.push(toplevel);
        });
        return Array.from(groups.values(), group => Object.assign(group, {
            "shownWindow": group.windows.find(w => w.activated) ?? mostRecentlyFocused(group.windows)
        }));
    }

    readonly property int iconSize: Theme.barIconSize(barThickness, undefined, barConfig?.maximizeWidgetIcons, barConfig?.iconScale)
    readonly property real iconCellSize: iconSize + 6

    visible: columnGroups.length > 0

    Connections {
        target: CompositorService
        function onToplevelsChanged() {
            root._toplevelsUpdateTrigger++;
        }
    }

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() {
            root._desktopEntriesUpdateTrigger++;
        }
    }

    Connections {
        target: SettingsData
        function onAppIdSubstitutionsChanged() {
            root._appIdSubstitutionsTrigger++;
        }
    }

    ScriptModel {
        id: columnModel
        values: root.columnGroups
        objectProp: "key"
    }

    property real scrollAccumulator: 0
    readonly property real touchpadThreshold: 500

    function focusAdjacentWindow(windows, step) {
        const current = windows.findIndex(w => w.activated);
        const next = current === -1 ? (step > 0 ? 0 : windows.length - 1) : Math.max(0, Math.min(windows.length - 1, current + step));
        CompositorService.activateToplevel(windows[next]);
    }

    onWheel: function (wheelEvent) {
        wheelEvent.accepted = true;
        const windows = sortedToplevels.filter(w => !w.skipSwitcher);
        if (windows.length < 2)
            return;

        const deltaY = wheelEvent.angleDelta.y;
        const isMouseWheel = Math.abs(deltaY) >= 120 && (Math.abs(deltaY) % 120) === 0;
        if (isMouseWheel) {
            focusAdjacentWindow(windows, deltaY < 0 ? 1 : -1);
            return;
        }

        scrollAccumulator += deltaY;
        if (Math.abs(scrollAccumulator) < touchpadThreshold)
            return;
        focusAdjacentWindow(windows, scrollAccumulator < 0 ? 1 : -1);
        scrollAccumulator = 0;
    }

    function barPosition() {
        return axis?.edge === "left" ? 2 : (axis?.edge === "right" ? 3 : (axis?.edge === "top" ? 0 : 1));
    }

    function sideAnchorX() {
        return axis?.edge === "left" ? (barThickness + barSpacing + Theme.spacingXS) : (parentScreen.width - barThickness - barSpacing - Theme.spacingXS);
    }

    function tooltipAnchor(item) {
        if (isVerticalOrientation) {
            const localPos = item.mapToItem(null, item.width / 2, item.height / 2);
            return {
                "x": sideAnchorX(),
                "y": localPos.y + minTooltipY,
                "screen": parentScreen,
                "side": axis?.edge === "left" ? "right" : "left"
            };
        }
        const localPos = item.mapToItem(null, item.width / 2, item.height);
        const barGap = barThickness + barSpacing + Theme.spacingXS;
        if (axis?.edge === "bottom") {
            const screenHeight = parentScreen ? parentScreen.height : Screen.height;
            return {
                "x": localPos.x,
                "y": screenHeight - barGap,
                "screen": parentScreen,
                "side": "above"
            };
        }
        return {
            "x": localPos.x,
            "y": barGap,
            "screen": parentScreen,
            "side": "below"
        };
    }

    function showTooltip(item) {
        tooltipItem = item;
        tooltipLoader.active = true;
        if (tooltipLoader.item)
            tooltipLoader.item.show(tooltipAnchor(item));
    }

    function hideTooltip() {
        tooltipItem = null;
        if (tooltipLoader.item)
            tooltipLoader.item.hide();
        tooltipLoader.active = false;
    }

    function showContextMenu(item, window) {
        hideTooltip();
        contextMenuLoader.active = true;
        const menu = contextMenuLoader.item;
        if (!menu)
            return;
        menu.currentWindow = window;
        menu.triggerBarConfig = barConfig;
        menu.triggerBarPosition = barPosition();
        menu.triggerBarThickness = barThickness;
        menu.triggerBarSpacing = barSpacing;
        if (isVerticalOrientation) {
            const localPos = item.mapToItem(null, item.width / 2, item.height / 2);
            menu.showAt(sideAnchorX(), localPos.y + minTooltipY, true, axis?.edge);
            return;
        }
        const localPos = item.mapToItem(null, item.width / 2, 0);
        const screenHeight = parentScreen ? parentScreen.height : Screen.height;
        const yPos = axis?.edge === "bottom" ? (screenHeight - barThickness - barSpacing - menu.menuHeight - Theme.spacingXS) : (barThickness + barSpacing + Theme.spacingXS);
        menu.showAt(localPos.x, yPos, false, axis?.edge);
    }

    content: Component {
        Item {
            implicitWidth: layoutLoader.item ? layoutLoader.item.implicitWidth : 0
            implicitHeight: layoutLoader.item ? layoutLoader.item.implicitHeight : 0

            Loader {
                id: layoutLoader
                anchors.centerIn: parent
                sourceComponent: root.isVerticalOrientation ? columnLayout : rowLayout
            }
        }
    }

    Component {
        id: rowLayout
        Row {
            spacing: Theme.spacingXS
            Repeater {
                model: columnModel
                delegate: ColumnAppItem {
                    pill: root
                }
            }
        }
    }

    Component {
        id: columnLayout
        Column {
            spacing: Theme.spacingXS
            Repeater {
                model: columnModel
                delegate: ColumnAppItem {
                    pill: root
                }
            }
        }
    }

    Loader {
        id: tooltipLoader
        active: false
        sourceComponent: ColumnTooltip {
            rows: root.tooltipItem ? root.tooltipItem.tooltipRows : []
            onWindowClicked: window => {
                CompositorService.activateToplevel(window);
                root.hideTooltip();
            }
        }
    }

    // The pointer crosses a gap between the bar and the tooltip, so hiding waits
    // long enough for it to arrive.
    Timer {
        interval: 300
        running: tooltipLoader.active && !root.hoveredItem && !(tooltipLoader.item?.pointerInside ?? false)
        onTriggered: root.hideTooltip()
    }

    Loader {
        id: contextMenuLoader
        active: false
        sourceComponent: WindowContextMenu {
            parentScreen: root.parentScreen
            onDismissed: contextMenuLoader.active = false
        }
    }
}
