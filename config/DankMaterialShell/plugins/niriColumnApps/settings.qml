// The plugin's settings page, with one card of options for each copy of the
// widget on each bar.

import QtQuick
import qs.Common
import qs.DCommon.Widgets
import qs.Modules.Plugins
import "PluginOptions.js" as PluginOptions

PluginSettings {
    id: root
    pluginId: PluginOptions.pluginId

    // Returns every bar entry for this widget as {barId, section, index, entry,
    // title}. The title is the bar's name, numbered when the bar holds the
    // widget more than once.
    function widgetCopies() {
        const copies = [];
        SettingsData.barConfigs.forEach((bar, barIndex) => {
            const barName = bar.name || ("Bar " + (barIndex + 1));
            const barCopies = [];
            for (const section of ["left", "center", "right"]) {
                (bar[section + "Widgets"] ?? []).forEach((entry, index) => {
                    const isString = typeof entry === "string";
                    if ((isString ? entry : entry.id) !== PluginOptions.pluginId)
                        return;
                    barCopies.push({
                        "barId": bar.id,
                        "section": section,
                        "index": index,
                        "entry": isString ? {} : entry
                    });
                });
            }
            barCopies.forEach((copy, n) => copies.push(Object.assign(copy, {
                    "title": barCopies.length > 1 ? barName + " (" + (n + 1) + ")" : barName
                })));
        });
        return copies;
    }

    StyledText {
        width: parent.width
        visible: copiesRepeater.count === 0
        text: "Add Niri Column Apps to a bar in Bar widgets, and its options will appear here."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    Column {
        width: parent.width
        spacing: Theme.spacingM

        Repeater {
            id: copiesRepeater
            model: root.widgetCopies()

            StyledRect {
                required property var modelData

                width: parent.width
                height: copyColumn.implicitHeight + Theme.spacingM * 2
                radius: Theme.cornerRadius
                color: Theme.chipSurface

                Column {
                    id: copyColumn
                    anchors.fill: parent
                    anchors.margins: Theme.spacingM
                    spacing: Theme.spacingS

                    StyledText {
                        width: parent.width
                        text: modelData.title
                        font.pixelSize: Theme.fontSizeLarge
                        font.weight: Theme.fontWeightMedium
                        color: Theme.surfaceText
                        elide: Text.ElideRight
                    }

                    OptionToggles {
                        values: PluginOptions.values(modelData.entry)
                        onOptionToggled: (key, value) => SettingsData.updateBarWidget(modelData.barId, modelData.section, modelData.index, {
                                [key]: value
                            })
                    }
                }
            }
        }
    }
}
