// Edits the window rules that every copy of the widget applies, showing `rules`
// and reporting each change through edited.

import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.DCommon.Widgets
import qs.Modals.FileBrowser
import qs.Services
import "PluginOptions.js" as PluginOptions

StyledRect {
    id: root

    property var rules: []
    // The view that scrolls this card, so dragging a rule to its edge scrolls it.
    property var flickable: null

    readonly property var matchFields: [
        {
            "text": "AppId",
            "field": "appId"
        },
        {
            "text": "Title",
            "field": "title"
        }
    ]

    signal edited(var updatedRules)

    function updateRule(index, key, value) {
        if (!rules[index] || PluginOptions.withDefaults(rules[index])[key] === value)
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

    function pickIcon(index) {
        iconBrowser.ruleIndex = index;
        iconBrowser.open();
    }

    component RuleLine: RowLayout {
        property alias label: lineLabel.text

        width: parent.width
        spacing: Theme.spacingS

        StyledText {
            id: lineLabel
            Layout.preferredWidth: Theme.fontSizeSmall * 5
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceVariantText
        }
    }

    height: rulesColumn.implicitHeight + Theme.spacingM * 2
    radius: Theme.cornerRadius
    color: Theme.chipSurface

    FileBrowserModal {
        id: iconBrowser

        property int ruleIndex

        browserTitle: "Select rule icon"
        bucket: "logo"
        filters: ["*.svg", "*.png", "*.jpg", "*.jpeg", "*.webp"]
        onAccepted: paths => root.updateRule(ruleIndex, "icon", Paths.shortenHome(paths[0]))
    }

    Column {
        id: rulesColumn
        anchors.fill: parent
        anchors.margins: Theme.spacingM
        spacing: Theme.spacingS
        // The file browser is its own window, and a rule moved while it is open
        // would shift the index it writes to.
        enabled: !iconBrowser.visible

        RowLayout {
            width: parent.width

            StyledText {
                Layout.fillWidth: true
                text: "Window rules"
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Theme.fontWeightMedium
                color: Theme.surfaceText
            }

            DActionButton {
                iconName: "add"
                tooltipText: "Add rule"
                onClicked: root.edited(root.rules.concat([PluginOptions.blankWindowRule]))
            }
        }

        StyledText {
            width: parent.width
            text: "Each rule's regex tests either the window's title or its app ID, and every rule that matches applies. The first matching rule that sets an icon provides the icon, and the first that sets a color provides the color. The icon is a theme icon name or an image path, and the color draws a border around the item."
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceVariantText
            wrapMode: Text.WordWrap
        }

        DReorderList {
            id: ruleList

            spacing: Theme.spacingL
            flickable: root.flickable
            // The model is the count because every keystroke saves. An array
            // model would rebuild the rows and drop focus from the field.
            model: root.rules.length
            onReordered: indices => {
                const reorderedRules = indices.map(index => root.rules[index]);
                // A count model never triggers the list's own reset, and without
                // one the rows would animate back to their old slots.
                ruleList.reset();
                root.edited(reorderedRules);
            }

            delegate: Rectangle {
                id: ruleRow

                required property int index
                readonly property var rule: PluginOptions.withDefaults(root.rules[index])
                readonly property bool dragging: ruleList.draggingIndex === index

                function focusHandle(reason) {
                    handle.forceActiveFocus(reason);
                }

                height: ruleContent.implicitHeight
                radius: Theme.cornerRadius
                color: dragging ? Theme.blend(root.color, Theme.onSurface, Theme.stateLayerDrag) : "transparent"
                z: dragging ? 100 : 0

                Behavior on y {
                    enabled: ruleList.animateLayout && !ruleRow.dragging && !SettingsData.reduceMotion && Theme.currentAnimationSpeed !== SettingsData.AnimationSpeed.None
                    NumberAnimation {
                        duration: Theme.expressiveDurations.expressiveDefaultSpatial
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Theme.expressiveCurves.expressiveFastSpatial
                    }
                }

                RowLayout {
                    id: ruleContent

                    width: parent.width
                    spacing: Theme.spacingS

                    DDragHandle {
                        id: handle

                        Layout.alignment: Qt.AlignTop
                        coordinateItem: ruleList
                        label: ruleRow.rule.pattern
                        enabled: ruleList.count > 1
                        dragging: ruleRow.dragging
                        canMoveUp: ruleRow.index > 0
                        canMoveDown: ruleRow.index < ruleList.count - 1
                        onStarted: position => ruleList.begin(ruleRow.index, position)
                        onMoved: position => ruleList.dragTo(position)
                        onFinished: ruleList.finish()
                        onDragCanceled: ruleList.cancel()
                        onMoveRequested: delta => ruleList.move(ruleRow.index, delta)
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: Theme.spacingXS

                        RuleLine {
                            label: "Pattern"

                            DTextField {
                                Layout.fillWidth: true
                                text: ruleRow.rule.pattern
                                isError: text !== "" && PluginOptions.compilePattern(text, ruleRow.rule.ignoreCase) === null
                                onTextEdited: root.updateRule(ruleRow.index, "pattern", text)
                            }

                            DButtonGroup {
                                size: "small"
                                checkEnabled: false
                                model: root.matchFields
                                currentIndex: root.matchFields.findIndex(option => option.field === ruleRow.rule.field)
                                onSelectionChanged: (index, selected) => {
                                    if (selected)
                                        root.updateRule(ruleRow.index, "field", root.matchFields[index].field);
                                }
                            }

                            DActionButton {
                                iconName: "match_case"
                                tooltipText: "Ignore case"
                                iconColor: ruleRow.rule.ignoreCase ? Theme.primary : Theme.surfaceVariantText
                                backgroundColor: ruleRow.rule.ignoreCase ? Theme.primarySelected : "transparent"
                                onClicked: root.updateRule(ruleRow.index, "ignoreCase", !ruleRow.rule.ignoreCase)
                            }

                            DActionButton {
                                iconName: "delete"
                                iconColor: Theme.error
                                tooltipText: "Remove rule"
                                onClicked: root.edited(root.rules.filter((rule, ruleIndex) => ruleIndex !== ruleRow.index))
                            }
                        }

                        RuleLine {
                            label: "Icon"

                            DTextField {
                                Layout.fillWidth: true
                                text: ruleRow.rule.icon
                                onTextEdited: root.updateRule(ruleRow.index, "icon", text)
                            }

                            DActionButton {
                                iconName: "folder_open"
                                tooltipText: "Choose a file"
                                onClicked: root.pickIcon(ruleRow.index)
                            }
                        }

                        RuleLine {
                            label: "Border"

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

                            Item {
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }
    }
}
