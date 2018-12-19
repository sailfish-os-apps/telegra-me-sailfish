import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;

LabelFixed {
    id: self;
    text: qsTr ("<Unsupported>");
    color: "magenta";

    property TD_Chat           chatItem           : null;
    property TD_Message        messageItem        : null;
    property TD_MessageContent messageContentItem : null;
}
