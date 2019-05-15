import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;

DelegateMessageSimpleLabelBase {
    id: self;
    color: "magenta";
    label: qsTr ("<Unsupported>");

    property TD_MessageContent messageContentItem : null;
}
