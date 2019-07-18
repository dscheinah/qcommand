import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: dialog
    canAccept: command

    property string name
    property string command
    property int has_output

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height

        Column {
            id: content
            width: parent.width

            DialogHeader {
                title: qsTr('run command')
            }

            TextArea {
                width: parent.width
                label: name
                labelVisible: true
                text: command || qsTr('none')
                readOnly: true
                font.italic: !command
            }
        }

        VerticalScrollDecorator {
        }
    }

    Component.onCompleted: {
        if (has_output) {
            dialog.acceptDestination = Qt.resolvedUrl('ResultPage.qml')
            dialog.acceptDestinationAction = PageStackAction.Push
        }
    }
}
