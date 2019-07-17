import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    canAccept: command
    acceptDestination: Qt.resolvedUrl('ResultPage.qml')
    acceptDestinationAction: PageStackAction.Push

    property string name
    property string command

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
}
