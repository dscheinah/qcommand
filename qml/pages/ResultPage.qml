import QtQuick 2.0
import Sailfish.Silica 1.0
import qCommand 1.0
import '../src'

Page {
    id: page
    allowedOrientations: Orientation.All
    objectName: 'result'

    property string output
    property string errors
    property bool error: false
    property bool errorMode: false
    property string name   

    property variant offsets: []
    property variant columns: []


    Connections {
        target: cengine
        onOutput: {
            output = handleData(data, outputModel, qsTr('no output provided'))
        }
        onError: {
            error = true
            errors = handleData(data, errorModel, qsTr('no messages provided'))
        }

        function handleData(data, model, placeholder) {
            var length = data.length, content = []
            if (length) {
                for (var i = 0; i < length; i++) {
                    var line = data[i]
                    model.append({
                        line: line,
                        placeholder: false,
                    })
                    content.push(line)
                }
            } else {
                model.append({
                    line: placeholder,
                    placeholder: true,
                })
            }
            busy.running = false
            return content.join("\n")
        }
    }

    Developer {
        id: handler
    }

    BusyIndicator {
        id: busy
        size: BusyIndicatorSize.Large
        anchors.centerIn: page
        running: true
    }

    SilicaListView {
        anchors.fill: parent
        contentHeight: content.height

        PullDownMenu {
            visible: error || output

            MenuItem {
                text: qsTr('Copy all')
                visible: (errorMode && errors) || (!errorMode && output)
                onClicked: {
                    Clipboard.text = errorMode ? errors : output
                }
            }

            MenuItem {
                text: qsTr('Show errors')
                visible: error && !errorMode
                onClicked: {
                    errorMode = true
                }
            }

            MenuItem {
                text: qsTr('Show output')
                visible: error && errorMode
                onClicked: {
                    errorMode = false
                }
            }
        }

        header: PageHeader {
            title: errorMode ? qsTr('Errors') : qsTr('Output')
        }

        model: errorMode ? errorModel : outputModel

        delegate: ListItem {
            contentItem.height: row.height + Theme.paddingSmall

            menu: ContextMenu {
                id: menu
                property string file

                onActiveChanged: {
                    if (active && !file) {
                        file = handler.getFileToOpen(line)
                    }
                }

                MenuItem {
                    text: qsTr('Copy')
                    onClicked: {
                        Clipboard.text = line
                    }
                }

                MenuItem {
                    text: qsTr('Open')
                    visible: menu.file
                    onClicked: {
                        busy.running = true
                        handler.open(menu.file)
                        busy.running = false
                    }
                }
            }

            Row {
                id: row
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                anchors.verticalCenter: parent.verticalCenter

                Repeater {
                    id: tabRepeater

                    Label {
                        color: highlighted ? Theme.highlightColor : Theme.primaryColor
                        text: modelData
                        wrapMode: Label.Wrap
                        lineHeight: 1
                        font.italic: placeholder

                        Binding on width {
                            when: tabRepeater.count === columns.length
                            value: parent.width * columns[index]
                        }

                        Binding on width {
                            when: tabRepeater.count !== columns.length
                            value: parent.width / tabRepeater.count
                        }
                    }
                }
            }

            onClicked: {
                openMenu()
            }

            Component.onCompleted: {
                var split = line.trim().split(/\t\s*/), length = split.length
                tabRepeater.model = split
                if (length < 2 || (offsets.length && length < offsets.length)) {
                    return
                }
                for (var i = 0; i < length; i++) {
                    var offset = split[i].length / line.length
                    if (!offsets[i] || offset > offsets[i]) {
                        offsets[i] = offset
                    }
                }
                var sum = offsets.reduce(function(pv, cv) { return pv + cv })
                columns = offsets.map(function(v) { return v / sum })
            }
        }

        ListModel {
            id: outputModel
        }

        ListModel {
            id: errorModel
        }

        VerticalScrollDecorator {
        }
    }
}
