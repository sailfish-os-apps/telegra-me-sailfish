import QtQuick 2.6;
import Sailfish.Silica 1.0;
import Nemo.Notifications 1.0;
import harbour.Telegrame 1.0;
import "cover";
import "pages";

ApplicationWindow {
    id: window;
    allowedOrientations: defaultAllowedOrientations;
    cover: Component {
        CoverPage {
            label: {
                switch (TD_Global.connectionState ? TD_Global.connectionState.typeOf : -1) {
                case TD_ObjectType.CONNECTION_STATE_WAITING_FOR_NETWORK: return qsTr ("Waiting...");
                case TD_ObjectType.CONNECTION_STATE_CONNECTING:          return qsTr ("Connecting...");
                case TD_ObjectType.CONNECTION_STATE_CONNECTING_TO_PROXY: return qsTr ("Proxying...");
                case TD_ObjectType.CONNECTION_STATE_UPDATING:            return qsTr ("Updating...");
                case TD_ObjectType.CONNECTION_STATE_READY:               return qsTr ("Ready");
                }
                return "";
            }
        }
    }
    initialPage: Component {
        PageMain { }
    }

    //Notification {
    //    id: notification
    //    category: "x-nemo.example"
    //    appName: "Example App"
    //    appIcon: "/usr/share/example-app/icon-l-application"
    //    summary: "Notification summary"
    //    body: "Notification body"
    //    previewSummary: "Notification preview summary"
    //    previewBody: "Notification preview body"
    //    itemCount: 5
    //    timestamp: "2013-02-20 18:21:00"
    //    remoteActions: [
    //        {
    //            "name": "default",
    //            "displayName": "Do something",
    //            "icon": "icon-s-do-it",
    //            "service": "org.nemomobile.example",
    //            "path": "/example",
    //            "iface": "org.nemomobile.example",
    //            "method": "doSomething",
    //            "arguments": [ "argument", 1 ]
    //        },
    //        {
    //            "name": "ignore",
    //            "displayName": "Ignore the problem",
    //            "icon": "icon-s-ignore",
    //            "service": "org.nemomobile.example",
    //            "path": "/example",
    //            "iface": "org.nemomobile.example",
    //            "method": "ignore",
    //            "arguments": [ "argument", 1 ]
    //        }
    //    ];
    //    onClicked: console.log("Clicked")
    //    onClosed: console.log("Closed, reason: " + reason)
    //    // publish()
    //}
}
