import QtQuick 2.6;
import QtMultimedia 5.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;
import "../components";

Page {
    id: page;
    allowedOrientations: Orientation.All;
    Component.onCompleted: {
        TD_Global.openChat (currentChat);
    }
    Component.onDestruction: {
        TD_Global.closeChat (currentChat);
    }

    property TD_Chat currentChat : null;

    property int autoMoveMode : stayAtBottom;

    readonly property int stayFree     : 0;
    readonly property int stayAtTop    : 1;
    readonly property int stayAtBottom : 2;

    SilicaFlickable {
        id: flickerMessages;
        quickScroll: true;
        contentWidth: width;
        contentHeight: layoutMessages.height;
        anchors.fill: parent;
        onContentYChanged: {
            timerAutoMoveMove.restart ();
        }

        Binding on contentY {
            when: (autoMoveMode === stayAtBottom);
            value: (flickerMessages.contentHeight - flickerMessages.height);
        }
        Binding on contentY {
            when: (autoMoveMode === stayAtTop);
            value: 0;
        }
        Timer {
            id: timerAutoMoveMove;
            repeat: false;
            running: false;
            interval: 150;
            onTriggered: {
                if (flickerMessages.flicking || flickerMessages.dragging) {
                    autoMoveMode = stayFree;
                }
                else {
                    if (flickerMessages.atYBeginning) {
                        autoMoveMode = stayAtTop;
                    }
                    else if (flickerMessages.atYEnd) {
                        autoMoveMode = stayAtBottom;
                    }
                    else {
                        autoMoveMode = stayFree;
                    }
                }
            }
        }
        PullDownMenu {
            id: pulleyTop;

            MenuItem {
                text: qsTr ("Load 20 older messages...");
                onClicked: {
                    TD_Global.loadMoreMessages (currentChat, 20);
                }
            }
        }
        ColumnContainer {
            id: layoutMessages;
            ExtraAnchors.topDock: parent;

            Item {
                ExtraAnchors.horizontalFill: parent;
                Container.forcedHeight: headerChat.height;
            }
            Repeater {
                model: (currentChat ? currentChat.messagesModel : 0);
                delegate: Item {
                    id: delegateMsg;
                    implicitHeight: (layoutMsg.height + layoutMsg.anchors.margins * 1.5);
                    anchors {
                        leftMargin: (!delegateMsg.messageItem.isOutgoing ? Theme.paddingLarge * 5 : Theme.paddingMedium);
                        rightMargin: (delegateMsg.messageItem.isOutgoing ? Theme.paddingLarge * 5 : Theme.paddingMedium);
                    }
                    ExtraAnchors.horizontalFill: parent;

                    readonly property TD_Message messageItem : modelData;
                    readonly property TD_User    userItem    : (messageItem ? TD_Global.getUserItemById (messageItem.senderUserId) : null);

                    Binding {
                        target: loaderMsgContent.item;
                        property: "messageContentItem";
                        value: delegateMsg.messageItem.content;
                        when: (loaderMsgContent.item && delegateMsg.messageItem && delegateMsg.messageItem.content);
                    }
                    Rectangle {
                        color: Theme.highlightColor;
                        radius: Theme.paddingSmall;
                        opacity: 0.05;
                        antialiasing: true;
                        anchors.fill: parent;
                        anchors.margins: Theme.paddingMedium;
                    }
                    RowContainer {
                        id: layoutMsg;
                        spacing: Theme.paddingSmall;
                        anchors.margins: Theme.paddingLarge;
                        ExtraAnchors.topDock: parent;

                        DelegateDownloadableImage {
                            size: Theme.iconSizeMedium;
                            fileItem: (delegateMsg.userItem && delegateMsg.userItem.profilePhoto ? delegateMsg.userItem.profilePhoto.big : null);
                            autoDownload: true;
                        }
                        ColumnContainer {
                            spacing: 1;
                            Container.horizontalStretch: 1;

                            Label {
                                text: (delegateMsg.userItem ? delegateMsg.userItem.firstName + " " + delegateMsg.userItem.lastName : "");
                                color: Theme.highlightColor;
                                ExtraAnchors.horizontalFill: parent;
                            }
                            Loader {
                                id: loaderMsgContent;
                                sourceComponent: {
                                    if (delegateMsg.messageItem && delegateMsg.messageItem.content) {
                                        switch (delegateMsg.messageItem.content.typeOf) {
                                        case TD_ObjectType.MESSAGE_TEXT:       return compoMsgText;
                                        case TD_ObjectType.MESSAGE_PHOTO:      return compoMsgPhoto;
                                        case TD_ObjectType.MESSAGE_DOCUMENT:   return compoMsgDocument;
                                        case TD_ObjectType.MESSAGE_STICKER:    return compoMsgSticker;
                                        case TD_ObjectType.MESSAGE_VIDEO:      return compoMsgVideo;
                                        case TD_ObjectType.MESSAGE_AUDIO:      return compoMsgAudio;
                                        case TD_ObjectType.MESSAGE_ANIMATION:  return compoMsgAnimation;
                                        case TD_ObjectType.MESSAGE_VOICE_NOTE: return compoMsgVoiceNote;
                                        }
                                    }
                                    return compoMsgUnsupported;
                                }
                                ExtraAnchors.horizontalFill: parent;
                            }
                            Label {
                                text: Qt.formatDateTime (new Date (delegateMsg.messageItem.date * 1000));
                                color: Theme.secondaryColor;
                                font.pixelSize: Theme.fontSizeExtraSmall;
                                anchors.right: parent.right;
                            }
                        }
                    }
                }
            }
            Item {
                ExtraAnchors.horizontalFill: parent;
                Container.forcedHeight: footerChat.height;
            }
        }
        VerticalScrollDecorator { flickable: parent; }
    }
    MouseArea {
        id: headerChat;
        opacity: (pulleyTop.active ? 0.0 : 1.0);
        implicitHeight: (Math.max (headerIcon.height, headerText.height) + Theme.paddingMedium * 2);
        ExtraAnchors.topDock: parent;

        Behavior on opacity { NumberAnimation { duration: 150; } }
        Rectangle {
            color: Qt.rgba (1.0 - Theme.primaryColor.r, 1.0 - Theme.primaryColor.g, 1.0 - Theme.primaryColor.b, 0.85);
            anchors.fill: parent;
        }
        Label {
            id: headerText;
            text: (currentChat ? currentChat.title : "");
            color: Theme.highlightColor;
            truncationMode: TruncationMode.Fade;
            horizontalAlignment: Text.AlignRight;
            font {
                family: Theme.fontFamilyHeading;
                pixelSize: Theme.fontSizeLarge;
            }
            anchors {
                left: parent.left;
                right: headerIcon.left;
                leftMargin: (Theme.paddingLarge * 2);
                rightMargin: Theme.paddingMedium;
                verticalCenter: parent.verticalCenter;
            }
        }
        DelegateDownloadableImage {
            id: headerIcon;
            size: Theme.iconSizeLarge;
            fileItem: (currentChat && currentChat.photo ? currentChat.photo.big : null);
            autoDownload: true;
            anchors {
                right: parent.right;
                rightMargin: Theme.paddingMedium;
                verticalCenter: parent.verticalCenter;
            }
        }
    }
}
