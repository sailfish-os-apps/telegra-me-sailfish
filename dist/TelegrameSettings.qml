import QtQuick 2.1;
import Sailfish.Silica 1.0;
import Nemo.Configuration 1.0;

Page {
    id: page;

    ConfigurationValue {
        id: configSendTextMsgOnEnterKey;
        key: "/apps/telegrame/send_text_msg_on_enter_key";
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
            title: qsTr ("Telegra'me settings");
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
    }
}
