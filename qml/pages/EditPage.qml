import QtQuick 2.0
import Sailfish.Silica 1.0
import qCommand 1.0
import '../src'

Dialog {
    allowedOrientations: Orientation.All
    canAccept: nameField.text

    property Database database
    property int rowid
    property string name
    property string command
    property int has_output
    property int is_template
    property string cover_group
    property int is_interactive
    property int run_as_root

    onDone: {
        if (result === DialogResult.Accepted) {
            name = nameField.text
            command = commandField.text
            has_output = hasOutputField.checked
            is_template = isTemplateField.checked
            is_interactive = isInteractiveField.checked
            run_as_root = runAsRootField.checked
            groupField.updateGroup(name)
            cover_group = groupField.checked ? groupField.group : ''
        }
    }

    Developer {
        id: checker
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height
        bottomMargin: commandField.panel.height

        Column {
            id: content
            width: parent.width

            DialogHeader {
                title: rowid ? qsTr('Edit command') : qsTr('Add command')
            }

            TextField {
                id: nameField
                width: parent.width
                placeholderText: qsTr('Name')
                label: qsTr('Name')
                text: name
                focus: !rowid

                onTextChanged: {
                    groupField.updateGroup(text)
                }

                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: 'image://theme/icon-m-enter-next'
                EnterKey.onClicked: {
                    commandField.focus = true
                }
            }

            TextSwitch {
                id: groupField
                checked: cover_group
                enabled: group
                text: qsTr('Use as cover action')

                property string group: cover_group

                function updateGroup(name) {
                    var split = name.trim().split(/\s+/)
                    if (split.length > 1) {
                        group = split[0]
                    } else {
                        group = ''
                        description = qsTr('hint_group_disabled')
                    }
                    updateLabel(name)
                }

                function updateLabel(name) {
                    if (!group) {
                        description = qsTr('hint_group_disabled')
                    } else {
                        description = group
                        busy = true
                        database.readCoverPosition(
                            {
                                name: name,
                                cover_group: group,
                                rowid: rowid,
                            }, function(index, max, name) {
                                if (name !== nameField.text) {
                                    return
                                }
                                description = '%1 (%2/%3)'.arg(group).arg(index).arg(max)
                                busy = false
                            }
                        )
                    }
                }

                Component.onCompleted: {
                    updateLabel(name)
                }
            }

            CodeField {
                id: commandField
                width: parent.width
                label: qsTr('Command')
                text: command
            }

            TextSwitch {
                id: isTemplateField
                checked: is_template
                text: qsTr('Editable before execution')
            }

            TextSwitch {
                id: runAsRootField
                checked: run_as_root
                text: qsTr('Run as root')
                description: enabled ? '' : qsTr('hint_root_disabled')
                enabled: checker.develSuAvailable
            }

            TextSwitch {
                id: isInteractiveField
                checked: is_interactive
                text: qsTr('Interactive')
                description: enabled ? qsTr('hint_interactive') : qsTr('hint_interactive_disabled')
                enabled: checker.fingertermAvailable
            }

            TextSwitch {
                id: hasOutputField
                checked: has_output
                text: qsTr('Show output')
                description: enabled ? qsTr('hint_output') : qsTr('hint_output_disabled')
                enabled: !isInteractiveField.checked || !isInteractiveField.enabled
            }
        }

        VerticalScrollDecorator {
        }
    }
}
