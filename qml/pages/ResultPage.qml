import QtQuick 2.0
import Sailfish.Silica 1.0
import '../src'

Page {
    id: page
    allowedOrientations: Orientation.All

    property string result
    property string errors
    property bool output: false
    property bool error: false
    property bool errorMode: false

    Connections {
        target: cengine
        onOutput: {
            result = data
            output = true
        }
        onError: {
            errors = data
            error = true
        }
    }

    BusyIndicator {
        size: BusyIndicatorSize.Large
        anchors.centerIn: page
        running: !output && !error
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height

        Column {
            id: content
            width: parent.width
            visible: output || error

            onHeightChanged: {
                parent.contentHeight = content.height
            }

            PageHeader {
                title: errorMode ? qsTr('errors') : qsTr('output')
            }

            TextArea {
                visible: !errorMode
                width: parent.width
                text: result ? result : qsTr('no output provided')
                font.italic: !result
                readOnly: true
            }

            TextArea {
                visible: errorMode
                width: parent.width
                text: errors ? errors : qsTr('no messages provided')
                font.italic: !errors
                readOnly: true
            }
        }

        PullDownMenu {
            visible: error

            MenuItem {
                text: qsTr('show errors')
                visible: !errorMode
                onClicked: {
                    errorMode = true
                }
            }

            MenuItem {
                text: qsTr('show output')
                visible: errorMode
                onClicked: {
                    errorMode = false
                }
            }
        }

        VerticalScrollDecorator {
        }
    }
}
