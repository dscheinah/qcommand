import QtQuick 2.0
import Sailfish.Silica 1.0
import qCommand 1.0
import '../src'

CoverBackground {
    id: cover

    property ApplicationWindow app
    property Database database
    property CommandEngine engine
    property string visibleName

    property int rowid
    property string name
    property string command
    property string cover_group
    property bool has_output
    property bool is_interactive
    property bool is_template
    property bool run_as_root
    property bool is_stored

    Secrets {
        id: secrets
    }

    Label {
        id: header
        x: Theme.horizontalPageMargin
        y: Theme.horizontalPageMargin
        font.pixelSize: Theme.fontSizeLarge
        text: 'qCommand'
        color: Theme.highlightColor
    }

    Label {
        x: Theme.horizontalPageMargin
        y: header.height + Theme.fontSizeLarge + Theme.paddingLarge
        width: parent.width - Theme.horizontalPageMargin * 2
        height: parent.height - header.height - Theme.fontSizeLarge - Theme.paddingLarge - cover.coverActionArea.height
        wrapMode: Label.Wrap
        truncationMode: TruncationMode.Elide
        text: visibleName
    }

    CoverActionList {
        enabled: rowid

        CoverAction {
            iconSource: 'image://theme/icon-cover-play'
            onTriggered: {
                var password = ''
                if (run_as_root && is_stored && !is_interactive && !is_template) {
                    password = secrets.read()
                }
                if (is_template || (run_as_root && !is_interactive && !password)) {
                    activate('exec', '../pages/ExecPage.qml', {
                         engine: engine,
                         database: database,
                         name: name,
                         command: command,
                         has_output: has_output,
                         is_template: is_template,
                         is_interactive: is_interactive,
                         is_stored: is_stored,
                         run_as_root: run_as_root,
                         rowid: rowid,
                     })
                } else {
                    if (has_output && !is_interactive) {
                        activate('result', '../pages/ResultPage.qml', {name: name})
                    }
                    if (run_as_root && is_interactive) {
                        engine.execAsRootInteractive(command)
                    } else if (password) {
                        engine.execAsRoot(command, has_output, password)
                    } else if (is_interactive) {
                        engine.execInteractive(command)
                    } else {
                        engine.exec(command, has_output)
                    }
                }
                next()
            }
        }

        CoverAction {
            iconSource: 'image://theme/icon-cover-next-song'
            onTriggered: {
                nextGroup()
            }
        }
    }

    function set(item) {
        if (!item.cover_group) {
            return;
        }
        if (item.rowid) {
            rowid = item.rowid
        }
        name = item.name || ''
        command = item.command || ''
        cover_group = item.cover_group || ''
        has_output = item.has_output || false
        is_interactive = item.is_interactive || false
        is_template = item.is_template || false
        run_as_root = item.run_as_root || false
        is_stored = item.is_stored || false
        visibleName = cover_group + '\n' + name.substr(cover_group.length).trim()
    }

    function next() {
        database.readNext(cover, set, nextGroup)
    }

    function nextGroup() {
        database.readNextGroup(cover, set)
    }

    function activate(target, url, data) {
        var page = pageStack.find(function(page) { return page.objectName === target })
        if (page) {
            pageStack.pop(page, true)
            pageStack.pop(null, true)
        }
        pageStack.push(Qt.resolvedUrl(url), data, true)
        app.activate()
    }

    Component.onCompleted: {
        database.edited.connect(function(item, data) {
            if (item.rowid === rowid) {
                set(data)
            }
        })
        database.removed.connect(function(item) {
            if (item.rowid === rowid) {
                next()
            }
        })
        database.added.connect(function(item) {
            if (!rowid) {
                set(item)
            }
        })
    }
}


