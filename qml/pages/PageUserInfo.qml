import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;
import "../components";

Page {
    id: pageUserInfo;
    allowedOrientations: Orientation.All;

    property TD_User userItem : null;

    SilicaFlickable {
        contentWidth: width;
        contentHeight: (layoutUserInfo.height + layoutUserInfo.anchors.margins * 2);
        anchors.fill: parent;

        ColumnContainer {
            id: layoutUserInfo;
            spacing: Theme.paddingMedium;
            ExtraAnchors.topDock: parent;

            Item {
                Container.forcedHeight: headerUserInfo.height;
            }
            DelegateAvatar {
                size: (Theme.iconSizeExtraLarge * 1.65);
                fileItem: (pageUserInfo.userItem && pageUserInfo.userItem.profilePhoto ? pageUserInfo.userItem.profilePhoto.big : null);
                anchors.horizontalCenter: parent.horizontalCenter;
            }
            LabelFixed {
                text: (pageUserInfo.userItem ? pageUserInfo.userItem.firstName : "");
                color: Theme.primaryColor;
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                font.family: Theme.fontFamilyHeading;
                font.pixelSize: Theme.fontSizeLarge;
                anchors.horizontalCenter: parent.horizontalCenter;
            }
            LabelFixed {
                text: (pageUserInfo.userItem ? pageUserInfo.userItem.lastName : "");
                color: Theme.primaryColor;
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                font.family: Theme.fontFamilyHeading;
                font.pixelSize: Theme.fontSizeLarge;
                anchors.horizontalCenter: parent.horizontalCenter;
            }
            Item {
                Container.forcedHeight: Theme.paddingLarge;
            }
            RowContainer {
                spacing: Theme.paddingLarge;
                visible: (pageUserInfo.userItem && pageUserInfo.userItem.username !== "");
                anchors.margins: Theme.paddingLarge;
                ExtraAnchors.horizontalFill: parent;

                RectangleButton {
                    icon: "icon-m-link";
                    size: Theme.iconSizeMedium;
                    anchors.verticalCenter: parent.verticalCenter;
                    onClicked: {
                        Clipboard.text = pageUserInfo.userItem.username;
                    }
                }
                LabelFixed {
                    text: (pageUserInfo.userItem ? "@" + pageUserInfo.userItem.username : "");
                    color: Theme.secondaryHighlightColor;
                    font.underline: true;
                    font.pixelSize: Theme.fontSizeLarge;
                    anchors.verticalCenter: parent.verticalCenter;
                }
            }
            RowContainer {
                spacing: Theme.paddingLarge;
                visible: (pageUserInfo.userItem && pageUserInfo.userItem.phoneNumber !== "");
                anchors.margins: Theme.paddingLarge;
                ExtraAnchors.horizontalFill: parent;

                RectangleButton {
                    icon: "icon-m-answer";
                    size: Theme.iconSizeMedium;
                    anchors.verticalCenter: parent.verticalCenter;
                    onClicked: {
                        Qt.openUrlExternally ("tel:+" + pageUserInfo.userItem.phoneNumber);
                    }
                }
                LabelFixed {
                    text: (pageUserInfo.userItem ? "+" + pageUserInfo.userItem.phoneNumber : "");
                    color: Theme.secondaryHighlightColor;
                    font.underline: true;
                    font.pixelSize: Theme.fontSizeLarge;
                    anchors.verticalCenter: parent.verticalCenter;
                }
            }
            Item {
                Container.forcedHeight: Theme.paddingLarge;
            }
            ColumnContainer {
                spacing: Theme.paddingLarge;
                anchors.horizontalCenter: parent.horizontalCenter;

                MouseArea {
                    id: btn;
                    opacity: (enabled ? 1.0 : 0.35);
                    implicitWidth: Math.max (Theme.itemSizeSmall, lbl.width + Theme.paddingMedium * 2);
                    implicitHeight: Math.max (Theme.itemSizeSmall, lbl.height + Theme.paddingMedium * 2);
                    ExtraAnchors.horizontalFill: parent;
                    onClicked: {
                        var chatItem = TD_Global.getChatItemById (userItem.id);
                        if (chatItem) {
                            TD_Global.showChat (chatItem);
                        }
                        else {
                            TD_Global.createPrivateChat (pageUserInfo.userItem);
                        }
                    }

                    Rectangle {
                        color: Theme.rgba ((parent.pressed ? Theme.highlightColor : Theme.primaryColor), 0.15);
                        radius: Theme.paddingSmall;
                        antialiasing: true;
                        anchors.fill: parent;
                    }
                    LabelFixed {
                        id: lbl;
                        text: qsTr ("Open private chat");
                        anchors.centerIn: parent;
                    }
                }
                MouseArea {
                    id: btnSecret;
                    enabled: false; // FIXED
                    opacity: (enabled ? 1.0 : 0.35);
                    implicitWidth: Math.max (Theme.itemSizeSmall, lblSecret.width + Theme.paddingMedium * 2);
                    implicitHeight: Math.max (Theme.itemSizeSmall, lblSecret.height + Theme.paddingMedium * 2);
                    ExtraAnchors.horizontalFill: parent;
                    onClicked: {
                        // TODO
                    }

                    Rectangle {
                        color: Theme.rgba ((parent.pressed ? Theme.highlightColor : Theme.primaryColor), 0.15);
                        radius: Theme.paddingSmall;
                        antialiasing: true;
                        anchors.fill: parent;
                    }
                    LabelFixed {
                        id: lblSecret;
                        text: qsTr ("Open secret chat [TODO]");
                        anchors.centerIn: parent;
                    }
                }
            }
        }
    }
    Rectangle {
        id: headerUserInfo;
        color: Helpers.panelColor;
        implicitHeight: (title.height + title.anchors.margins * 2);
        ExtraAnchors.topDock: parent;

        LabelFixed {
            id: title;
            text: qsTr ("Contact info");
            color: Theme.highlightColor;
            font {
                family: Theme.fontFamilyHeading;
                pixelSize: Theme.fontSizeLarge;
            }
            anchors {
                right: parent.right
                margins: Theme.paddingLarge;
                verticalCenter: parent.verticalCenter;
            }
        }
    }
}
