import QtQuick 2.1;
import Sailfish.Silica 1.0;
import Nemo.Configuration 1.0;
import QtQmlTricks 3.0;
import "../components";

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
    ConfigurationValue {
        id: configKeepKeyboardOpenAfterMsgSend;
        key: "/apps/telegrame/keep_kdb_open_after_msg_send";
        defaultValue: true;
    }
    ConfigurationValue {
        id: configAvatarShape;
        key: "/apps/telegrame/avatar_shape";
        defaultValue: "square";
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
        TextSwitch {
            text: qsTr ("Keep keyboard open after sending message");
            description: qsTr ("By default Jolla keyboard auto-closes, but we can bypass this")
            automaticCheck: true;
            onCheckedChanged: {
                configKeepKeyboardOpenAfterMsgSend.value = checked;
            }

            Binding on checked { value: configKeepKeyboardOpenAfterMsgSend.value; }
        }
        LabelFixed {
            text: qsTr ("Avatar shape");
            anchors.horizontalCenter: parent.horizontalCenter;
        }
        RowContainer {
            spacing: Theme.paddingLarge;
            anchors.margins: Theme.paddingLarge;
            ExtraAnchors.horizontalFill: parent;

            Repeater {
                model: [
                    { "shape" : "square",   "mask" : "qrc:///images/mask_square.svg",   "label" : qsTr ("Square (default)") },
                    { "shape" : "rounded",  "mask" : "qrc:///images/mask_rounded.svg",  "label" : qsTr ("Rounded square")   },
                    { "shape" : "squircle", "mask" : "qrc:///images/mask_squircle.svg", "label" : qsTr ("Meego 'squircle'") },
                    { "shape" : "circle",   "mask" : "qrc:///images/mask_circle.svg",   "label" : qsTr ("Full circle")      },
                ];
                delegate: MouseArea {
                    id: delegateShape;
                    implicitHeight: (width * 1.65);
                    Container.horizontalStretch: 1;
                    onClicked: {
                        configAvatarShape.value = modelData ["shape"];
                    }

                    Rectangle {
                        color: Theme.secondaryHighlightColor;
                        radius: Theme.paddingMedium;
                        opacity: 0.15;
                        visible: (modelData ["shape"] === configAvatarShape.value);
                        antialiasing: true;
                        anchors.fill: parent;
                    }
                    ColumnContainer {
                        spacing: Theme.paddingMedium;
                        anchors.centerIn: parent;

                        Image {
                            source: modelData ["mask"];
                            opacity: 0.65;
                            sourceSize: Qt.size (delegateShape.width * 0.65, delegateShape.width * 0.65);
                            anchors.horizontalCenter: parent.horizontalCenter;
                        }
                        LabelFixed {
                            text: modelData ["label"].replace (/\s/g, "\n");
                            color: (modelData ["shape"] === configAvatarShape.value ? Theme.highlightColor : Theme.secondaryColor);
                            horizontalAlignment: Text.AlignHCenter;
                            font.pixelSize: Theme.fontSizeSmall;
                            anchors.horizontalCenter: parent.horizontalCenter;
                        }
                    }
                }
            }
        }
    }
}
