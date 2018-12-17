import QtQuick 2.1;
import Sailfish.Silica 1.0;
import Nemo.Configuration 1.0;

Page {
    id: page;
    allowedOrientations: Orientation.All;

    ConfigurationValue {
        id: configSendTextMsgOnEnterKey;
        key: "/apps/telegrame/send_text_msg_on_enter_key";
        defaultValue: false;
    }
    ConfigurationValue {
        id: configIncludeMutedChatsInUnreadCount;
        key: "/apps/telegrame/include_muted_chats_in_unread_count";
        defaultValue: false;
    }
    Column {
        spacing: Theme.paddingLarge;
        anchors {
            top: parent.top;
            left: parent.left;
            right: parent.right;
        }

        PageHeader {
            title: qsTr ("Settings");
        }
        TextSwitch {
            text: qsTr ("Quick sending of text messages");
            description: qsTr ("Press Enter to send text messages (single-line)")
            automaticCheck: true;
            onCheckedChanged: {
                configSendTextMsgOnEnterKey.value = checked;
            }

            Binding on checked { value: configSendTextMsgOnEnterKey.value; }
        }
        TextSwitch {
            text: qsTr ("Include muted chats in unread count");
            description: qsTr ("Whether unread chats should be included in cover page")
            automaticCheck: true;
            onCheckedChanged: {
                configIncludeMutedChatsInUnreadCount.value = checked;
            }

            Binding on checked { value: configIncludeMutedChatsInUnreadCount.value; }
        }
    }
}
