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

    readonly property TD_User currentChatUserItem : (currentChat && currentChat.type.typeOf === TD_ObjectType.CHAT_TYPE_PRIVATE
                                                     ? TD_Global.getUserItemById (currentChat.type ["userId"])
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
    SilicaFlickable {
        id: flickerMessages;
        clip: true;
        quickScroll: false;
        anchors.fill: parent;
        anchors.bottomMargin: (footerChat.height + (stripReplyTo.visible ? stripReplyTo.height : 0));
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
            spaceBefore: headerChat.height;
            //spaceAfter: footerChat.height;
            delegate: ListItem {
                id: delegateMsg;
                contentHeight: layoutMessage.height;
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr ("Copy text");
                        visible: (formattedTextItem !== null);
                        onClicked: {
                            Clipboard.text = formattedTextItem.text;
                        }

                        readonly property TD_MessageText messageTextItem : (delegateMsg.messageItem &&
                                                                            delegateMsg.messageItem.content &&
                                                                            delegateMsg.messageItem.content.typeOf === TD_ObjectType.MESSAGE_TEXT
                                                                            ? delegateMsg.messageItem.content
                                                                            : null);

                        readonly property TD_FormattedText formattedTextItem : (messageTextItem ? messageTextItem.text : null);
                    }
                    MenuItem {
                        text: qsTr ("Open image in viewer");
                        visible: (photoSizeItem !== null);
                        enabled: (photoSizeItem && photoSizeItem.photo && photoSizeItem.photo.local && photoSizeItem.photo.local.isDownloadingCompleted);
                        onClicked: {
                            Qt.openUrlExternally (TD_Global.urlFromLocalPath (photoSizeItem.photo.local.path));
                        }

                        readonly property TD_MessagePhoto messagePhotoItem : (delegateMsg.messageItem &&
                                                                              delegateMsg.messageItem.content &&
                                                                              delegateMsg.messageItem.content.typeOf === TD_ObjectType.MESSAGE_PHOTO
                                                                              ? delegateMsg.messageItem.content
                                                                              : null);

                        readonly property TD_Photo photoItem : (messagePhotoItem ? messagePhotoItem.photo : null);

                        readonly property TD_PhotoSize photoSizeItem : {
                            var ret = null;
                            if (photoItem && photoItem.sizes.count > 0) {
                                var tmp = photoItem.sizes.get ("x");
                                ret = (tmp ? tmp : photoItem.sizes.getLast ());
                            }
                            return ret;
                        }
                    }
                    MenuItem {
                        text: qsTr ("Open video with player");
                        visible: (videoItem !== null);
                        enabled: (videoItem && videoItem.video && videoItem.video.local && videoItem.video.local.isDownloadingCompleted);
                        onClicked: {
                            Qt.openUrlExternally (TD_Global.urlFromLocalPath (videoItem.video.local.path));
                        }

                        readonly property TD_MessageVideo messageVideoItem : (delegateMsg.messageItem &&
                                                                              delegateMsg.messageItem.content &&
                                                                              delegateMsg.messageItem.content.typeOf === TD_ObjectType.MESSAGE_VIDEO
                                                                              ? delegateMsg.messageItem.content
                                                                              : null);

                        readonly property TD_Video videoItem : (messageVideoItem ? messageVideoItem.video : null);
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
                        text: qsTr ("Edit [TODO]");
                        visible: delegateMsg.messageItem.canBeEdited;
                        enabled: false;
                        onClicked: {
                            // TODO
                        }
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
                onMenuOpenChanged: {
                    if (menuOpen) {
                        centerOnMsg (messageItem.id);
                    }
                }

                readonly property TD_Message messageItem : modelItem;
                readonly property TD_User    userItem    : (messageItem ? TD_Global.getUserItemById (messageItem.senderUserId) : null);

                function showRemorseItem (forAll) {
                    remorse.execute (delegateMsg, qsTr ("Deleting"), function () {
                        TD_Global.removeMessage (currentChat, messageItem, forAll);
                    });
                }

                RemorseItem { id: remorse; }
                Rectangle {
                    color: Theme.secondaryHighlightColor;
                    opacity: 0.10;
                    visible: (delegateMsg.messageItem.id === currentMessageId);
                    anchors.fill: parent;
                }
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

                    LabelFixed {
                        id: lblNewMessages;
                        text: qsTr ("New messages");
                        color: Theme.highlightColor;
                        visible: (delegateMsg.messageItem && currentChat && currentChat.firstUnreadMessageItem && currentChat.firstUnreadMessageItem.id === delegateMsg.messageItem.id);
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
                            color: Theme.highlightColor;
                            implicitHeight: 1;
                            ExtraAnchors.topDock: parent;
                        }
                    }
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
                                LabelFixed {
                                    text: qsTr ("<b>Reply</b>: %1").arg (originalMessageItem ? originalMessageItem.preview (true).replace (/\n/g, "<br>") : qsTr ("<i>deleted message</i>"));
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
                                        text: ((delegateMsg.messageItem.editDate.getFullYear () > 2000)
                                               ? (qsTr ("edited") + " " + Qt.formatDateTime (delegateMsg.messageItem.editDate))
                                               : Qt.formatDateTime (delegateMsg.messageItem.date));
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
                }
            }
        }
        PullDownMenu {
            id: pulleyTop;
            visible: enabled;
            enabled: (currentChat && !currentChat.hasReachedFirst);

            MenuItem {
                text: qsTr ("Load older messages...");
                onDelayedClick: {
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
                onDelayedClick: {
                    centerOnMsg (currentChat.messagesModel.lastItem.id);
                    TD_Global.loadNewerMessages (currentChat);
                }
            }
            MenuItem {
                text: qsTr ("Mark all read in chat");
                onDelayedClick: {
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
            topMargin: (viewMessages.spaceBefore + flickerMessages.anchors.topMargin + headerChat.anchors.topMargin);
            bottomMargin: (viewMessages.spaceAfter + flickerMessages.anchors.bottomMargin);
        }
        ExtraAnchors.rightDock: parent;

        Behavior on opacity { NumberAnimation { duration: 650; } }
        Rectangle {
            color: Theme.highlightColor;
            opacity: 0.15;
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
    Item {
        id: stripReplyTo;
        visible: (replyingToMessageItem !== null);
        implicitHeight: (layoutReplyTo.height + layoutReplyTo.anchors.margins * 2);
        anchors.bottomMargin: footerChat.height;
        ExtraAnchors.bottomDock: parent;

        Rectangle {
            color: Qt.rgba (1.0 - Theme.primaryColor.r, 1.0 - Theme.primaryColor.g, 1.0 - Theme.primaryColor.b, 0.85);
            anchors.fill: parent;

            Rectangle {
                color: Theme.secondaryHighlightColor;
                opacity: 0.15;
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
                text: qsTr ("<b>Reply</b>: %1").arg (replyingToMessageItem ? replyingToMessageItem.preview (true).replace (/\n/g, "<br>") : qsTr ("<i>deleted message</i>"));
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
    MouseArea {
        id: headerChat;
        opacity: (pulleyTop.active ? 0.65 : 1.0);
        implicitHeight: (layoutHeader.height + layoutHeader.anchors.margins * 2);
        anchors.topMargin: Math.max (-flickerMessages.contentY, 0);
        ExtraAnchors.topDock: parent;
        onPressed: { }
        onReleased: { }

        Behavior on opacity { NumberAnimation { duration: 150; } }
        Rectangle {
            color: Qt.rgba (1.0 - Theme.primaryColor.r, 1.0 - Theme.primaryColor.g, 1.0 - Theme.primaryColor.b, 0.85);
            anchors.fill: parent;

            Rectangle {
                color: Theme.secondaryHighlightColor;
                opacity: 0.65;
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
                                    case TD_ObjectType.USER_STATUS_OFFLINE:    return qsTr ("Offline since %1").arg (Qt.formatDateTime (currentChatUserItem.status.wasOnline));
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
                        anchors {
                            right: parent.left;
                            margins: Theme.paddingMedium;
                            verticalCenter: parent.verticalCenter;
                        }
                    }
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
