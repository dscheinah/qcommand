import QtQuick 2.0
import Sailfish.Silica 1.0
import 'pages'
import 'cover'
import 'src'

ApplicationWindow
{
    initialPage: loading
    cover: cover
    allowedOrientations: Orientation.All

    CommandEngine {
        id: engine
        objectName: 'cengine'
    }

    Database {
        id: database

        onReady: {
            pageStack.clear()
            pageStack.push(Qt.resolvedUrl('pages/CommandPage.qml'), {
                database: database,
                engine: engine,
            })
            cover.next()
        }
    }

    LoadingPage {
        id: loading
    }

    CoverPage {
        id: cover
        database: database
        engine: engine
    }

    Component.onCompleted: {
        database.create()
    }
}
