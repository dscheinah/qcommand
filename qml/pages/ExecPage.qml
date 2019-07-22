import QtQuick 2.0
import Sailfish.Silica 1.0
import qCommand 1.0
import '../src'

Dialog {
    id: dialog
    canAccept: command && (!root.checked || password.acceptableInput)
    allowedOrientations: Orientation.All

    property CommandEngine engine
    property string name
    property string command
    property int has_output

    onAccepted: {
        if (root.checked) {
            engine.execAsRoot(command, has_output, password.text)
        } else {
            engine.exec(command, has_output)
        }
    }

    DevelSu {
        id: checker
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height

        Column {
            id: content
            width: parent.width

            DialogHeader {
                title: qsTr('Run command')
            }

            TextArea {
                width: parent.width
                label: name
                labelVisible: true
                text: command || qsTr('none')
                readOnly: true
                font.italic: !command
            }

            TextSwitch {
                id: root
                text: qsTr('Run as root')
                enabled: checker.available
                onCheckedChanged: {
                    if (checked) {
                        password.focus = true
                    }
                }
            }

            PasswordField {
                id: password
                label: qsTr('Password')
                placeholderText: qsTr('Password')
                visible: root.checked
                validator: checker

                EnterKey.iconSource: 'image://theme/icon-m-enter-accept'
                EnterKey.onClicked: {
                    dialog.accept()
                }
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
