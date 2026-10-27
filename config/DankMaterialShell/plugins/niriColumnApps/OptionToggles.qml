// One toggle per widget option, showing `values` and reporting each change
// through optionToggled.

import QtQuick
import qs.DCommon.Widgets
import "PluginOptions.js" as PluginOptions

Column {
    id: root

    property var values: PluginOptions.values({})

    signal optionToggled(string key, bool value)

    width: parent.width

    Repeater {
        model: PluginOptions.options

        DToggle {
            required property var modelData

            text: modelData.label
            description: modelData.description
            checked: root.values[modelData.key]
            onToggled: isChecked => root.optionToggled(modelData.key, isChecked)
        }
    }
}
