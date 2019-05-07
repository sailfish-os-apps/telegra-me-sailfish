import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;
import "../components";

Page {
    id: pageChatInfoPrivate;
    allowedOrientations: Orientation.All;

    property TD_Chat chatItem : null;
    property TD_User userItem : null;

    SilicaFlickable {
        contentWidth: width;
        contentHeight: (layoutUserInfo.height + layoutUserInfo.anchors.margins * 2);
        anchors.fill: parent;

        PullDownMenu {
            MenuItem {
                text: qsTr ("Delete contact [TODO]");
                enabled: false;
                onClicked: {
                    // TODO
                }
            }
            MenuItem {
                text: qsTr ("Block user [TODO]");
                enabled: false;
                onClicked: {
                    // TODO
                }
            }
            MenuItem {
                text: qsTr ("Edit contact [TODO]");
                enabled: false;
                onClicked: {
                    // TODO
                }
            }
        }
        ColumnContainer {
            id: layoutUserInfo;
            spacing: (Theme.paddingLarge * 2);
            anchors.margins: Theme.paddingLarge;
            ExtraAnchors.topDock: parent;

            LabelFixed {
                text: qsTr ("User details")
                color: Theme.highlightColor;
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                font.family: Theme.fontFamilyHeading;
                font.pixelSize: Theme.fontSizeExtraLarge;
                anchors.right: parent.right;
            }
            DelegateAvatar {
                size: (Theme.iconSizeExtraLarge * 1.65);
                fileItem: (pageChatInfoPrivate.chatItem && pageChatInfoPrivate.chatItem.photo ? pageChatInfoPrivate.chatItem.photo.big : null);
                anchors.horizontalCenter: parent.horizontalCenter;
            }
            LabelFixed {
                text: (pageChatInfoPrivate.chatItem ? pageChatInfoPrivate.chatItem.title : "");
                color: Theme.primaryColor;
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                horizontalAlignment: Text.AlignHCenter;
                font.family: Theme.fontFamilyHeading;
                font.pixelSize: Theme.fontSizeLarge;
                anchors.margins: Theme.paddingLarge;
                ExtraAnchors.horizontalFill: parent;
            }
            RowContainer {
                spacing: Theme.paddingLarge;
                visible: (pageChatInfoPrivate.userItem && pageChatInfoPrivate.userItem.username !== "");
                anchors.margins: Theme.paddingLarge;
                ExtraAnchors.horizontalFill: parent;

                RectangleButton {
                    icon: "icon-m-link";
                    size: Theme.iconSizeMedium;
                    anchors.verticalCenter: parent.verticalCenter;
                    onClicked: {
                        Clipboard.text = pageChatInfoPrivate.userItem.username;
                    }
                }
                LabelFixed {
                    text: (pageChatInfoPrivate.userItem ? "@" + pageChatInfoPrivate.userItem.username : "");
                    color: Theme.secondaryHighlightColor;
                    font.underline: true;
                    font.pixelSize: Theme.fontSizeLarge;
                    anchors.verticalCenter: parent.verticalCenter;
                }
            }
            RowContainer {
                spacing: Theme.paddingLarge;
                visible: (pageChatInfoPrivate.userItem && pageChatInfoPrivate.userItem.phoneNumber !== "");
                anchors.margins: Theme.paddingLarge;
                ExtraAnchors.horizontalFill: parent;

                RectangleButton {
                    icon: "icon-m-answer";
                    size: Theme.iconSizeMedium;
                    anchors.verticalCenter: parent.verticalCenter;
                    onClicked: {
                        Qt.openUrlExternally ("tel:+" + pageChatInfoPrivate.userItem.phoneNumber);
                    }
                }
                LabelFixed {
                    text: (pageChatInfoPrivate.userItem ? "+" + pageChatInfoPrivate.userItem.phoneNumber : "");
                    color: Theme.secondaryHighlightColor;
                    font.underline: true;
                    font.pixelSize: Theme.fontSizeLarge;
                    anchors.verticalCenter: parent.verticalCenter;
                }
            }
        }
    }
}
