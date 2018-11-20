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
        if (currentChat.messagesModel.count > 0 && currentChat.lastReadInboxMessageId !== currentChat.messagesModel.lastItem ["id"]) {
            autoScrollDown = false;
            viewMessages.current = currentChat.getMessageItemById (currentChat.lastReadInboxMessageId);
            viewMessages.behavior = FastObjectListView.KEEP_CENTERED;
        }
        else {
            autoScrollDown = true;
        }
    }
    Component.onDestruction: {
        TD_Global.closeChat (currentChat);
    }

    property TD_Chat currentChat : null;

    readonly property TD_User       currentChatUserItem       : (currentChat && currentChat.type.typeOf === TD_ObjectType.CHAT_TYPE_PRIVATE
                                                                 ? TD_Global.getUserItemById (currentChat.type ["userId"])
                                                                 : null);
    readonly property TD_BasicGroup currentChatBasicGroupItem : (currentChat && currentChat.type.typeOf === TD_ObjectType.CHAT_TYPE_BASIC_GROUP
                                                                 ? TD_Global.getBasicGroupItemById (currentChat.type ["basicGroupId"])
                                                                 : null);
    readonly property TD_Supergroup currentChatSupergroupItem : (currentChat && currentChat.type.typeOf === TD_ObjectType.CHAT_TYPE_SUPERGROUP
                                                                 ? TD_Global.getSupergroupItemById (currentChat.type ["supergroupId"])
                                                                 : null);

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
            if (currentChatUserItem) {
                pageStack.pushAttached (compoPageChatInfoPrivate, {
                                            "chatItem" : currentChat,
                                            "userItem" : currentChatUserItem,
                                        });
            }
            else if (currentChatBasicGroupItem) {
                pageStack.pushAttached (compoPageChatInfoBasicGroup, {
                                            "chatItem"       : currentChat,
                                            "basicGroupItem" : currentChatBasicGroupItem,
                                        });
            }
            else if (currentChatSupergroupItem) {
                pageStack.pushAttached (compoPageChatInfoSupergroup, {
                                            "chatItem"       : currentChat,
                                            "supergroupItem" : currentChatSupergroupItem,
                                        });
            }
            else { }
        }
    }
    Timer {
        repeat: true;
        running: true;
        interval: 60000;
        triggeredOnStart: true;
        onTriggered: {
            if (currentChatBasicGroupItem) {
                TD_Global.refreshBasicGroupFullInfo (currentChatBasicGroupItem);
            }
            if (currentChatSupergroupItem) {
                TD_Global.refreshSupergroupFullInfo (currentChatSupergroupItem);
                TD_Global.refreshSupergroupMembers  (currentChatSupergroupItem, 50);
            }
        }
    }
    Timer {
        id: timerSetMode;
        repeat: false;
        running: false;
        interval: 150;
        onTriggered: {
            if (Qt.application.state === Qt.ApplicationActive) {
                if (!flickerMessages.draggingVertically && !flickerMessages.flickingVertically) {
                    if (flickerMessages.atYEnd || flickerMessages.contentHeight < flickerMessages.height) {
                        autoScrollDown = true;
                        TD_Global.markAllMessagesAsRead (currentChat);
                    }
                    else if (flickerMessages.contentY < Theme.paddingMedium) {
                        autoScrollDown = false;
                        viewMessages.current = currentChat.messagesModel.firstItem;
                        viewMessages.behavior = FastObjectListView.KEEP_AT_TOP;
                    }
                    else {
                        autoScrollDown = false;
                    }
                }
            }
        }
    }
    Binding {
        target: viewMessages;
        property: "current";
        value: (currentChat ? currentChat.messagesModel.lastItem : null);
        when: (autoScrollDown && Qt.application.state === Qt.ApplicationActive);
    }
    Binding {
        target: viewMessages;
        property: "behavior";
        value: FastObjectListView.KEEP_AT_BOTTOM;
        when: (autoScrollDown && Qt.application.state === Qt.ApplicationActive);
    }
    SilicaFlickable {
        id: flickerMessages;
        quickScroll: true;
        anchors.fill: parent;
        onDraggingVerticallyChanged: {
            if (Qt.application.state === Qt.ApplicationActive) {
                if (draggingVertically) {
                    autoScrollDown = false;
                }
                else {
                    timerSetMode.restart ();
                }
            }
        }
        onFlickingVerticallyChanged: {
            if (Qt.application.state === Qt.ApplicationActive) {
                if (draggingVertically) {
                    autoScrollDown = false;
                }
                else {
                    timerSetMode.restart ();
                }
            }
        }
        onContentYChanged: {
            if (Qt.application.state === Qt.ApplicationActive) {
                timerSetMode.restart ();
            }
        }

        FastObjectListView {
            id: viewMessages;
            model: (currentChat ? currentChat.messagesModel : 0);
            spaceAfter: footerChat.height;
            spaceBefore: headerChat.height;
            delegate: ListItem {
                id: delegateMsg;
                contentHeight: layoutMessage.height;
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr ("Reply");
                        enabled: false;
                        onClicked: {
                            // TODO
                        }
                    }
                    MenuItem {
                        text: qsTr ("Forward");
                        visible: delegateMsg.messageItem.canBeForwarded;
                        enabled: false;
                        onClicked: {
                            // TODO
                        }
                    }
                    MenuItem {
                        text: qsTr ("Edit");
                        visible: delegateMsg.messageItem.canBeEdited;
                        enabled: false;
                        onClicked: {
                            // TODO
                        }
                    }
                    MenuItem {
                        text: qsTr ("Delete only for me");
                        visible: delegateMsg.messageItem.canBeDeletedOnlyForSelf;
                        enabled: false;
                        onClicked: {
                            // TODO
                        }
                    }
                    MenuItem {
                        text: qsTr ("Delete for all users");
                        visible: delegateMsg.messageItem.canBeDeletedForAllUsers;
                        enabled: false;
                        onClicked: {
                            // TODO
                        }
                    }
                }
                ExtraAnchors.horizontalFill: parent;
                onMenuOpenChanged: {
                    if (menuOpen) {
                        viewMessages.current = messageItem;
                        viewMessages.behavior = FastObjectListView.KEEP_CENTERED;
                    }
                }

                readonly property TD_Message messageItem : modelItem;
                readonly property TD_User    userItem    : (messageItem ? TD_Global.getUserItemById (messageItem.senderUserId) : null);

                Binding {
                    target: loaderMsgContent.item;
                    property: "messageContentItem";
                    value: delegateMsg.messageItem.content;
                    when: (loaderMsgContent.item && delegateMsg.messageItem && delegateMsg.messageItem.content);
                }
                Binding {
                    target: loaderMsgContent.item;
                    property: "messageItem";
                    value: delegateMsg.messageItem;
                    when: (loaderMsgContent.item && delegateMsg.messageItem);
                }
                ColumnContainer {
                    id: layoutMessage;
                    spacing: Theme.paddingSmall;
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
                            spacing: Theme.paddingLarge;
                            anchors.margins: Theme.paddingLarge;
                            ExtraAnchors.topDock: parent;

                            DelegateDownloadableImage {
                                size: Theme.iconSizeMedium;
                                fileItem: (!delegateMsg.messageItem.isChannelPost
                                           ? (delegateMsg.userItem && delegateMsg.userItem.profilePhoto ? delegateMsg.userItem.profilePhoto.big : null)
                                           : (currentChat && currentChat.photo ? currentChat.photo.big : null));
                                autoDownload: true;
                            }
                            ColumnContainer {
                                spacing: 1;
                                Container.horizontalStretch: 1;

                                LabelFixed {
                                    text: (delegateMsg.userItem ? delegateMsg.userItem.firstName + " " + delegateMsg.userItem.lastName : "");
                                    color: Theme.highlightColor;
                                    visible: !delegateMsg.messageItem.isChannelPost;
                                    ExtraAnchors.horizontalFill: parent;
                                }
                                Loader {
                                    id: loaderMsgContent;
                                    sourceComponent: {
                                        if (delegateMsg.messageItem && delegateMsg.messageItem.content) {
                                            switch (delegateMsg.messageItem.content.typeOf) {
                                            case TD_ObjectType.MESSAGE_TEXT:                    return compoMsgText;
                                            case TD_ObjectType.MESSAGE_PHOTO:                   return compoMsgPhoto;
                                            case TD_ObjectType.MESSAGE_DOCUMENT:                return compoMsgDocument;
                                            case TD_ObjectType.MESSAGE_STICKER:                 return compoMsgSticker;
                                            case TD_ObjectType.MESSAGE_VIDEO:                   return compoMsgVideo;
                                            case TD_ObjectType.MESSAGE_AUDIO:                   return compoMsgAudio;
                                            case TD_ObjectType.MESSAGE_ANIMATION:               return compoMsgAnimation;
                                            case TD_ObjectType.MESSAGE_VOICE_NOTE:              return compoMsgVoiceNote;
                                            case TD_ObjectType.MESSAGE_CALL:                    return compoMsgCall;
                                            case TD_ObjectType.MESSAGE_CHAT_JOIN_BY_LINK:       return compoMsgChatJoinByLink;
                                            case TD_ObjectType.MESSAGE_CHAT_ADD_MEMBERS:        return compoMsgChatAddMembers;
                                            case TD_ObjectType.MESSAGE_CHAT_DELETE_MEMBER:      return compoMsgChatDeleteMember;
                                            case TD_ObjectType.MESSAGE_CHAT_CHANGE_TITLE:       return compoMsgChatChangeTitle;
                                            case TD_ObjectType.MESSAGE_CHAT_CHANGE_PHOTO:       return compoMsgChatChangePhoto;
                                            case TD_ObjectType.MESSAGE_CHAT_UPGRADE_FROM:       return compoMsgChatUpgradeFrom;
                                            case TD_ObjectType.MESSAGE_CHAT_UPGRADE_TO:         return compoMsgChatUpgradeTo;
                                            case TD_ObjectType.MESSAGE_CONTACT_REGISTERED:      return compoMsgChatContactRegistered;
                                            case TD_ObjectType.MESSAGE_BASIC_GROUP_CHAT_CREATE: return compoMsgBasicGroupChatCreate;
                                            case TD_ObjectType.MESSAGE_SUPERGROUP_CHAT_CREATE:  return compoMsgSupergroupChatCreate;
                                            }
                                        }
                                        return compoMsgUnsupported;
                                    }
                                    ExtraAnchors.horizontalFill: parent;
                                }
                                RowContainer {
                                    spacing: Theme.paddingMedium;
                                    anchors.right: parent.right;

                                    LabelFixed {
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
                    LabelFixed {
                        id: lblNewMessages;
                        text: qsTr ("New messages");
                        color: Theme.highlightColor;
                        visible: (delegateMsg.messageItem &&
                                  delegateMsg.messageItem.id === currentChat.lastReadInboxMessageId &&
                                  delegateMsg.messageItem !== currentChat.messagesModel.lastItem);
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
        PullDownMenu {
            id: pulleyTop;

            MenuItem {
                text: qsTr ("Load 30 older messages...");
                onDelayedClick: {
                    autoScrollDown = false;
                    viewMessages.behavior = FastObjectListView.KEEP_CENTERED;
                    viewMessages.current = currentChat.messagesModel.firstItem;
                    TD_Global.loadMoreMessages (currentChat, 30);
                }
            }
        }
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

                LabelFixed {
                    text: (currentChat ? currentChat.title : "");
                    color: Theme.highlightColor;
                    elide: Text.ElideRight;
                    horizontalAlignment: Text.AlignRight;
                    font {
                        family: Theme.fontFamilyHeading;
                        pixelSize: Theme.fontSizeLarge;
                    }
                    ExtraAnchors.horizontalFill: parent;
                }
                LabelFixed {
                    color: Theme.secondaryColor;
                    elide: Text.ElideRight;
                    visible: (text !== "");
                    horizontalAlignment: Text.AlignRight;
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
                                var basicGroupItem = TD_Global.getBasicGroupItemById (currentChat.type.basicGroupId);
                                if (basicGroupItem) {
                                    return qsTr ("%1 members").arg (basicGroupItem.memberCount);
                                }
                                break;
                            case TD_ObjectType.CHAT_TYPE_SUPERGROUP:
                                var supergroupItem = TD_Global.getSupergroupItemById (currentChat.type.supergroupId);
                                if (supergroupItem) {
                                    return qsTr ("%1 members").arg (supergroupItem.memberCount);
                                }
                                break;
                            }
                        }
                        return "";
                    }
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
