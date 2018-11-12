import QtQuick 2.6;
import Sailfish.Silica 1.0;
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
}
