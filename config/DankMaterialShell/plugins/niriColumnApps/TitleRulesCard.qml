// Edits the window title rules that every copy of the widget applies, showing
// `rules` and reporting each change through edited.

import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.DCommon.Widgets
import qs.Services
import "PluginOptions.js" as PluginOptions

StyledRect {
    id: root

    property var rules: []

    signal edited(var updatedRules)

    function updateRule(index, key, value) {
        if (!rules[index] || rules[index][key] === value)
            return;
        const updatedRules = rules.slice();
        updatedRules[index] = Object.assign({}, rules[index], {
            [key]: value
        });
        edited(updatedRules);
    }

    function pickColor(index) {
        const picker = PopoutService.colorPickerModal;
        picker.selectedColor = rules[index].color || Theme.primary;
        picker.pickerTitle = "Border color";
        picker.onColorSelectedCallback = selectedColor => updateRule(index, "color", selectedColor.toString());
        picker.show();
    }

    height: rulesColumn.implicitHeight + Theme.spacingM * 2
    radius: Theme.cornerRadius
    color: Theme.chipSurface

    Column {
        id: rulesColumn
        anchors.fill: parent
        anchors.margins: Theme.spacingM
        spacing: Theme.spacingS

        RowLayout {
            width: parent.width

            StyledText {
                Layout.fillWidth: true
                text: "Title rules"
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Theme.fontWeightMedium
                color: Theme.surfaceText
            }

            DActionButton {
                iconName: "add"
                tooltipText: "Add rule"
                onClicked: root.edited(root.rules.concat([PluginOptions.blankTitleRule]))
            }
        }

        StyledText {
            width: parent.width
            text: "Every rule whose regex matches a window's title applies, and the first one to set a field wins that field. The icon is a theme icon name or an image path, and the color draws a border around the item."
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceVariantText
            wrapMode: Text.WordWrap
        }

        Repeater {
            // The model is the count because every keystroke saves. An array
            // model would rebuild the rows and drop focus from the field.
            model: root.rules.length

            RowLayout {
                id: ruleRow

                required property int index
                readonly property var rule: Object.assign({}, PluginOptions.blankTitleRule, root.rules[index])

                width: parent.width
                spacing: Theme.spacingS

                DTextField {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    labelText: "Title regex"
                    text: ruleRow.rule.pattern
                    isError: text !== "" && PluginOptions.compilePattern(text, ruleRow.rule.ignoreCase) === null
                    onTextEdited: root.updateRule(ruleRow.index, "pattern", text)
                }

                DActionButton {
                    iconName: "match_case"
                    tooltipText: "Ignore case"
                    iconColor: ruleRow.rule.ignoreCase ? Theme.primary : Theme.surfaceVariantText
                    backgroundColor: ruleRow.rule.ignoreCase ? Theme.primarySelected : "transparent"
                    onClicked: root.updateRule(ruleRow.index, "ignoreCase", !ruleRow.rule.ignoreCase)
                }

                DTextField {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    labelText: "Icon"
                    text: ruleRow.rule.icon
                    onTextEdited: root.updateRule(ruleRow.index, "icon", text)
                }

                DColorButton {
                    swatchColor: ruleRow.rule.color || "transparent"
                    tooltipText: "Border color"
                    onClicked: root.pickColor(ruleRow.index)
                }

                DActionButton {
                    iconName: "format_color_reset"
                    tooltipText: "Remove border"
                    enabled: !!ruleRow.rule.color
                    onClicked: root.updateRule(ruleRow.index, "color", "")
                }

                DActionButton {
                    iconName: "delete"
                    iconColor: Theme.error
                    tooltipText: "Remove rule"
                    onClicked: root.edited(root.rules.filter((rule, ruleIndex) => ruleIndex !== ruleRow.index))
                }
            }
        }
    }
}
