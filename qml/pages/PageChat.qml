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
        if (currentChat.messagesModel.count > 0 && currentChat.lastReadInboxMessageId !== currentChat.messagesModel.getLast () ["id"]) {
            autoMoveMode = stayOnLastReadMsg;
        }
        else {
            autoMoveMode = stayAtBottom;
        }
    }
    Component.onDestruction: {
        TD_Global.closeChat (currentChat);
    }

    property TD_Chat currentChat : null;

    Binding {
        target: window;
        property: "showInputPanel";
        value: (pageStack.currentPage && page && pageStack.currentPage === page);
    }
    Timer {
        repeat: false;
        running: true;
        interval: 350;
        onTriggered: {
            pageStack.pushAttached (compoPageChatInfo, { });
        }
    }
    SilicaFlickable {
        id: flickerMessages;
        quickScroll: true;
        contentWidth: width;
        contentHeight: layoutMessages.height;
        anchors.fill: parent;
        onMovementStarted: {
            autoMoveMode = stayFree;
        }
        onMovementEnded: {
            if (flickerMessages.atYEnd || flickerMessages.contentHeight < flickerMessages.height) {
                autoMoveMode = stayAtBottom;
                TD_Global.markAllMessagesAsRead (currentChat);
            }
            else if (flickerMessages.atYBeginning) {
                autoMoveMode = stayAtTop;
            }
            else {
                autoMoveMode = stayFree;
            }
        }

        Binding on contentY {
            when: (autoMoveMode === stayAtBottom);
            value: (flickerMessages.contentHeight - flickerMessages.height);
        }
        Binding on contentY {
            when: (autoMoveMode === stayAtTop);
            value: 0;
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
        Column {
            id: layoutMessages;
            ExtraAnchors.topDock: parent;

            Item {
                implicitHeight: headerChat.height;
                ExtraAnchors.horizontalFill: parent;
                Container.forcedHeight: headerChat.height;
            }
            Repeater {
                id: repeaterMessages;
                model: (currentChat ? currentChat.messagesModel : 0);
                delegate: ListItem {
                    id: delegateMsg;
                    contentHeight: layoutMessage.height;
                    menu: ContextMenu {
                        MenuItem {
                            text: qsTr ("Reply");
                            onClicked: {
                                // TODO
                            }
                        }
                        MenuItem {
                            text: qsTr ("Forward");
                            onClicked: {
                                // TODO
                            }
                        }
                        MenuItem {
                            text: qsTr ("Edit");
                            onClicked: {
                                // TODO
                            }
                        }
                        MenuItem {
                            text: qsTr ("Delete");
                            onClicked: {
                                // TODO
                            }
                        }
                    }
                    ExtraAnchors.horizontalFill: parent;

                    readonly property TD_Message messageItem : modelData;
                    readonly property TD_User    userItem    : (messageItem ? TD_Global.getUserItemById (messageItem.senderUserId) : null);

                    Timer {
                        repeat: true;
                        running: (autoMoveMode === stayOnLastReadMsg && currentChat.lastReadInboxMessageId === delegateMsg.messageItem.id);
                        interval: 350;
                        onTriggered: {
                            flickerMessages.contentY = targetY;
                        }

                        readonly property int targetY : (delegateMsg.y /*+ delegateMsg.height - lblNewMessages.height*/ - headerChat.height);
                    }
                    Binding {
                        target: loaderMsgContent.item;
                        property: "messageContentItem";
                        value: delegateMsg.messageItem.content;
                        when: (loaderMsgContent.item && delegateMsg.messageItem && delegateMsg.messageItem.content);
                    }
                    ColumnContainer {
                        id: layoutMessage;
                        spacing: Theme.paddingMedium;
                        ExtraAnchors.topDock: parent;

                        Item {
                            implicitHeight: (layoutMsgContent.height + layoutMsgContent.anchors.margins * 1.5);
                            anchors {
                                leftMargin: (!delegateMsg.messageItem.isOutgoing ? Theme.paddingLarge * 5 : Theme.paddingMedium);
                                rightMargin: (delegateMsg.messageItem.isOutgoing ? Theme.paddingLarge * 5 : Theme.paddingMedium);
                            }
                            ExtraAnchors.horizontalFill: parent;

                            Rectangle {
                                color: Theme.highlightColor;
                                radius: Theme.paddingSmall;
                                opacity: 0.05;
                                antialiasing: true;
                                anchors.fill: parent;
                                anchors.margins: Theme.paddingMedium;
                            }
                            RowContainer {
                                id: layoutMsgContent;
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
                                    RowContainer {
                                        spacing: Theme.paddingMedium;
                                        anchors.right: parent.right;

                                        Label {
                                            text: Qt.formatDateTime (delegateMsg.messageItem.date);
                                            color: Theme.secondaryColor;
                                            font.pixelSize: Theme.fontSizeExtraSmall;
                                            anchors.verticalCenter: parent.verticalCenter;
                                        }
                                        Image {
                                            source: "image://theme/icon-m-acknowledge?%1".arg (Theme.highlightColor);
                                            visible: (delegateMsg.messageItem.isOutgoing && delegateMsg.messageItem.id <= currentChat.lastReadOutboxMessageId);
                                            sourceSize: Qt.size (Theme.iconSizeSmall, Theme.iconSizeSmall);
                                            anchors.verticalCenter: parent.verticalCenter;
                                        }
                                    }
                                }
                            }
                        }
                        Label {
                            id: lblNewMessages;
                            text: qsTr ("New messages");
                            color: Theme.highlightColor;
                            visible: (delegateMsg.messageItem &&
                                      delegateMsg.messageItem.id === currentChat.lastReadInboxMessageId &&
                                      currentChat.messagesModel.count > 0 &&
                                      delegateMsg.messageItem !== currentChat.messagesModel.getLast ());
                            verticalAlignment: Text.AlignBottom;
                            horizontalAlignment: Text.AlignHCenter;
                            font.bold: true;
                            font.pixelSize: Theme.fontSizeSmall;
                            ExtraAnchors.horizontalFill: parent;

                            Rectangle {
                                opacity: 0.15;
                                gradient: Gradient {
                                    GradientStop { position: 0; color: Theme.highlightColor; }
                                    GradientStop { position: 1; color: "transparent"; }
                                }
                                anchors.fill: parent;
                            }
                            Rectangle {
                                implicitHeight: 1;
                                color: Theme.highlightColor;
                                ExtraAnchors.topDock: parent;
                            }
                        }
                    }
                }
            }
            Item {
                implicitHeight: footerChat.height;
                ExtraAnchors.horizontalFill: parent;
                Container.forcedHeight: footerChat.height;
            }
        }
        VerticalScrollDecorator { flickable: parent; }
    }
    MouseArea {
        id: headerChat;
        opacity: (pulleyTop.active ? 0.0 : 1.0);
        implicitHeight: (layoutHeader.height + layoutHeader.anchors.margins * 2);
        ExtraAnchors.topDock: parent;

        Behavior on opacity { NumberAnimation { duration: 150; } }
        Rectangle {
            color: Qt.rgba (1.0 - Theme.primaryColor.r, 1.0 - Theme.primaryColor.g, 1.0 - Theme.primaryColor.b, 0.85);
            anchors.fill: parent;
        }
        RowContainer {
            id: layoutHeader;
            spacing: Theme.paddingMedium;
            anchors {
                left: parent.left;
                right: parent.right;
                margins: Theme.paddingMedium;
                leftMargin: (Theme.paddingLarge * 2);
                rightMargin: (Theme.paddingLarge * 2);
                verticalCenter: parent.verticalCenter;
            }

            ColumnContainer {
                Container.horizontalStretch: 1;
                anchors.verticalCenter: parent.verticalCenter;

                Label {
                    text: (currentChat ? currentChat.title : "");
                    color: Theme.highlightColor;
                    truncationMode: TruncationMode.Fade;
                    horizontalAlignment: Text.AlignRight;
                    font {
                        family: Theme.fontFamilyHeading;
                        pixelSize: Theme.fontSizeLarge;
                    }
                    ExtraAnchors.horizontalFill: parent;
                }
                Label {
                    text: {
                        if (currentChat) {
                            switch (currentChat.type.typeOf) {
                            case TD_ObjectType.CHAT_TYPE_SECRET:
                            case TD_ObjectType.CHAT_TYPE_PRIVATE:
                                var userItem = TD_Global.getUserItemById (currentChat.type.userId);
                                if (userItem && userItem.status) {
                                    switch (userItem.status.typeOf) {
                                    case TD_ObjectType.USER_STATUS_ONLINE:     return qsTr ("Online");
                                    case TD_ObjectType.USER_STATUS_OFFLINE:    return qsTr ("Offline since %1").arg (Qt.formatDateTime (userItem.status.wasOnline));
                                    case TD_ObjectType.USER_STATUS_LAST_MONTH: return qsTr ("Seen last month");
                                    case TD_ObjectType.USER_STATUS_LAST_WEEK:  return qsTr ("Seen last week");
                                    case TD_ObjectType.USER_STATUS_RECENTLY:   return qsTr ("Recently");
                                    case TD_ObjectType.USER_STATUS_EMPTY:      return qsTr ("");
                                    }
                                }
                                break;
                            case TD_ObjectType.CHAT_TYPE_BASIC_GROUP:
                            case TD_ObjectType.CHAT_TYPE_SUPERGROUP:
                                // TODO : online/offline members count
                                break;
                            }
                        }
                        return "";
                    }
                    visible: (text !== "");
                    color: Theme.secondaryColor;
                    truncationMode: TruncationMode.Fade;
                    horizontalAlignment: Text.AlignRight;
                    font {
                        family: Theme.fontFamilyHeading;
                        pixelSize: Theme.fontSizeExtraSmall;
                    }
                    ExtraAnchors.horizontalFill: parent;
                }
            }
            DelegateDownloadableImage {
                size: Theme.iconSizeLarge;
                fileItem: (currentChat && currentChat.photo ? currentChat.photo.big : null);
                autoDownload: true;
                anchors.verticalCenter: parent.verticalCenter;
            }
        }
    }
}
