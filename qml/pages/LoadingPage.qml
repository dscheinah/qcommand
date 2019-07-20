import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    PageHeader {
        title: 'qCommand'
    }

    BusyIndicator {
        size: BusyIndicatorSize.Large
        anchors.centerIn: page
        running: true
    }
}
