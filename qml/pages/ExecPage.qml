import QtQuick 2.0
import Sailfish.Silica 1.0
import qCommand 1.0
import '../src'

Dialog {
    id: dialog
    canAccept: command && (is_interactive || !root.checked || password.acceptableInput)
    allowedOrientations: Orientation.All

    property CommandEngine engine
    property string name
    property string command
    property int has_output
    property int is_template
    property int is_interactive

    onDone: {
        commandField.focus = false
    }

    onAccepted: {
        if (!checker.fingertermAvailable)  {
            is_interactive = false
        }
        if (root.checked && checker.develSuAvailable) {
            if (is_interactive) {
                engine.execAsRootInteractive(commandField.text)
            } else {
                engine.execAsRoot(commandField.text, has_output, password.text)
            }
        } else {
            if (is_interactive) {
                engine.execInteractive(commandField.text)
            } else {
                engine.exec(commandField.text, has_output)
            }
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
                title: qsTr('Run command')
            }

            CodeField {
                id: commandField
                width: parent.width
                label: name
                text: command
                placeholder: is_template ? '' : qsTr('none')
            }

            TextSwitch {
                id: root
                text: qsTr('Run as root')
                description: enabled ? '' : qsTr('hint_root_disabled')
                enabled: checker.develSuAvailable
                onCheckedChanged: {
                    if (checked && !is_interactive) {
                        password.focus = true
                    }
                }
            }

            PasswordField {
                id: password
                label: qsTr('Password')
                placeholderText: qsTr('Password')
                visible: root.checked && !is_interactive
                enabled: visible
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
        if (!checker.fingertermAvailable)  {
            is_interactive = false
        }
        if (has_output && !is_interactive) {
            dialog.acceptDestination = Qt.resolvedUrl('ResultPage.qml')
            dialog.acceptDestinationAction = PageStackAction.Push
            dialog.acceptDestinationProperties = {
                name: name,
            }
        }
    }
}
