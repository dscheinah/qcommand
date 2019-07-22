import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import '../src'

Page {
    allowedOrientations: Orientation.All

    property Database database
    property CommandEngine engine

    SilicaListView {
        id: list
        anchors.fill: parent

        header: PageHeader {
            title: qsTr('Available commands')
        }

        model: ListModel {
            id: commands
        }

        delegate: ListItem {
            id: command

            menu: ContextMenu {
                MenuItem {
                    text: qsTr('Edit')
                    onClicked: {
                        load(commandLabel.mapToItem(list, 0, 0), commandLabel.height)
                        database.read(commands.get(index), function(item) {
                            loading.running = false
                            var dialog = pageStack.push(Qt.resolvedUrl('EditPage.qml'), item)
                            dialog.accepted.connect(function() {
                                load(commandLabel.mapToItem(list, 0, 0), commandLabel.height)
                                database.edit(item, dialog)
                            })
                        })
                    }
                }
                MenuItem {
                    text: qsTr('Remove')
                    onClicked: {
                        command.remorseAction(qsTr('Deleting'), function() {
                            load(commandLabel.mapToItem(list, 0, 0), commandLabel.height)
                            database.remove(commands.get(index))
                        })
                    }
                }
            }

            onClicked: {
                load(commandLabel.mapToItem(list, 0, 0), commandLabel.height)
                database.read(commands.get(index), function(item) {
                    loading.running = false
                    item.engine = engine;
                    pageStack.push(Qt.resolvedUrl('ExecPage.qml'), item)
                })
            }

            Label {
                id: commandLabel
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                color: command.highlighted ? Theme.highlightColor : Theme.primaryColor
                anchors.verticalCenter: parent.verticalCenter
                text: name
                truncationMode: TruncationMode.Fade
            }
        }

        BusyIndicator {
            id: loading
            anchors.horizontalCenter: parent.horizontalCenter
            size: BusyIndicatorSize.Small
            running: false
        }

        PullDownMenu {
            MenuItem {
                text: qsTr('Add command')
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

    function load(position, height) {
        loading.y = position.y + (height - loading.height) / 2
        loading.running = true
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
            loading.running = false
        })
        database.removed.connect(function(item) {
            var index = getIndex(item)
            if (index >= 0) {
                commands.remove(index)
            }
            loading.running = false
        })
        database.added.connect(commands.append)
        database.load(commands.append)
    }
}
