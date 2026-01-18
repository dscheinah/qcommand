import QtQuick 2.0
import Sailfish.Silica 1.0
import qCommand 1.0
import '../src'

Dialog {
    id: dialog
    canAccept: command && (is_interactive || !root.checked || password.acceptableInput)
    allowedOrientations: Orientation.All
    objectName: 'exec'

    property CommandEngine engine
    property Database database

    property string name
    property string command
    property int has_output
    property int is_template
    property int is_interactive
    property int is_stored
    property int run_as_root
    property int rowid

    property string lastPassword: ''

    onDone: {
        commandField.focus = false
    }

    onAccepted: {
        var item = {
            rowid: rowid + '-exec',
            command: commandField.text,
        }
        engine.store(item, function() {
            if (!checker.fingertermAvailable)  {
                is_interactive = false
            }
            if (root.checked) {
                var success = false
                if (store.checked) {
                    success = true
                    if (password.text != lastPassword) {
                        success = secrets.store(password.text)
                    }
                }
                if (success) {
                    database.setStored(rowid, true)
                    lastPassword = password.text
                } else {
                    database.setStored(rowid, false)
                    lastPassword = ''
                }
                if (checker.develSuAvailable) {
                    if (is_interactive) {
                        engine.execAsRootInteractive(engine.path(item))
                    } else {
                        engine.execAsRoot(engine.path(item), has_output, password.text)
                    }
                }
            } else {
                if (is_interactive) {
                    engine.execInteractive(engine.path(item))
                } else {
                    engine.exec(engine.path(item), has_output)
                }
            }
        })
    }

    Developer {
        id: checker

        onChanged: {
            password.validator = null
            password.validator = checker
        }
    }

    Secrets {
        id: secrets
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
                checked: run_as_root
                onCheckedChanged: {
                    if (checked && !is_interactive) {
                        if (!password.text && is_stored) {
                            password.text = lastPassword = secrets.read();
                        }
                        if (!password.text) {
                            password.focus = true
                        }
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
                showEchoModeToggle: !is_stored

                EnterKey.iconSource: 'image://theme/icon-m-enter-accept'
                EnterKey.onClicked: {
                    dialog.accept()
                }
            }

            TextSwitch {
                id: store
                text: qsTr('Store password')
                visible: root.checked && !is_interactive
                checked: is_stored
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
        }
    }
}
