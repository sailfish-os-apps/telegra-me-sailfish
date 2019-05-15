import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;

DelegateMessageSimpleLabelBase {
    id: self;
    label: qsTr ("Supergroup chat '%1' created").arg (messageContentItem.title);

    property TD_MessageSupergroupChatCreate messageContentItem : null;
}
