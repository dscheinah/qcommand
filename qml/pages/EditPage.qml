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

    onDone: {
        if (result == DialogResult.Accepted) {
            name = nameField.text
            command = commandField.text
            has_output = hasOutputField.checked
            is_template = isTemplateField.checked
            cover_group = groupField.checked ? groupField.group : ''
            is_interactive = isInteractiveField.checked
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
                    }
                    updateLabel(name)
                }

                function updateLabel(name) {
                    if (!group) {
                        groupDetails.text = ''
                    } else {
                        groupDetails.text = group
                        busy.running = true
                        database.readCoverPosition(
                            {
                                name: name,
                                cover_group: group,
                                rowid: rowid,
                            }, function(index, max) {
                                groupDetails.text = '%1 (%2/%3)'.arg(group).arg(index).arg(max)
                                busy.running = false
                            }
                        )
                    }
                }

                Component.onCompleted: {
                    updateLabel(name)
                }
            }

            Row {
                width: parent.width

                Item {
                    width: Theme.itemSizeExtraSmall
                    height: Theme.itemSizeExtraSmall

                    BusyIndicator {
                        id: busy
                        size: BusyIndicatorSize.Small
                        running: false
                        x: Theme.horizontalPageMargin - Theme.paddingSmall
                    }
                }

                Label {
                    id: groupDetails
                    font.pixelSize: Theme.fontSizeExtraSmall
                    width: parent.width - Theme.itemSizeExtraSmall - Theme.horizontalPageMargin * 2
                    wrapMode: Label.Wrap
                }
            }

            Row {
                width: parent.width
                height: Theme.paddingSmall
            }

            CodeField {
                id: commandField
                width: parent.width
                label: qsTr('Command')
                text: command
            }

            TextSwitch {
                id: isInteractiveField
                checked: is_interactive
                text: qsTr('Interactive')
                enabled: checker.fingertermAvailable
            }

            TextSwitch {
                id: hasOutputField
                checked: has_output
                text: qsTr('Show output')
                enabled: !isInteractiveField.checked && isInteractiveField.enabled
            }

            TextSwitch {
                id: isTemplateField
                checked: is_template
                text: qsTr('Editable before execution')
            }
        }

        VerticalScrollDecorator {
        }
    }
}
