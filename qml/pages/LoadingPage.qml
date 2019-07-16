import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    Column {
        width: parent.width

        PageHeader {
            title: "qCommand"
        }
        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: qsTr('loading...')
        }
    }
}
