import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0
import Nemo.DBus 2.0

Item {
    property ApplicationWindow app
    property variant appAction: {
        'name': 'app',
        'service': 'de.qcommand.dscheinah',
        'iface': 'de.qcommand.dscheinah',
        'path': '/app',
        'method': 'show',
    }

    Connections {
        target: cengine
        onOutput: {
            var result = getResultPage()
            if (result && Qt.application.state !== Qt.ApplicationActive) {
                notification.body = result.name
                notification.publish()
            }
        }
        onErrorState: {
            errorNotification.publish()
        }
    }

    DBusAdaptor {
        bus: DBus.SessionBus
        service: 'de.qcommand.dscheinah'
        iface: 'de.qcommand.dscheinah'
        path: '/app'

        function show() {
            app.activate()
        }

        function error() {
            if (!app.applicationActive) {
                app.activate()
            }
            var result = getResultPage()
            if (result) {
                result.errorMode = true
            }
        }
    }

    Notification {
        id: notification
        appName: 'qCommand'
        summary: qsTr('Command completed')
        previewSummary: summary
        previewBody: body
        replacesId: 42
        urgency: Notification.Low
        remoteActions: [
            appAction,
            {
                'name': 'default',
                'service': 'de.qcommand.dscheinah',
                'iface': 'de.qcommand.dscheinah',
                'path': '/app',
                'method': 'show',
            },
        ]
    }

    Notification {
        id: errorNotification
        appName: 'qCommand'
        appIcon: 'image://theme/icon-lock-warning'
        summary: qsTr('Error')
        body: qsTr('Command exited with errors')
        previewSummary: summary
        previewBody: body
        isTransient: true
        urgency: Notification.Critical
        remoteActions: [
            appAction,
            {
                'name': 'default',
                'service': 'de.qcommand.dscheinah',
                'iface': 'de.qcommand.dscheinah',
                'path': '/app',
                'method': 'error',
            },
        ]
    }

    function getResultPage() {
        return pageStack.find(function(page) {
            return page.objectName === 'result'
        })
    }

    Component.onCompleted: {
        app.applicationActiveChanged.connect(function() {
            if (app.applicationActive) {
                notification.close()
            }
        })
    }
}
