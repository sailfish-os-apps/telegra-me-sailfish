import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;

LabelFixed {
    id: self;
    text: (messageContentItem
           ? (messageContentItem.messageId !== "0"
              ? qsTr ("Pinned message : %1").arg (pinnedMessageItem ? pinnedMessageItem.preview (TD_Message.MINIMAL) : qsTr ("deleted message"))
              : qsTr ("Unpinned message"))
           : "")
    color: Theme.secondaryHighlightColor;
    wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
    font.italic: true;
    font.pixelSize: Theme.fontSizeSmall;

    property TD_Chat              chatItem           : null;
    property TD_Message           messageItem        : null;
    property TD_MessagePinMessage messageContentItem : null;

    readonly property TD_MessageRefWatcher pinnedMsgRefWatcher : (chatItem ? chatItem.getMessageRefById (messageContentItem.messageId) : null);
    readonly property TD_Message           pinnedMessageItem   : (pinnedMsgRefWatcher ? pinnedMsgRefWatcher.messageItem : null);
}
