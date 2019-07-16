import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

Dialog {
    property int rowid
    property string name
    property string command

    onDone: {
       if (result == DialogResult.Accepted) {
           name = nameField.text
           command = commandField.text
       }
    }

    Column {
        width: parent.width

        DialogHeader {
            title: rowid ? qsTr('edit command') : qsTr('add command')
        }

        TextField {
            id: nameField
            width: parent.width
            placeholderText: qsTr('name')
            label: qsTr('name')
            text: name

            EnterKey.enabled: text.length > 0
            EnterKey.iconSource: 'image://theme/icon-m-enter-next'
            EnterKey.onClicked: commandField.focus = true
        }

        TextArea {
            id: commandField
            width: parent.width
            placeholderText: qsTr('command')
            label: qsTr('command')
            inputMethodHints: Qt.ImhNone
            text: command
        }
    }
}
