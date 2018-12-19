import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;

LabelFixed {
    id: self;
    text: qsTr ("Joined the group chat using the invite link");
    color: Theme.secondaryHighlightColor;
    wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
    font.italic: true;
    font.pixelSize: Theme.fontSizeSmall;

    property TD_Chat                  chatItem           : null;
    property TD_Message               messageItem        : null;
    property TD_MessageChatJoinByLink messageContentItem : null;
}
