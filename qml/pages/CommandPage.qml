import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import '../src'

Page {
    property Database database
    property CommandEngine engine

    SilicaListView {
        anchors.fill: parent

        header: PageHeader {
            title: qsTr('available commands')
        }

        model: ListModel {
            id: commands
        }

        delegate: ListItem {
            id: command

            menu: ContextMenu {
                MenuItem {
                    text: qsTr('edit')
                    onClicked: {
                        database.read(commands.get(index), function(item) {
                            var dialog = pageStack.push(Qt.resolvedUrl('EditPage.qml'), item)
                            dialog.accepted.connect(function() {
                                database.edit(item, dialog)
                            })
                        })
                    }
                }
                MenuItem {
                    text: qsTr('remove')
                    onClicked: {
                        command.remorseAction('deleting', function() {
                            database.remove(commands.get(index))
                        })
                    }
                }
            }

            onClicked: {
                database.read(commands.get(index), function(item) {
                    var dialog = pageStack.push(Qt.resolvedUrl('ExecPage.qml'), item)
                    dialog.accepted.connect(function() {
                        engine.exec(dialog.command, dialog.has_output)
                    })
                })
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                color: command.highlighted ? Theme.highlightColor : Theme.primaryColor
                anchors.verticalCenter: parent.verticalCenter
                text: name
                truncationMode: TruncationMode.Fade
            }
        }

        PullDownMenu {
            MenuItem {
                text: qsTr('add command')
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl('EditPage.qml'))
                    dialog.accepted.connect(function() {
                        database.add(dialog)
                    })
                }
            }
        }

        VerticalScrollDecorator {
        }
    }

    function getIndex(item) {
        var length = commands.rowCount()
        for (var i = 0; i < length; i++) {
            if (commands.get(i).rowid === item.rowid) {
                return i
            }
        }
        return -1
    }

    Component.onCompleted: {
        database.edited.connect(function(item, data) {
            var index = getIndex(item)
            if (index >= 0) {
                commands.set(index, data)
            }
        })
        database.removed.connect(function(item) {
            var index = getIndex(item)
            if (index >= 0) {
                commands.remove(index)
            }
        })
        database.added.connect(commands.append)
        database.load(commands.append)
    }
}
