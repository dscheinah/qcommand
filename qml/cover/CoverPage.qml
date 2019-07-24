import QtQuick 2.0
import Sailfish.Silica 1.0
import '../src'

CoverBackground {
    id: cover
    property Database database
    property CommandEngine engine
    property int rowid: -1
    property string name
    property string command

    Label {
        id: header
        x: Theme.horizontalPageMargin
        y: Theme.horizontalPageMargin
        font.pixelSize: Theme.fontSizeLarge
        text: 'qCommand'
    }

    Rectangle {
        height: 2
        x: Theme.horizontalPageMargin
        y: header.height + Theme.horizontalPageMargin * 2
        width: parent.width / 5 * 2

        border.color: Theme.primaryColor
    }

    Label {
        x: Theme.horizontalPageMargin
        y: header.height + Theme.horizontalPageMargin * 3
        width: parent.width - Theme.horizontalPageMargin * 2
        height: parent.height - header.height - cover.coverActionArea.height - Theme.horizontalPageMargin * 3
        wrapMode: Label.Wrap
        truncationMode: TruncationMode.Fade
        text: name
    }

    CoverActionList {
        enabled: rowid

        CoverAction {
            iconSource: 'image://theme/icon-cover-play'
            onTriggered: {
                engine.exec(command, false)
                next()
            }
        }

        CoverAction {
            iconSource: 'image://theme/icon-cover-next-song'
            onTriggered: {
                next()
            }
        }
    }

    function next() {
        database.readNext(cover, function(item) {
            rowid = item.rowid
            name = item.name
            command = item.command || ''
        })
    }

    Component.onCompleted: {
        database.edited.connect(function(item, data) {
            if (item.rowid === rowid) {
                name = data.name
                command = data.command
            }
        })
        database.removed.connect(function(item) {
            if (item.rowid === rowid) {
                next()
            }
        })
        database.added.connect(function(item) {
            if (!rowid) {
                rowid = item.rowid
                name = item.name
                command= item.command
            }
        })
    }
}


