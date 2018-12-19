import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;

LabelFixed {
    id: self;
    text: qsTr ("Changed the group title to '%1'").arg (messageContentItem.title);
    color: Theme.secondaryHighlightColor;
    wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
    font.italic: true;
    font.pixelSize: Theme.fontSizeSmall;

    property TD_Chat                   chatItem           : null;
    property TD_Message                messageItem        : null;
    property TD_MessageChatChangeTitle messageContentItem : null;
}
