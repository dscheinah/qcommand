import QtQuick 2.0
import Sailfish.Silica 1.0
import "src"
import "pages"
import "cover"

ApplicationWindow
{
    initialPage: loading
    cover: cover
    allowedOrientations: Orientation.All

    LoadingPage {
        id: loading
    }

    CoverPage {
        id: cover
    }

    Database {
        id: database

        onReady: {
            pageStack.clear()
            pageStack.push(Qt.resolvedUrl('pages/CommandPage.qml'), {
                database: database
            })
        }
    }

    Component.onCompleted: {
        database.create()
    }
}
