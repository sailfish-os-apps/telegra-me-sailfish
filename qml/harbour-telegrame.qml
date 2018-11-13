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

    /*Notification {
        id: notification;
        replacesId: 123456789;
        appIcon: "/home/nemo/.telegrame/profile_photos/439636578_66103.jpg";
        appName: "Telegra'me";
        summary: qsTr ("Unread messages");
        body: "Jimmy Huguet\n#Entourage\n#Sailfish FanClub\n#Ascorel BE";
        itemCount: 7;
        maxContentLines: 5;
        previewSummary: "Contact name";
        previewBody: "Sample message content, which can be quite long, anyway";
        //category: "x-nemo.example"
        //icon: "/home/nemo/.telegrame/profile_photos/439636578_66103.jpg";
        //timestamp: "2013-02-20 18:21:00"
        //onClicked: console.log("Clicked")
        //onClosed: console.log("Closed, reason: " + reason)
        Component.onCompleted: {
            publish ();
        }
        Component.onDestruction: {
            close ();
        }
    }*/
}
