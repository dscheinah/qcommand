import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../src"

Page {
    id: page
    objectName: "Main"

    signal exec(string cmd)

    property Database database

    SilicaListView {
        width: parent.width
        height: parent.height

        header: PageHeader {
            title: qsTr('available commands')
        }
        model: ListModel {
            id: commands
        }
        delegate: ListItem {
            id: command
            width: parent.width

            menu: ContextMenu {
                MenuItem {
                    text: qsTr('edit')
                    onClicked: {
                        database.read(model, function(item) {
                            var dialog = pageStack.push(Qt.resolvedUrl('AddPage.qml'), item)
                            dialog.accepted.connect(function() {
                                database.edit(item, dialog)
                            })
                        })
                    }
                }
                MenuItem {
                    text: qsTr('remove')
                    onClicked: {
                        command.remorseAction("deleting", function() {
                            database.remove(model)
                        })
                    }
                }
            }
            onClicked: {
                database.read(model, function(item) {
                    var dialog = pageStack.push(Qt.resolvedUrl("ExecPage.qml"), item)
                    dialog.accepted.connect(function() {
                        page.exec(dialog.command)
                    })
                })
            }

            Label {
                color: command.highlighted ? Theme.highlightColor : Theme.primaryColor
                text: name
                x: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        PullDownMenu {
            MenuItem {
                text: qsTr('add/modify command')
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl('AddPage.qml'))
                    dialog.accepted.connect(function() {
                        database.add(dialog)
                    })
                }
            }
        }

        VerticalScrollDecorator {}
    }

    Component.onCompleted: {
        database.edited.connect(function(item, data) {
            var entry = commands.get(item.index)
            if (!entry || entry.name !== data.name) {
                commands.append(data)
            } else {
                commands.set(item.index, data)
            }
        })
        database.removed.connect(function(item) {
            commands.remove(item.index)
        })
        database.added.connect(commands.append)
        database.load(commands.append)
    }
}
