import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;

LabelFixed {
    id: self;
    text: {
        if (callDiscardReasonItem) {
            switch (callDiscardReasonItem.typeOf) {
            case TD_ObjectType.CALL_DISCARD_REASON_HUNG_UP:      return qsTr ("Call finished (%1)").arg (TD_Global.formatTime (messageContentItem.duration, false));
            case TD_ObjectType.CALL_DISCARD_REASON_MISSED:       return qsTr ("Call missed");
            case TD_ObjectType.CALL_DISCARD_REASON_DECLINED:     return qsTr ("Call declined");
            case TD_ObjectType.CALL_DISCARD_REASON_DISCONNECTED: return qsTr ("Call disconnected");
            case TD_ObjectType.CALL_DISCARD_REASON_EMPTY:        return qsTr ("Call unknown state");
            }
        }
        return qsTr ("Call");
    }
    color: Theme.secondaryHighlightColor;
    wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
    font.italic: true;
    font.pixelSize: Theme.fontSizeSmall;

    property TD_Chat        chatItem           : null;
    property TD_Message     messageItem        : null;
    property TD_MessageCall messageContentItem : null;

    readonly property TD_CallDiscardReason callDiscardReasonItem : (messageContentItem ? messageContentItem.discardReason : null);
}
