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
    SilicaFlickable {
        id: flickerSettings;
        contentWidth: width;
        contentHeight: (layoutSettings.height + layoutSettings.anchors.margins * 2);
        anchors.fill: parent;
        anchors.topMargin: headerSettings.height;

        ColumnContainer {
            id: layoutSettings;
            spacing: Theme.paddingLarge;
            ExtraAnchors.topDock: parent;

            Item {
                Container.forcedHeight: Theme.paddingMedium;
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
                spacing: Theme.paddingSmall;
                anchors.horizontalCenter: parent.horizontalCenter;

                Repeater {
                    model: [
                        { "shape" : "square",   "mask" : "qrc:///images/mask_square.svg",   "label" : qsTr ("Square (default)") },
                        { "shape" : "rounded",  "mask" : "qrc:///images/mask_rounded.svg",  "label" : qsTr ("Rounded square")   },
                        { "shape" : "squircle", "mask" : "qrc:///images/mask_squircle.svg", "label" : qsTr ("Meego 'squircle'") },
                        { "shape" : "circle",   "mask" : "qrc:///images/mask_circle.svg",   "label" : qsTr ("Full circle")      },
                    ];
                    delegate: MouseArea {
                        id: delegateShape;
                        implicitWidth: (Theme.iconSizeLarge + Theme.paddingLarge * 2);
                        implicitHeight: (implicitWidth * 1.65);
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
                                sourceSize: Qt.size (Theme.iconSizeLarge, Theme.iconSizeLarge);
                                anchors.horizontalCenter: parent.horizontalCenter;
                            }
                            LabelFixed {
                                text: modelData ["label"].replace (/\s/g, "\n");
                                color: (modelData ["shape"] === configAvatarShape.value ? Theme.highlightColor : Theme.secondaryColor);
                                horizontalAlignment: Text.AlignHCenter;
                                font.pixelSize: Theme.fontSizeExtraSmall;
                                anchors.horizontalCenter: parent.horizontalCenter;
                            }
                        }
                    }
                }
            }
            Item {
                Container.forcedHeight: Theme.paddingMedium;
            }
        }
    }
    VerticalScrollDecorator {
        flickable: flickerSettings;
    }
    Rectangle {
        id: headerSettings;
        color: Qt.rgba (1.0 - Theme.primaryColor.r, 1.0 - Theme.primaryColor.g, 1.0 - Theme.primaryColor.b, 0.85);
        implicitHeight: (titleSettings.height + titleSettings.anchors.margins * 2);
        ExtraAnchors.topDock: parent;

        LabelFixed {
            id: titleSettings;
            text: qsTr ("Settings");
            color: Theme.highlightColor;
            horizontalAlignment: Text.AlignRight;
            font {
                family: Theme.fontFamilyHeading;
                pixelSize: Theme.fontSizeLarge;
            }
            anchors.margins: Theme.paddingLarge;
            anchors.verticalCenter: parent.verticalCenter;
            ExtraAnchors.horizontalFill: parent;
        }
    }
}
