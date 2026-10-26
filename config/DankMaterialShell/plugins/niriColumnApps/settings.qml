import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "niriColumnApps"

    ToggleSetting {
        settingKey: "currentMonitor"
        label: "Current display only"
        description: "Show only windows on the monitor this bar is on"
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "currentWorkspace"
        label: "Current workspace only"
        description: "Show only windows on the active workspace"
        defaultValue: false
    }

    ToggleSetting {
        settingKey: "compactMode"
        label: "Compact mode"
        description: "Show icons only"
        defaultValue: false
    }
}
