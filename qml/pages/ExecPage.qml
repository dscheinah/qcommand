import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

Dialog {
    property string name
    property string command

    Column {
        width: parent.width

        DialogHeader {
            title: qsTr('run command')
        }

        TextArea {
            label: name
            labelVisible: true
            text: command
            readOnly: true
            width: parent.width
        }
    }
}
