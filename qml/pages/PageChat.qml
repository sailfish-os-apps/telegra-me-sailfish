import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;
import "../components";

Page {
    id: page;
    allowedOrientations: Orientation.All;
    Component.onCompleted: {
        TD_Global.openChat (currentChat);
        if (currentChat.unreadCount > 0) {
            // should wait for first unread msg to become valid and center on it
        }
        else {
            initialized = true;
            scrollToBottom ();
        }
    }
    Component.onDestruction: {
        TD_Global.closeChat (currentChat);
    }
    onContainsFirstUnreadMsgChanged: {
        if (!initialized && containsFirstUnreadMsg) {
            centerOnMsg (currentChat.firstUnreadMessageItem.id);
            initialized = true;
        }
    }
    onShouldMarkAllAsReadChanged: {
        if (shouldMarkAllAsRead) {
            TD_Global.markAllMessagesAsRead (currentChat);
        }
    }

    property bool initialized    : false;
    property bool autoScrollDown : false;

    property TD_Chat currentChat : null;

    property string currentMessageId : "";

    readonly property TD_MessageRefWatcher currentMessageRefWatcher : (currentChat && currentMessageId !== ""
                                                                       ? currentChat.getMessageRefById (currentMessageId)
                                                                       : null);

    readonly property TD_Message currentMessageItem : (currentMessageRefWatcher
                                                       ? currentMessageRefWatcher.messageItem
                                                       : null);

    readonly property TD_MessageRefWatcher replyingToMessageRefWatcher : (currentChat && TD_Global.replyingToMessageId !== ""
                                                                          ? currentChat.getMessageRefById (TD_Global.replyingToMessageId)
                                                                          : null);

    readonly property TD_Message replyingToMessageItem : (replyingToMessageRefWatcher
                                                          ? replyingToMessageRefWatcher.messageItem
                                                          : null);

    readonly property TD_MessageRefWatcher editingMessageRefWatcher : (currentChat && TD_Global.editingMessageId !== ""
                                                                       ? currentChat.getMessageRefById (TD_Global.editingMessageId)
                                                                       : null);

    readonly property TD_Message editingToMessageItem : (editingMessageRefWatcher
                                                         ? editingMessageRefWatcher.messageItem
                                                         : null);

    readonly property TD_MessageRefWatcher pinnedMessageRefWatcher : (currentChat && currentChat.pinnedMessageId
                                                                      ? currentChat.getMessageRefById (currentChat.pinnedMessageId)
                                                                      : null);

    readonly property TD_Message pinnedMessageItem : (pinnedMessageRefWatcher
                                                      ? pinnedMessageRefWatcher.messageItem
                                                      : null);

    readonly property TD_User currentChatUserItem : (currentChat && currentChat.type.typeOf === TD_ObjectType.CHAT_TYPE_PRIVATE
                                                     ? TD_Global.getUserItemById (currentChat.type ["userId"])
                                                     : null);

    readonly property TD_ChatTypePrivate currentChatTypePrivateItem : (currentChat && currentChat.type.typeOf === TD_ObjectType.CHAT_TYPE_PRIVATE
                                                                       ? currentChat.type
                                                                       : null);

    readonly property TD_ChatAction currentChatActionItem : (currentChatTypePrivateItem
                                                             ? currentChatTypePrivateItem.currentChatAction
                                                             : null);

    readonly property TD_BasicGroup currentChatBasicGroupItem : (currentChat && currentChat.type.typeOf === TD_ObjectType.CHAT_TYPE_BASIC_GROUP
                                                                 ? TD_Global.getBasicGroupItemById (currentChat.type ["basicGroupId"])
                                                                 : null);

    readonly property TD_Supergroup currentChatSupergroupItem : (currentChat && currentChat.type.typeOf === TD_ObjectType.CHAT_TYPE_SUPERGROUP
                                                                 ? TD_Global.getSupergroupItemById (currentChat.type ["supergroupId"])
                                                                 : null);

    readonly property bool currentlyOnApp         : (Qt.application.state === Qt.ApplicationActive);
    readonly property bool viewPositionedAtEnd    : (flickerMessages.atYEnd);
    readonly property bool containsFirstUnreadMsg : (currentChat &&
                                                     currentChat.firstUnreadMessageItem);
    readonly property bool containsLastReadMsg    : (currentChat &&
                                                     currentChat.oldestFetchedMessageId <= currentChat.lastReadInboxMessageId &&
                                                     currentChat.newestFetchedMessageId >= currentChat.lastReadInboxMessageId);
    readonly property bool shouldMarkAllAsRead    : (currentlyOnApp &&
                                                     initialized &&
                                                     viewPositionedAtEnd &&
                                                     autoScrollDown &&
                                                     currentChat.hasReachedLast); // FIXME : remove hasReachedLast test when TDLIB >= 1.3

    function scrollToTop () {
        autoScrollDown   = false;
        currentMessageId = "";
        flickerMessages.contentY = 0;
    }

    function scrollToBottom () {
        currentMessageId = "";
        autoScrollDown   = true;
    }

    function longJumpToMsg (messageId) {
        autoScrollDown   = false;
        currentMessageId = messageId;
        TD_Global.loadInitialMessage (currentChat, messageId);
    }

    function centerOnMsg (messageId) {
        autoScrollDown   = false;
        currentMessageId = messageId;
    }

    Binding {
        target: Helpers;
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
    SilicaFlickable {
        id: flickerMessages;
        clip: true;
        quickScroll: false;
        anchors.fill: parent;
        anchors.bottomMargin: layoutBottom.height;
        onDraggingVerticallyChanged: {
            currentMessageId = "";
            autoScrollDown   = atYEnd;
        }
        onFlickingVerticallyChanged: {
            currentMessageId = "";
            autoScrollDown   = atYEnd;
        }

        FastObjectListView {
            id: viewMessages;

            Binding on current {
                value: (currentlyOnApp
                        ? (autoScrollDown
                           ? currentChat.messagesModel.lastItem
                           : currentMessageItem)
                        : null);
            }
            Binding on behavior {
                value: (currentlyOnApp
                        ? (autoScrollDown
                           ? FastObjectListView.KEEP_AT_BOTTOM
                           : (currentMessageItem
                              ? FastObjectListView.KEEP_CENTERED
                              : FastObjectListView.FREE_MOVE))
                        : FastObjectListView.FREE_MOVE);
            }

            model: (currentChat ? currentChat.messagesModel : 0);
            spaceBefore: layoutTop.height;
            //spaceAfter: layoutBottom.height;
            delegate: ListItem {
                id: delegateMsg;
                contentHeight: layoutMessage.height;
                menu: ContextMenu {
                    Repeater {
                        model: (loaderMsgContent.item ? loaderMsgContent.item ["additionalContextMenuItems"] : 0);
                    }
                    MenuItem {
                        text: qsTr ("Reply...");
                        onClicked: {
                            TD_Global.replyingToMessageId = delegateMsg.messageItem.id;
                        }
                    }
                    MenuItem {
                        text: qsTr ("Forward [TODO]");
                        visible: delegateMsg.messageItem.canBeForwarded;
                        enabled: false;
                        onClicked: {
                            // TODO
                        }
                    }
                    MenuItem {
                        text: (textItem
                               ? qsTr ("Edit text")
                               : (captionItem
                                  ? qsTr ("Edit caption")
                                  : ""));
                        visible: (delegateMsg.messageItem.canBeEdited && (textItem || captionItem));
                        onClicked: {
                            TD_Global.editingMessageId = delegateMsg.messageItem.id;
                            TD_Global.editFormattedText (textItem || captionItem);
                        }

                        readonly property TD_FormattedText textItem : (delegateMsg.messageItem &&
                                                                       delegateMsg.messageItem.content &&
                                                                       "text" in delegateMsg.messageItem.content
                                                                       ? delegateMsg.messageItem.content ["text"]
                                                                       : null);
                        readonly property TD_FormattedText captionItem : (delegateMsg.messageItem &&
                                                                          delegateMsg.messageItem.content &&
                                                                          "caption" in delegateMsg.messageItem.content
                                                                          ? delegateMsg.messageItem.content ["caption"]
                                                                          : null);
                    }
                    MenuItem {
                        text: qsTr ("Delete only for me");
                        visible: delegateMsg.messageItem.canBeDeletedOnlyForSelf;
                        onClicked: {
                            delegateMsg.showRemorseItem (false);
                        }
                    }
                    MenuItem {
                        text: qsTr ("Delete for all users");
                        visible: delegateMsg.messageItem.canBeDeletedForAllUsers;
                        onClicked: {
                            delegateMsg.showRemorseItem (true);
                        }
                    }
                }
                ExtraAnchors.horizontalFill: parent;

                readonly property TD_Message messageItem : modelItem;
                readonly property TD_User    userItem    : (messageItem ? TD_Global.getUserItemById (messageItem.senderUserId) : null);

                function showRemorseItem (forAll) {
                    remorse.execute (delegateMsg, qsTr ("Deleting"), function () {
                        TD_Global.removeMessage (currentChat, messageItem, forAll);
                    });
                }

                RemorseItem { id: remorse; }
                Rectangle {
                    color: Theme.rgba (Theme.secondaryHighlightColor, (delegateMsg.messageItem.containsUnreadMention ? 0.35 : 0.10));
                    visible: (delegateMsg.messageItem.id === currentMessageId || delegateMsg.messageItem.containsUnreadMention);
                    anchors.fill: parent;
                }
                ColumnContainer {
                    id: layoutMessage;
                    ExtraAnchors.topDock: parent;

                    Loader {
                        active: (delegateMsg.messageItem && currentChat && currentChat.firstUnreadMessageItem && currentChat.firstUnreadMessageItem.id === delegateMsg.messageItem.id);
                        visible: active;
                        sourceComponent: LabelFixed {
                            text: qsTr ("New messages");
                            color: Theme.highlightColor;
                            verticalAlignment: Text.AlignBottom;
                            horizontalAlignment: Text.AlignHCenter;
                            font.bold: true;
                            font.pixelSize: Theme.fontSizeSmall;

                            Rectangle {
                                gradient: Gradient {
                                    GradientStop { position: 0; color: Theme.rgba (Theme.highlightColor, 0.15); }
                                    GradientStop { position: 1; color: "transparent"; }
                                }
                                anchors.fill: parent;
                            }
                            Rectangle {
                                color: Theme.highlightColor;
                                implicitHeight: 1;
                                ExtraAnchors.topDock: parent;
                            }
                        }
                        ExtraAnchors.horizontalFill: parent;
                    }
                    Item {
                        Container.forcedHeight: Theme.paddingSmall;
                    }
                    RowContainer {
                        id: room;
                        anchors.margins: Theme.paddingMedium;
                        ExtraAnchors.horizontalFill: parent;

                        Item {
                            visible: delegateMsg.messageItem.isOutgoing;
                            Container.horizontalStretch: 1;
                        }
                        Item {
                            id: content;
                            implicitWidth: ((lblReply.visible
                                             ? maxWidth
                                             : (optWidth > 0
                                                ? Helpers.clamp (optWidth, minWidth, maxWidth)
                                                : maxWidth)) + layoutMsgContent.anchors.margins * 2);
                            implicitHeight: (layoutMsgContent.height + layoutMsgContent.anchors.margins * 2);

                            readonly property int maxWidth : (room.width - Theme.paddingLarge * 3.65);
                            readonly property int minWidth : (Math.max (layoutMsgAuthor.implicitWidth, layoutMsgStatus.implicitWidth));
                            readonly property int optWidth : (loaderMsgContent.messageContentDelegate
                                                              ? (loaderMsgContent.messageContentDelegate.optimalWidth)
                                                              : 0);

                            Rectangle {
                                color: Theme.rgba (delegateMsg.messageItem.isOutgoing ? Theme.primaryColor : Theme.highlightColor, 0.10);
                                radius: Theme.paddingMedium;
                                visible: Helpers.showBubblesAroundMessages;
                                antialiasing: true;
                                anchors.fill: parent;
                            }
                            ColumnContainer {
                                id: layoutMsgContent;
                                spacing: Theme.paddingSmall;
                                anchors.margins: Theme.paddingMedium;
                                ExtraAnchors.topDock: parent;

                                RowContainer {
                                    id: layoutMsgAuthor;
                                    spacing: Theme.paddingMedium;

                                    MouseArea {
                                        anchors.fill: parent;
                                        Container.ignored: true;
                                        onClicked: {
                                            pageStack.push (compoPageUserInfo, {
                                                                "userItem" : delegateMsg.userItem,
                                                            });
                                        }
                                    }
                                    DelegateAvatar {
                                        size: Theme.iconSizeSmall;
                                        fileItem: (!delegateMsg.messageItem.isChannelPost
                                                   ? (delegateMsg.userItem && delegateMsg.userItem.profilePhoto ? delegateMsg.userItem.profilePhoto.big : null)
                                                   : (currentChat && currentChat.photo ? currentChat.photo.big : null));
                                        anchors.verticalCenter: parent.verticalCenter;
                                    }
                                    LabelFixed {
                                        text: (delegateMsg.userItem ? delegateMsg.userItem.firstName + " " + delegateMsg.userItem.lastName : "");
                                        color: Theme.highlightColor;
                                        elide: Text.ElideRight;
                                        visible: !delegateMsg.messageItem.isChannelPost;
                                        font.bold: true;
                                        font.pixelSize: Theme.fontSizeSmall;
                                        anchors.verticalCenter: parent.verticalCenter;
                                        Container.horizontalStretch: 1;
                                    }
                                }
                                LabelFixed {
                                    id: lblReply;
                                    text: qsTr ("<b>Reply to</b>: %1").arg (originalMessageItem ? originalMessageItem.preview (TD_Message.SHOW_TITLE | TD_Message.MULTILINE).replace (/\n/g, "<br>") : qsTr ("<i>deleted message</i>"));
                                    color: Theme.secondaryHighlightColor;
                                    elide: Text.ElideRight;
                                    visible: originalMsgRefWatcher;
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                                    textFormat: Text.StyledText;
                                    maximumLineCount: 3;
                                    font.pixelSize: Theme.fontSizeSmall;
                                    ExtraAnchors.horizontalFill: parent;

                                    readonly property TD_MessageRefWatcher originalMsgRefWatcher : currentChat.getMessageRefById (delegateMsg.messageItem.replyToMessageId);
                                    readonly property TD_Message           originalMessageItem   : (originalMsgRefWatcher ? originalMsgRefWatcher.messageItem : null);

                                    MouseArea {
                                        enabled: parent.originalMessageItem;
                                        anchors.fill: parent;
                                        anchors.margins: -Theme.paddingSmall;
                                        onClicked: {
                                            longJumpToMsg (delegateMsg.messageItem.replyToMessageId);
                                        }
                                    }
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
                                            case TD_ObjectType.MESSAGE_PIN_MESSAGE:             return compoMsgPinMessage;
                                            case TD_ObjectType.MESSAGE_BASIC_GROUP_CHAT_CREATE: return compoMsgBasicGroupChatCreate;
                                            case TD_ObjectType.MESSAGE_SUPERGROUP_CHAT_CREATE:  return compoMsgSupergroupChatCreate;
                                            }
                                        }
                                        return compoMsgUnsupported;
                                    }
                                    ExtraAnchors.horizontalFill: parent;

                                    readonly property DelegateAbstractMessageContent messageContentDelegate : item;

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
                                    Binding {
                                        target: loaderMsgContent.item;
                                        property: "chatItem";
                                        value: currentChat;
                                        when: (loaderMsgContent.item && currentChat);
                                    }
                                }
                                RowContainer {
                                    id: layoutMsgStatus;
                                    spacing: Theme.paddingMedium;
                                    anchors.right: parent.right;

                                    LabelFixed {
                                        text: ((delegateMsg.messageItem.editDate.getFullYear () > 2000)
                                               ? (qsTr ("edited") + " " + Qt.formatDateTime (delegateMsg.messageItem.editDate, "ddd d MMM, hh:mm:ss"))
                                               : Qt.formatDateTime (delegateMsg.messageItem.date, "ddd d MMM, hh:mm:ss"));
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
                        Item {
                            visible: !delegateMsg.messageItem.isOutgoing;
                            Container.horizontalStretch: 1;
                        }
                    }
                    Item {
                        Container.forcedHeight: Theme.paddingSmall;
                    }
                }
            }
        }
        PullDownMenu {
            id: pulleyTop;
            visible: enabled;
            enabled: (currentChat && !currentChat.hasReachedFirst);

            MenuItem {
                text: qsTr ("Load older messages...");
                onClicked: {
                    centerOnMsg (currentChat.messagesModel.firstItem.id);
                    TD_Global.loadOlderMessages (currentChat);
                }
            }
        }
        PushUpMenu {
            id: pulleyBottom;
            visible: enabled;
            enabled: (currentChat && !currentChat.hasReachedLast);

            MenuItem {
                text: qsTr ("Load newer messages...");
                onClicked: {
                    centerOnMsg (currentChat.messagesModel.lastItem.id);
                    TD_Global.loadNewerMessages (currentChat);
                }
            }
            MenuItem {
                text: qsTr ("Mark all read in chat");
                onClicked: {
                    longJumpToMsg (currentChat.lastReceivedMessageId);
                    TD_Global.loadNewerMessages (currentChat);
                    scrollToBottom ();
                }
            }
        }
    }
    Item {
        id: scrollBar;
        state: (!pulleyTop.active && !pulleyBottom.active && (flickerMessages.flickingVertically || flickerMessages.draggingVertically) ? "shown" : "hidden");
        opacity: 0.0;
        enabled: false;
        implicitWidth: Theme.itemSizeLarge;
        states: [
            State {
                name: "shown";
            },
            State {
                name: "hidden";
            }
        ]
        transitions: [
            Transition {
                from: "hidden";
                to: "shown";

                SequentialAnimation {
                    alwaysRunToEnd: true;

                    PauseAnimation {
                        duration: 150;
                    }
                    PropertyAction {
                        target: scrollBar;
                        property: "enabled";
                        value: true;
                    }
                    PropertyAnimation {
                        target: scrollBar;
                        property: "opacity";
                        to: 1.0;
                        duration: 350;
                    }
                }
            },
            Transition {
                from: "shown";
                to: "hidden";

                SequentialAnimation {
                    alwaysRunToEnd: true;

                    PauseAnimation {
                        duration: 850;
                    }
                    PropertyAnimation {
                        target: scrollBar;
                        property: "opacity";
                        to: 0.0;
                        duration: 350;
                    }
                    PropertyAction {
                        target: scrollBar;
                        property: "enabled";
                        value: false;
                    }
                }
            }
        ]
        anchors {
            top: layoutTop.bottom;
            right: parent.right;
            bottom: layoutBottom.top;
        }

        Behavior on opacity { NumberAnimation { duration: 650; } }
        Rectangle {
            color: Theme.rgba (Theme.highlightColor, 0.15);
            anchors.fill: parent;
        }
        Rectangle {
            y: (parent.height * flickerMessages.visibleArea.yPosition);
            color: Theme.primaryColor;
            implicitWidth: Theme.paddingSmall;
            implicitHeight: (flickerMessages.visibleArea.heightRatio * parent.height);
            anchors.right: parent.right;
        }
        ColumnContainer {
            anchors.centerIn: parent;

            MouseArea {
                opacity: (flickerMessages.atYBeginning ? 0.15 : 1.0);
                implicitWidth: Theme.itemSizeLarge;
                implicitHeight: Theme.itemSizeLarge;
                onClicked: {
                    scrollToTop ();
                }

                Image {
                    source: "image://theme/icon-m-page-up?%1".arg (parent.pressed ? Theme.highlightColor : Theme.primaryColor);
                    sourceSize: Qt.size (Theme.iconSizeMedium, Theme.iconSizeMedium);
                    anchors.centerIn: parent;
                }
            }
            MouseArea {
                opacity: (flickerMessages.atYEnd ? 0.15 : 1.0);
                implicitWidth: Theme.itemSizeLarge;
                implicitHeight: Theme.itemSizeLarge;
                onClicked: {
                    scrollToBottom ();
                }

                Image {
                    source: "image://theme/icon-m-page-down?%1".arg (parent.pressed ? Theme.highlightColor : Theme.primaryColor);
                    sourceSize: Qt.size (Theme.iconSizeMedium, Theme.iconSizeMedium);
                    anchors.centerIn: parent;
                }
            }
        }
    }
    ColumnContainer {
        id: layoutTop;
        opacity: (pulleyTop.active ? 0.65 : 1.0);
        anchors.topMargin: Math.max (-flickerMessages.contentY, 0);
        ExtraAnchors.topDock: parent;

        Behavior on opacity { NumberAnimation { duration: 150; } }
        MouseArea {
            id: headerChat;
            visible: !Helpers.hideChatHeader;
            implicitHeight: (layoutHeader.height + layoutHeader.anchors.margins * 2);
            ExtraAnchors.horizontalFill: parent;
            onPressed: { }
            onReleased: { }

            PanelFixed {
                anchors.fill: parent;

                Rectangle {
                    color: Theme.rgba (Theme.secondaryHighlightColor, 0.65);
                    visible: flickerMessages.atYBeginning;
                    implicitHeight: Theme.paddingSmall;
                    ExtraAnchors.topDock: parent;
                }
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
                    RowContainer {
                        spacing: Theme.paddingMedium;
                        anchors.right: parent.right;

                        Rectangle {
                            color: "lime";
                            radius: (Theme.paddingMedium * 0.5);
                            visible: (currentChatUserItem &&
                                      currentChatUserItem.status &&
                                      currentChatUserItem.status.typeOf === TD_ObjectType.USER_STATUS_ONLINE);
                            antialiasing: true;
                            implicitWidth: Theme.paddingMedium;
                            implicitHeight: Theme.paddingMedium;
                            anchors.verticalCenter: parent.verticalCenter;
                        }
                        LabelFixed {
                            color: Theme.secondaryColor;
                            elide: Text.ElideRight;
                            visible: (text !== "");
                            text: {
                                if (currentChat) {
                                    switch (currentChat.type.typeOf) {
                                    case TD_ObjectType.CHAT_TYPE_SECRET:
                                    case TD_ObjectType.CHAT_TYPE_PRIVATE:
                                        if (currentChatUserItem && currentChatUserItem.status) {
                                            switch (currentChatUserItem.status.typeOf) {
                                            case TD_ObjectType.USER_STATUS_ONLINE:     return qsTr ("Online");
                                            case TD_ObjectType.USER_STATUS_OFFLINE:    return qsTr ("Offline since %1").arg (Qt.formatDateTime (currentChatUserItem.status.wasOnline, "d MMM, hh:mm"));
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
                        }
                        LabelFixed {
                            color: Theme.secondaryColor;
                            elide: Text.ElideRight;
                            visible: (text !== "");
                            text: {
                                if (currentChat) {
                                    switch (currentChat.type.typeOf) {
                                    case TD_ObjectType.CHAT_TYPE_PRIVATE:
                                        if (currentChatActionItem) {
                                            switch (currentChatActionItem.typeOf) {
                                            case TD_ObjectType.CHAT_ACTION_TYPING:               return qsTr ("(Typing...)");
                                            case TD_ObjectType.CHAT_ACTION_CHOOSING_CONTACT:     return qsTr ("(Choosing contact...)");
                                            case TD_ObjectType.CHAT_ACTION_CHOOSING_LOCATION:    return qsTr ("(Choosing location...)");
                                            case TD_ObjectType.CHAT_ACTION_RECORDING_VIDEO:      return qsTr ("(Recording video...)");
                                            case TD_ObjectType.CHAT_ACTION_RECORDING_VIDEO_NOTE: return qsTr ("(Recording video-note...)");
                                            case TD_ObjectType.CHAT_ACTION_RECORDING_VOICE_NOTE: return qsTr ("(Recording voice-note...)");
                                            case TD_ObjectType.CHAT_ACTION_START_PLAYING_GAME:   return qsTr ("(Playing...)");
                                            case TD_ObjectType.CHAT_ACTION_UPLOADING_DOCUMENT:   return qsTr ("(Uploading file...)");
                                            case TD_ObjectType.CHAT_ACTION_UPLOADING_PHOTO:      return qsTr ("(Uploading photo...)");
                                            case TD_ObjectType.CHAT_ACTION_UPLOADING_VIDEO:      return qsTr ("(Uploading video...)");
                                            case TD_ObjectType.CHAT_ACTION_UPLOADING_VIDEO_NOTE: return qsTr ("(Uploading video-note...)");
                                            case TD_ObjectType.CHAT_ACTION_UPLOADING_VOICE_NOTE: return qsTr ("(Uploading voice-note...)");
                                            case TD_ObjectType.CHAT_ACTION_CANCEL:               return "";
                                            }
                                        }
                                        break;
                                    case TD_ObjectType.CHAT_TYPE_SECRET:
                                    case TD_ObjectType.CHAT_TYPE_BASIC_GROUP:
                                    case TD_ObjectType.CHAT_TYPE_SUPERGROUP:
                                       break;
                                    }
                                }
                                return "";
                            }
                            font {
                                family: Theme.fontFamilyHeading;
                                pixelSize: Theme.fontSizeExtraSmall;
                            }
                        }

                    }
                }
                DelegateAvatar {
                    size: Theme.iconSizeMedium;
                    fileItem: (currentChat && currentChat.photo ? currentChat.photo.big : null);
                    anchors.verticalCenter: parent.verticalCenter;
                }
            }
        }
        PanelFixed {
            id: stripPinned;
            visible: (pinnedMessageItem !== null);
            implicitHeight: (lblPinned.height + lblPinned.anchors.margins * 2);
            ExtraAnchors.horizontalFill: parent;

            Rectangle {
                color: Theme.rgba (Theme.secondaryHighlightColor, 0.15);
                anchors.fill: parent;
            }
            MouseArea {
                anchors.fill: parent;
                onClicked: {
                    longJumpToMsg (pinnedMessageItem.id);
                }
            }
            LabelFixed {
                id: lblPinned;
                text: qsTr ("<b>Pinned</b>: %1").arg (pinnedMessageItem ? pinnedMessageItem.preview (TD_Message.MINIMAL) : qsTr ("<i>deleted message</i>"));
                color: Theme.secondaryHighlightColor;
                elide: Text.ElideRight;
                textFormat: Text.StyledText;
                font.pixelSize: Theme.fontSizeExtraSmall;
                anchors {
                    margins: Theme.paddingSmall;
                    verticalCenter: parent.verticalCenter;
                }
                ExtraAnchors.horizontalFill: parent;
            }
        }
    }
    ColumnContainer {
        id: layoutBottom;
        ExtraAnchors.bottomDock: parent;

        Item {
            id: stripReplyTo;
            visible: (replyingToMessageItem !== null);
            implicitHeight: (layoutReplyTo.height + layoutReplyTo.anchors.margins * 2);
            ExtraAnchors.horizontalFill: parent;

            PanelFixed {
                anchors.fill: parent;

                Rectangle {
                    color: Theme.rgba (Theme.secondaryHighlightColor, 0.15);
                    anchors.fill: parent;
                }
            }
            RowContainer {
                id: layoutReplyTo;
                spacing: Theme.paddingMedium;
                anchors {
                    margins: Theme.paddingMedium;
                    verticalCenter: parent.verticalCenter;
                }
                ExtraAnchors.horizontalFill: parent;

                LabelFixed {
                    text: qsTr ("<b>Reply</b>: %1").arg (replyingToMessageItem ? replyingToMessageItem.preview (TD_Message.SHOW_TITLE | TD_Message.MULTILINE).replace (/\n/g, "<br>") : qsTr ("<i>deleted message</i>"));
                    color: Theme.secondaryHighlightColor;
                    elide: Text.ElideRight;
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                    textFormat: Text.StyledText;
                    maximumLineCount: 3;
                    font.pixelSize: Theme.fontSizeSmall;
                    anchors.verticalCenter: parent.verticalCenter;
                    Container.horizontalStretch: 1;
                }
                RectangleButton {
                    icon: "icon-m-clear";
                    anchors.verticalCenter: parent.verticalCenter;
                    onClicked: {
                        TD_Global.replyingToMessageId = "";
                    }
                }
            }
        }
        Item {
            id: stripEdit;
            visible: (editingToMessageItem !== null);
            implicitHeight: (layoutEdit.height + layoutEdit.anchors.margins * 2);
            ExtraAnchors.horizontalFill: parent;

            PanelFixed {
                anchors.fill: parent;

                Rectangle {
                    color: Theme.rgba (Theme.secondaryHighlightColor, 0.15);
                    anchors.fill: parent;
                }
            }
            RowContainer {
                id: layoutEdit;
                spacing: Theme.paddingMedium;
                anchors {
                    margins: Theme.paddingMedium;
                    verticalCenter: parent.verticalCenter;
                }
                ExtraAnchors.horizontalFill: parent;

                LabelFixed {
                    text: qsTr ("<b>Edit</b>: %1").arg (editingToMessageItem ? editingToMessageItem.preview (TD_Message.SHOW_TITLE | TD_Message.MULTILINE).replace (/\n/g, "<br>") : qsTr ("<i>deleted message</i>"));
                    color: Theme.secondaryHighlightColor;
                    elide: Text.ElideRight;
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                    textFormat: Text.StyledText;
                    maximumLineCount: 3;
                    font.pixelSize: Theme.fontSizeSmall;
                    anchors.verticalCenter: parent.verticalCenter;
                    Container.horizontalStretch: 1;
                }
                RectangleButton {
                    icon: "icon-m-clear";
                    anchors.verticalCenter: parent.verticalCenter;
                    onClicked: {
                        TD_Global.editFormattedText (null);
                        TD_Global.editingMessageId = "";
                    }
                }
            }
        }
        Item {
            Container.forcedHeight: footerChat.height;
            ExtraAnchors.horizontalFill: parent;
        }
    }
}
