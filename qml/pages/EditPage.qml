import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    allowedOrientations: Orientation.All

    property int rowid
    property string name
    property string command
    property int has_output

    onDone: {
       if (result == DialogResult.Accepted) {
           name = nameField.text
           command = commandField.text
           has_output = hasOutputField.checked
       }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height

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

                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: 'image://theme/icon-m-enter-next'
                EnterKey.onClicked: {
                    commandField.focus = true
                }
            }

            TextArea {
                id: commandField
                width: parent.width
                placeholderText: qsTr('Command')
                label: qsTr('Command')
                text: command
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
            }

            TextSwitch {
                id: hasOutputField
                checked: has_output
                text: qsTr('Show output')
            }
        }

        VerticalScrollDecorator {
        }
    }
}
