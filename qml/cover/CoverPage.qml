import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;
import Nemo.Configuration 1.0;
import "../components";

CoverBackground {
    id: cover;

    readonly property int count : (configIncludeMutedChatsInUnreadCount.value
                                   ? TD_Global.unreadMessagesCountWithMuted
                                   : TD_Global.unreadMessagesCount);

    ConfigurationValue {
        id: configIncludeMutedChatsInUnreadCount;
        key: "/apps/telegrame/include_muted_chats_in_unread_count";
        defaultValue: false;
    }
    Image {
        source: "qrc:///images/Telegram_logo.svg";
        height: width;
        opacity: 0.15;
        anchors {
            topMargin: (cover.height * +0.05);
            leftMargin: (cover.width * -0.05);
            rightMargin: (cover.width * +0.05);
        }
        ExtraAnchors.topDock: parent;
    }
    ColumnContainer {
        spacing: Theme.paddingLarge;
        anchors {
            margins: Theme.paddingLarge;
            verticalCenter: parent.verticalCenter;
        }
        ExtraAnchors.horizontalFill: parent;

        LabelFixed {
            text: "Telegra'me";
            color: Theme.primaryColor;
            font.pixelSize: Theme.fontSizeLarge;
            anchors.horizontalCenter: parent.horizontalCenter;
        }
        LabelFixed {
            text: count;
            color: (count > 0 ? Theme.highlightColor : Theme.secondaryColor);
            font.pixelSize: Theme.fontSizeHuge;
            anchors.horizontalCenter: parent.horizontalCenter;
        }
        LabelFixed {
            text: qsTr ("unread messages");
            color: Theme.primaryColor;
            opacity: (count > 0 ? 1.0 : 0.35);
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
            horizontalAlignment: Text.AlignHCenter;
            font.pixelSize: Theme.fontSizeLarge;
            ExtraAnchors.horizontalFill: parent;
        }
        Rectangle {
            color: Theme.secondaryColor;
            implicitWidth: (cover.width * 0.65);
            implicitHeight: 1;
            anchors.horizontalCenter: parent.horizontalCenter;
        }
        LabelFixed {
            color: Theme.primaryColor;
            horizontalAlignment: Text.AlignHCenter;
            text: {
                if (TD_Global.connectionState) {
                    switch (TD_Global.connectionState.typeOf) {
                    case TD_ObjectType.CONNECTION_STATE_WAITING_FOR_NETWORK: return qsTr ("Waiting");
                    case TD_ObjectType.CONNECTION_STATE_CONNECTING:          return qsTr ("Connecting");
                    case TD_ObjectType.CONNECTION_STATE_CONNECTING_TO_PROXY: return qsTr ("Proxying");
                    case TD_ObjectType.CONNECTION_STATE_UPDATING:            return qsTr ("Updating");
                    case TD_ObjectType.CONNECTION_STATE_READY:               return qsTr ("Ready");
                    }
                }
                return "";
            }
            ExtraAnchors.horizontalFill: parent;
        }
    }
}
