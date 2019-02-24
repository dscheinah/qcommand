import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

Page {
    id: page
    objectName: "Main"
    signal exec(string cmd)

    SilicaListView {
        width: parent.width
        height: parent.height

        header: PageHeader {
            title: qsTr('available commands')
        }
        model:   ListModel {
            id: commands
        }
        delegate: ListItem {
            id: command
            width: parent.width

            menu: ContextMenu {
                MenuItem {
                    text: qsTr('edit')
                    onClicked: {
                        var db = LocalStorage.openDatabaseSync('qCommand', '1.0', 'stored commands from qCommand')
                        db.transaction(function(t) {
                            var result = t.executeSql('SELECT * FROM commands WHERE name = ?', [model.name]), item = result.rows.item(0)
                            if (item) {
                                var dialog = pageStack.push(Qt.resolvedUrl('AddPage.qml'))
                                dialog.name = item.name
                                dialog.command = item.command
                                dialog.accepted.connect(function() {
                                    db.transaction(function(t) {
                                        t.executeSql('INSERT OR REPLACE INTO commands VALUES(?, ?)', [dialog.name, dialog.command])
                                        if (dialog.name !== model.name) {
                                            commands.append({ name: dialog.name, command: dialog.command })
                                        }
                                    })
                                })
                            }
                        })
                    }
                }
                MenuItem {
                    text: qsTr('remove')
                    onClicked: {
                        command.remorseAction("deleting", function() {
                            var db = LocalStorage.openDatabaseSync('qCommand', '1.0', 'stored commands from qCommand')
                            db.transaction(function(t) {
                                t.executeSql('DELETE FROM commands WHERE name = ?', [model.name])
                                commands.remove(model.index)
                            })
                        })

                    }
                }
            }
            onClicked: {
                var db = LocalStorage.openDatabaseSync('qCommand', '1.0', 'stored commands from qCommand')
                db.transaction(function(t) {
                    var result = t.executeSql('SELECT * FROM commands WHERE name = ?', [model.name]), item = result.rows.item(0)
                    if (item) {
                        var dialog = pageStack.push(Qt.resolvedUrl("ExecPage.qml"))
                        dialog.name    = item.name
                        dialog.command = item.command
                        dialog.accepted.connect(function() {
                            page.exec(dialog.command)
                        })
                    }
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
                        var db = LocalStorage.openDatabaseSync('qCommand', '1.0', 'stored commands from qCommand')
                        db.transaction(function(t) {
                            t.executeSql('INSERT OR REPLACE INTO commands VALUES(?, ?)', [dialog.name, dialog.command])
                            commands.append({ name: dialog.name, command: dialog.command })
                        })
                    })
                }
            }
        }

        VerticalScrollDecorator {}
    }

    Component.onCompleted: {
        var db = LocalStorage.openDatabaseSync('qCommand', '1.0', 'stored commands from qCommand')
        db.transaction(function(t) {
            t.executeSql('CREATE TABLE IF NOT EXISTS commands(name TEXT UNIQUE, command TEXT)')
            var result = t.executeSql('SELECT * from commands ORDER BY name'), length = result.rows.length
            for (var i = 0; i < length; i++) {
                commands.append({ name: result.rows.item(i).name, command: result.rows.item(i).command })
            }
        })
    }
}
