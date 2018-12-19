import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;
import "../components";

Page {
    id: page;
    allowedOrientations: Orientation.All;

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
                description: qsTr ("Press Enter to send text messages (single-line)");
                automaticCheck: true;
                onCheckedChanged: {
                    Helpers.sendTextMsgOnEnterKey = checked;
                }

                Binding on checked { value: Helpers.sendTextMsgOnEnterKey; }
            }
            TextSwitch {
                text: qsTr ("Include muted chats in unread count");
                description: qsTr ("Whether unread chats should be included in cover page");
                automaticCheck: true;
                onCheckedChanged: {
                    Helpers.includeMutedChatsInUnreadCount = checked;
                }

                Binding on checked { value: Helpers.includeMutedChatsInUnreadCount; }
            }
            TextSwitch {
                text: qsTr ("Hide the header in conversation page");
                description: qsTr ("Normally, it displays title and status, but hiding it can save some space");
                automaticCheck: true;
                onCheckedChanged: {
                    Helpers.hideChatHeader = checked;
                }

                Binding on checked { value: Helpers.hideChatHeader; }
            }
            TextSwitch {
                text: qsTr ("Keep keyboard open after sending message");
                description: qsTr ("By default Jolla keyboard auto-closes, but we can bypass this");
                automaticCheck: true;
                onCheckedChanged: {
                    Helpers.keepKeyboardOpenAfterMsgSend = checked;
                }

                Binding on checked { value: Helpers.keepKeyboardOpenAfterMsgSend; }
            }
            TextSwitch {
                text: qsTr ("Limit file picker to home directory");
                description: qsTr ("By default one can't navigate outside of home, but can be unlocked for advanced users");
                automaticCheck: true;
                onCheckedChanged: {
                    Helpers.limitFilePickerToHome = checked;
                }

                Binding on checked { value: Helpers.limitFilePickerToHome; }
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
                            Helpers.avatarShape = modelData ["shape"];
                        }

                        Rectangle {
                            color: Theme.secondaryHighlightColor;
                            radius: Theme.paddingMedium;
                            opacity: 0.15;
                            visible: (modelData ["shape"] === Helpers.avatarShape);
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
                                color: (modelData ["shape"] === Helpers.avatarShape ? Theme.highlightColor : Theme.secondaryColor);
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
        color: Helpers.panelColor;
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
