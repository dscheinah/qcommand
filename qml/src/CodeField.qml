import QtQuick 2.0
import Sailfish.Silica 1.0
import qCommand 1.0

Item {
    id: item
    width: parent.width
    height: input.height

    property string label
    property string text
    property string placeholder

    Binding {
        target: item
        property: 'text'
        value: input.text
    }

    property DockedPanel panel: DockedPanel {
        parent: pageStack.currentPage
        width: parent.width
        height: Theme.itemSizeExtraSmall - Theme.paddingLarge
        contentWidth: row.width
        dock: Dock.Bottom
        open: input.focus || stayOpened

        background: Rectangle {
            color: Theme.highlightDimmerColor
        }

        property bool stayOpened

        Row {
            id: row

            Repeater {
                id: completions
                model: []

                TextField {
                    text: modelData
                    font.pixelSize: Theme.fontSizeExtraSmall
                    cursorColor: 'transparent'

                    background: Rectangle {
                        color: 'transparent'
                    }

                    onClicked: {
                        panel.stayOpened = true
                        var position = input.cursorPosition
                        var pre = input.text.substr(0, position - completion.part.length)
                        var post = input.text.substr(position)
                        refocus.text = pre + modelData + post
                        refocus.position = position + modelData.length - completion.part.length
                        refocus.start()
                    }
                }
            }

            Item {
                width: panel.width
                height: panel.height
            }
        }

        Timer {
            id: refocus
            interval: 10

            property string text
            property int position

            onTriggered: {
                input.text = text
                input.cursorPosition = position
                input.forceActiveFocus()
                panel.stayOpened = false
            }
        }
    }

    Completion {
        id: completion

        onResult: {
            panel.contentX = 0
            completions.model = list
        }
    }

    TextArea {
        id: input
        width: parent.width
        label: item.label
        placeholderText: item.label
        text: item.text || item.placeholder
        readOnly: item.placeholder
        font.italic: item.placeholder && !item.text
        inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase

        onTextChanged: {
            completions.model = []
            if (focus) {
                completion.complete(text.substr(0, cursorPosition))
            }
        }

        onFocusChanged: {
            if (focus) {
                completion.complete(text.substr(0, cursorPosition))
            }
        }
    }
}
