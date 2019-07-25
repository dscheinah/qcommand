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
        anchors.bottomMargin: search.visible ? search.height : 0
        clip: true

        layer.enabled: search.visible
        layer.smooth: true
        layer.effect: OpacityRampEffectBase {
            direction: OpacityRamp.TopToBottom
            slope: 8
            offset: .9
            source: list
        }

        header: PageHeader {
            title: search.text ? qsTr('Search results') : qsTr('Available commands')
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
                            elementLoader.running = false
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
                    elementLoader.running = false
                    item.engine = engine
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

            MenuItem {
                text: qsTr('Search')

                onClicked: {
                    search.visible = true
                    search.forceActiveFocus()
                }
            }
        }

        BusyIndicator {
            id: elementLoader
            anchors.horizontalCenter: parent.horizontalCenter
            size: BusyIndicatorSize.Small
            running: false
        }

        BusyIndicator {
            id: loading
            size: BusyIndicatorSize.Medium
            anchors.centerIn: list
            running: true
        }

        VerticalScrollDecorator {
        }
    }

    SearchField {
        id: search
        anchors.bottom: parent.bottom
        width: parent.width
        placeholderText: qsTr('Search')
        visible: false

        EnterKey.enabled: false
        EnterKey.iconSource: 'image://'

        background: Rectangle {
            width: parent.width
            height: parent.height
            color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
        }

        onTextChanged: {
            async.stop()
            async.text = text
            async.start()
        }

        Item {
            parent: search
            anchors.fill: parent
            z: 1

            IconButton {
                anchors {
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                }
                width: icon.width
                height: parent.height
                icon.source: 'image://theme/icon-m-close'
                visible: !search.text

                onClicked: {
                    search.focus = false
                    search.visible = false
                }
            }
        }

        Timer {
            id: async
            interval: 100
            property string text

            onTriggered: {
                loading.running = true
                commands.clear()
                database.load(function(item) {
                    loading.running = false
                    commands.append(item)
                }, function() {
                    loading.running = false
                }, text)
            }
        }
    }

    function load(position, height) {
        elementLoader.y = position.y + (height - elementLoader.height) / 2
        elementLoader.running = true
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
            elementLoader.running = false
        })
        database.removed.connect(function(item) {
            var index = getIndex(item)
            if (index >= 0) {
                commands.remove(index)
            }
            elementLoader.running = false
        })
        database.added.connect(commands.append)
        database.load(function(item) {
            loading.running = false
            commands.append(item)
        }, function() {
            loading.running = false
        })
    }
}
