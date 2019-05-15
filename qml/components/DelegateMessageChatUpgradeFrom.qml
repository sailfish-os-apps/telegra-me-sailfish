import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;

DelegateMessageSimpleLabelBase {
    id: self;
    label: qsTr ("Upgraded from basic group");

    property TD_MessageChatUpgradeFrom messageContentItem : null;
}
