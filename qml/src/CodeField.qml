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

    Binding on text {
        value: input.text
    }

    property DockedPanel panel: DockedPanel {
        width: pageStack.currentPage.width
        height: Theme.itemSizeExtraSmall - Theme.paddingLarge
        contentWidth: row.width
        dock: Dock.Bottom
        open: input.focus || stayOpened
        flickableDirection: Flickable.HorizontalFlick

        background: Rectangle {
            color: Theme.highlightDimmerColor
        }

        property bool stayOpened

        Binding on parent {
            value: pageStack.currentPage
            when: item.visible
        }

        Row {
            id: row

            Repeater {
                id: completions
                model: []

                TextField {
                    text: modelData.hint
                    font.pixelSize: Theme.fontSizeExtraSmall
                    cursorColor: 'transparent'

                    background: Rectangle {
                        color: 'transparent'
                    }

                    onClicked: {
                        panel.stayOpened = true
                        var position = input.cursorPosition
                        var pre = input.text.substr(0, position - modelData.part.length)
                        var post = input.text.substr(position)
                        refocus.text = pre + modelData.hint + post
                        refocus.position = position + modelData.hint.length - modelData.part.length
                        refocus.start()
                    }
                }
            }

            Item {
                width: panel.width
                height: panel.height
            }
        }
    }

    Completion {
        id: completion

        onResult: {
            panel.contentX = 0
            var length = list.length
            for (var i = 0; i < length; i++) {
                async.add(list[i], part)
            }
            async.show()
        }
    }

    QtObject {
        id: localCompletion

        property variant split: /[\s"'${}()#;&`,:!@\[\]<>|=%^\\]+/
        property variant index: []
        property string lastPart: ''
        property variant lastList: []

        function complete(text) {
            if (!text || text[text.length - 1].match(split)) {
                index = input.text.split(split)
            }
            var part = text.split(split).pop(), localIndex
            if (part.indexOf(lastPart) === 0) {
                localIndex = lastList
            } else {
                localIndex = index
            }
            lastPart = part
            lastList = []
            var length = localIndex.length
            for (var i = 0; i < length; i++) {
                var current = localIndex[i]
                if (current && current !== part && current.indexOf(part) === 0) {
                    lastList.push(current)
                    async.add(current, part)
                }
            }
            async.show()
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

    Timer {
        id: async
        interval: 100

        property string text: ''
        property variant list: []

        onTriggered: {
            localCompletion.complete(text)
            completion.complete(text)
        }

        function complete(local) {
            stop()
            text = local
            list = []
            show()
            start()
        }

        function add(hint, part) {
            if (!hint) {
                return
            }
            if (hint[hint.length - 1] !== '/') {
                hint += ' '
            }
            var length = list.length
            for (var i = 0; i < length; i++) {
                if (list[i].hint === hint) {
                    return
                }
            }
            list.push({
                hint: hint,
                part: part,
            })
        }

        function show() {
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
            if (focus) {
                async.complete(text.substr(0, cursorPosition))
            }
        }

        onCursorPositionChanged: {
            async.complete(text.substr(0, cursorPosition))
        }
    }
}
