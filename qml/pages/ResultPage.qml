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
                    var line = data[i].line
                    model.append({
                        line: line,
                        file: data[i].file || '',
                        placeholder: false,
                    })
                    content.push(line)
                }
            } else {
                model.append({
                    line: placeholder,
                    file: '',
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
            MenuItem {
                text: qsTr('Copy all')
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
            contentItem.height: label.contentHeight + Theme.paddingSmall

            menu: ContextMenu {
                MenuItem {
                    text: qsTr('Copy')
                    onClicked: {
                        Clipboard.text = line
                    }
                }

                MenuItem {
                    text: qsTr('Open')
                    visible: file
                    onClicked: {
                        handler.open(file)
                    }
                }
            }

            Label {
                id: label
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                anchors.verticalCenter: parent.verticalCenter
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
                text: line
                wrapMode: Label.Wrap
                lineHeight: 1
                font.italic: placeholder
            }

            onClicked: {
                openMenu()
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
