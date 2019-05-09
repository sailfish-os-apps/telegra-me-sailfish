import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import Nemo.Notifications 1.0;
import harbour.Telegrame 1.0;
import QtGraphicalEffects 1.0;
import "../components";

Page {
    id: page;
    allowedOrientations: Orientation.All;

    property string currentCode : "";
    property string currentName : "";
    property string currentFlag : "";

    readonly property TD_AuthorizationStateWaitCode authWaitCode : (TD_Global.authorizationState &&
                                                                    TD_Global.authorizationState.typeOf === TD_ObjectType.AUTHORIZATION_STATE_WAIT_CODE
                                                                    ? TD_Global.authorizationState
                                                                    : null);

    readonly property TD_AuthenticationCodeInfo authCodeInfo : (authWaitCode ? authWaitCode.codeInfo : null);
    readonly property TD_AuthenticationCodeType authCodeType : (authCodeInfo ? authCodeInfo.type     : null);

    readonly property int authCodeSize : (authCodeType &&
                                          (authCodeType.typeOf === TD_ObjectType.AUTHENTICATION_CODE_TYPE_SMS ||
                                           authCodeType.typeOf === TD_ObjectType.AUTHENTICATION_CODE_TYPE_TELEGRAM_MESSAGE ||
                                           authCodeType.typeOf === TD_ObjectType.AUTHENTICATION_CODE_TYPE_CALL)
                                          ? authCodeType.length
                                          : -1)

    Item {
        id: tabRegisterPhoneNumber;
        enabled: (TD_Global.authorizationState && TD_Global.authorizationState.typeOf === TD_ObjectType.AUTHORIZATION_STATE_WAIT_PHONE_NUMBER);
        opacity: (enabled ? 1.0 : 0.0);
        anchors.fill: parent;

        PageHeader {
            id: headerPhoneNumber;
            title: qsTr ("Register phone number");
            ExtraAnchors.topDock: parent;
        }
        ColumnContainer {
            spacing: Theme.paddingLarge;
            anchors {
                top: headerPhoneNumber.bottom;
                margins: Theme.paddingLarge;
            }
            ExtraAnchors.horizontalFill: parent;

            LabelFixed {
                text: qsTr ("Choose a country and enter your phone number:");
                color: Theme.highlightColor;
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                font.family: Theme.fontFamilyHeading;
                ExtraAnchors.horizontalFill: parent;
            }
            MouseArea {
                id: btnChoose;
                implicitHeight: (layoutBtn.height + layoutBtn.anchors.margins * 2);
                anchors.margins: Theme.paddingMedium;
                ExtraAnchors.horizontalFill: parent;
                onClicked: {
                    var dialog = pageStack.push (compoDialogCountries);
                }

                Rectangle {
                    color: Theme.rgba ((parent.pressed ? Theme.highlightColor : Theme.primaryColor), 0.15);
                    radius: Theme.paddingSmall;
                    anchors.fill: parent;
                }
                RowContainer {
                    id: layoutBtn;
                    spacing: Theme.paddingMedium;
                    anchors {
                        margins: Theme.paddingMedium;
                        verticalCenter: parent.verticalCenter;
                    }
                    ExtraAnchors.horizontalFill: parent;

                    Image {
                        cache: true;
                        source: currentFlag;
                        fillMode: Image.PreserveAspectFit;
                        sourceSize: Qt.size (Theme.iconSizeMedium, Theme.iconSizeMedium);
                        asynchronous: false;
                        verticalAlignment: Image.AlignVCenter;
                        horizontalAlignment: Image.AlignHCenter;
                        anchors.verticalCenter: parent.verticalCenter;
                    }
                    LabelFixed {
                        text: (currentName !== "" ? currentName : qsTr ("Select a country/region..."));
                        anchors.verticalCenter: parent.verticalCenter;
                    }
                }
            }
            RowContainer {
                ExtraAnchors.horizontalFill: parent;

                TextField {
                    id: inputDialCode;
                    text: (currentCode !== "" ? ("+" + currentCode) : "+   ");
                    enabled: false;
                    anchors.verticalCenter: parent.verticalCenter;
                }
                TextField {
                    id: inputPhoneNumber;
                    placeholderText: qsTr ("Phone number");
                    anchors.verticalCenter: parent.verticalCenter;
                    Container.horizontalStretch: 1;
                    inputMethodHints: Qt.ImhDialableCharactersOnly;
                }
            }
            MouseArea {
                id: btnTryAuth;
                opacity: (enabled ? 1.0 : 0.35);
                enabled: (currentCode !== "" && inputPhoneNumber.text !== "");
                implicitWidth: (lblConnect.width + lblConnect.anchors.margins * 2);
                implicitHeight: (lblConnect.height + lblConnect.anchors.margins * 2);
                anchors.horizontalCenter: parent.horizontalCenter;
                onClicked: {
                    TD_Global.send ({
                                        "@type" : "setAuthenticationPhoneNumber",
                                        "phone_number" : "+%1%2".arg (currentCode).arg (inputPhoneNumber.text.trim ()),
                                        "allow_flash_call" : false,
                                        "is_current_phone_number" : true,
                                    });
                }

                Rectangle {
                    color: Theme.rgba ((parent.pressed ? Theme.highlightColor : Theme.primaryColor), 0.15);
                    radius: Theme.paddingSmall;
                    anchors.fill: parent;
                }
                LabelFixed {
                    id: lblConnect;
                    text: qsTr ("Connect");
                    anchors {
                        centerIn: parent;
                        margins: Theme.paddingLarge;
                    }
                }
            }
        }
    }
    Item {
        id: tabVerifySecurityCode;
        enabled: (TD_Global.authorizationState && TD_Global.authorizationState.typeOf === TD_ObjectType.AUTHORIZATION_STATE_WAIT_CODE);
        opacity: (enabled ? 1.0 : 0.0);
        anchors.fill: parent;

        PageHeader {
            id: headerVerifyCode;
            title: qsTr ("Verify security code");
            ExtraAnchors.topDock: parent;
        }
        ColumnContainer {
            spacing: Theme.paddingLarge;
            anchors {
                top: headerVerifyCode.bottom;
                margins: Theme.paddingLarge;
            }
            ExtraAnchors.horizontalFill: parent;

            LabelFixed {
                text: qsTr ("Enter the verification code you received :");
                color: Theme.highlightColor;
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                font.family: Theme.fontFamilyHeading;
                ExtraAnchors.horizontalFill: parent;
            }
            LabelFixed {
                text: {
                    if (authWaitCode) {
                        switch (authWaitCode.typeOf) {
                        case TD_AuthenticationCodeType.SMS:              return qsTr ("(sent by SMS on %1)").arg (inputDialCode.text.trim () + inputPhoneNumber.text.trim ());
                        case TD_AuthenticationCodeType.TELEGRAM_MESSAGE: return qsTr ("(sent on your previous Telegram sessions)");
                        default:                                         return "";
                        }
                    }
                    return "";
                }
                horizontalAlignment: Text.AlignHCenter;
            }
            TextField {
                id: inputCode;
                placeholderText: (new Array (authCodeSize +1).join ("X"));
                inputMethodHints: Qt.ImhDigitsOnly;
                ExtraAnchors.horizontalFill: parent;
            }
            TextField {
                id: inputUserFirstName;
                visible: (authWaitCode && !authWaitCode.isRegistered);
                placeholderText: qsTr ("Firstname");
                ExtraAnchors.horizontalFill: parent;
            }
            TextField {
                id: inputUserLastName;
                visible: (authWaitCode && !authWaitCode.isRegistered);
                placeholderText: qsTr ("Lastname");
                ExtraAnchors.horizontalFill: parent;
            }
            MouseArea {
                id: btnCheckCode;
                opacity: (enabled ? 1.0 : 0.35);
                enabled: (inputCode.text !== "");
                implicitWidth: (lblCheckCode.width + lblCheckCode.anchors.margins * 2);
                implicitHeight: (lblCheckCode.height + lblCheckCode.anchors.margins * 2);
                anchors.horizontalCenter: parent.horizontalCenter;
                onClicked: {
                    TD_Global.send ({
                                        "@type" : "checkAuthenticationCode",
                                        "code" : inputCode.text.trim (),
                                        "first_name" : inputUserFirstName.text.trim (),
                                        "last_name" : inputUserLastName.text.trim (),
                                    });
                }

                Rectangle {
                    color: Theme.rgba ((parent.pressed ? Theme.highlightColor : Theme.primaryColor), 0.15);
                    radius: Theme.paddingSmall;
                    anchors.fill: parent;
                }
                LabelFixed {
                    id: lblCheckCode;
                    text: qsTr ("Check code");
                    anchors {
                        centerIn: parent;
                        margins: Theme.paddingLarge;
                    }
                }
            }
        }
    }
    Item {
        id: tabPassword;
        enabled: (TD_Global.authorizationState && TD_Global.authorizationState.typeOf === TD_ObjectType.AUTHORIZATION_STATE_WAIT_PASSWORD);
        opacity: (enabled ? 1.0 : 0.0);
        anchors.fill: parent;

        PageHeader {
            id: headerPassword;
            title: qsTr ("2FA");
            ExtraAnchors.topDock: parent;
        }
        ColumnContainer {
            spacing: Theme.paddingLarge;
            anchors {
                top: headerPassword.bottom;
                margins: Theme.paddingLarge;
            }
            ExtraAnchors.horizontalFill: parent;

            LabelFixed {
                text: qsTr ("Enter your password :");
                color: Theme.highlightColor;
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                font.family: Theme.fontFamilyHeading;
                ExtraAnchors.horizontalFill: parent;
            }
            TextField {
                id: inputPassword2FA;
                echoMode: TextInput.Password;
                placeholderText: qsTr ("Password");
                ExtraAnchors.horizontalFill: parent;
            }
            MouseArea {
                id: btnPassword;
                opacity: (enabled ? 1.0 : 0.35);
                enabled: (inputPassword2FA.text !== "");
                implicitWidth: (lblPassword.width + lblPassword.anchors.margins * 2);
                implicitHeight: (lblPassword.height + lblPassword.anchors.margins * 2);
                anchors.horizontalCenter: parent.horizontalCenter;
                onClicked: {
                    TD_Global.send ({
                                        "@type" : "checkAuthenticationPassword",
                                        "password" : inputPassword2FA.text.trim (),
                                    });
                }

                Rectangle {
                    color: Theme.rgba ((parent.pressed ? Theme.highlightColor : Theme.primaryColor), 0.15);
                    radius: Theme.paddingSmall;
                    anchors.fill: parent;
                }
                LabelFixed {
                    id: lblPassword;
                    text: qsTr ("Unlock");
                    anchors {
                        centerIn: parent;
                        margins: Theme.paddingLarge;
                    }
                }
            }
        }
    }
    Item {
        id: tabConverstations;
        enabled: (TD_Global.authorizationState && TD_Global.authorizationState.typeOf === TD_ObjectType.AUTHORIZATION_STATE_READY);
        opacity: (enabled ? 1.0 : 0.0);
        anchors.fill: parent;

        SilicaFlickable {
            id: flickerChats;
            quickScroll: true;
            contentWidth: width;
            contentHeight: layoutChats.height;
            anchors.fill: parent;

            PullDownMenu {
                id: pulley;

                MenuItem {
                    text: qsTr ("About");
                    onClicked: {
                        pageStack.push (compoPageAbout);
                    }
                }
                MenuItem {
                    text: qsTr ("Settings");
                    onClicked: {
                        pageStack.push (compoPageSettings);
                    }
                }
                MenuItem {
                    text: qsTr ("New group chat [TODO]");
                    enabled: false;
                    onClicked: {
                        // TODO
                    }
                }
                MenuItem {
                    text: qsTr ("Contacts list");
                    onClicked: {
                        pageStack.push (compoPageContacts);
                    }
                }
                MenuItem {
                    text: (layoutSearch.visible ? qsTr ("Hide search bar") : qsTr ("Show search bar"));
                    onClicked: {
                        if (layoutSearch.visible) {
                            inputFilter.focus = false;
                            layoutSearch.visible = false;
                        }
                        else {
                            layoutSearch.visible = true;
                            inputFilter.forceActiveFocus ();
                        }
                    }
                }
            }
            Column {
                id: layoutChats;
                ExtraAnchors.topDock: parent;

                Item {
                    implicitHeight: headerConversations.height;
                    ExtraAnchors.horizontalFill: parent;
                    Container.forcedHeight: headerConversations.height;
                }
                Repeater {
                    model: TD_Global.sortedChatsList;
                    delegate: ListItem {
                        id: delegateChat;
                        visible: ((chatItem.order > 0) && (inputFilter.value === "" || chatItem.title.toLowerCase ().indexOf (inputFilter.value) >= 0));
                        contentHeight: (Theme.iconSizeMedium + Theme.paddingMedium * 2);
                        implicitHeight: (Theme.iconSizeMedium + Theme.paddingMedium * 2);
                        menu: ContextMenu {
                            MenuItem {
                                text: (delegateChat.chatItem.isPinned ? qsTr ("Un-pin from favorites") : qsTr ("Pin to favorites"));
                                onClicked: {
                                    TD_Global.togglePinChat (delegateChat.chatItem);
                                }
                            }
                            MenuItem {
                                text: (delegateChat.chatItem && delegateChat.chatItem.notificationSettings && delegateChat.chatItem.notificationSettings.muteFor > 0 ? qsTr ("Un-mute notifications [TODO]") : qsTr ("Mute notifications [TODO]"));
                                enabled: false;
                                onClicked: {
                                    // TODO
                                }
                            }
                            MenuItem {
                                text: qsTr ("Remove chat history [TODO]");
                                enabled: false;
                                onClicked: {
                                    // TODO
                                }
                            }
                        }
                        ExtraAnchors.horizontalFill: parent;
                        onClicked: {
                            pageStack.push (compoPageChat, {
                                                "currentChat" : chatItem,
                                            },
                                            PageStackAction.Animated);
                        }

                        readonly property TD_Chat      chatItem      : modelData;
                        readonly property TD_ChatPhoto chatPhotoItem : (chatItem ? chatItem.photo : null);
                        readonly property TD_Message   lastMsgItem   : (chatItem ? chatItem.getMessageItemById (chatItem.lastReceivedMessageId) : null);
                        readonly property string       description   : (lastMsgItem ? lastMsgItem.preview (TD_Message.SHOW_TITLE) : "");

                        Connections {
                            target: delegateChat.chatItem;
                            onDisplayRequested: {
                                TD_Global.showChat (delegateChat.chatItem);
                            }
                        }
                        RowContainer {
                            id: layoutChat;
                            spacing: Theme.paddingMedium;
                            anchors.margins: Theme.paddingMedium;
                            anchors.verticalCenter: parent.verticalCenter;
                            ExtraAnchors.horizontalFill: parent;

                            DelegateAvatar {
                                id: avatarChat;
                                size: Theme.iconSizeMedium;
                                fileItem: (delegateChat.chatPhotoItem
                                           ? delegateChat.chatPhotoItem.big
                                           : null);
                                anchors.verticalCenter: parent.verticalCenter;
                            }
                            ColumnContainer {
                                anchors.verticalCenter: parent.verticalCenter;
                                Container.horizontalStretch: 1;

                                LabelFixed {
                                    text: delegateChat.chatItem.title;
                                    elide: Text.ElideRight;
                                    ExtraAnchors.horizontalFill: parent;
                                }
                                RowContainer {
                                    spacing: Theme.paddingSmall;
                                    ExtraAnchors.horizontalFill: parent;

                                    LabelFixed {
                                        text: delegateChat.description;
                                        color: Theme.secondaryColor;
                                        elide: Text.ElideRight;
                                        maximumLineCount: 1;
                                        font.pixelSize: Theme.fontSizeExtraSmall;
                                        anchors.verticalCenter: parent.verticalCenter;
                                        Container.horizontalStretch: 1;
                                    }
                                    Image {
                                        source: "image://theme/icon-m-acknowledge?%1".arg (Theme.highlightColor);
                                        visible: (delegateChat.lastMsgItem &&
                                                  delegateChat.lastMsgItem.isOutgoing &&
                                                  delegateChat.lastMsgItem.id <= delegateChat.chatItem.lastReadOutboxMessageId);
                                        sourceSize: Qt.size (Theme.iconSizeSmall, Theme.iconSizeSmall);
                                        anchors.verticalCenter: parent.verticalCenter;
                                    }
                                }
                            }
                            Rectangle {
                                color: Theme.rgba (Theme.secondaryColor, 0.35);
                                radius: (Theme.iconSizeMedium * 0.5);
                                visible: (delegateChat.chatItem.unreadMentionCount > 0);
                                implicitWidth: Theme.iconSizeMedium;
                                implicitHeight: Theme.iconSizeMedium;
                                anchors.verticalCenter: parent.verticalCenter;

                                LabelFixed {
                                    text: "@";
                                    color: ((delegateChat.chatItem &&
                                             delegateChat.chatItem.notificationSettings &&
                                             delegateChat.chatItem.notificationSettings.muteFor > 0)
                                            ? Theme.secondaryColor
                                            : Theme.highlightColor);
                                    anchors.centerIn: parent;
                                }
                            }
                            Rectangle {
                                color: "transparent";
                                radius: (height * 0.5);
                                visible: (delegateChat.chatItem.unreadCount > 0);
                                border {
                                    width: 1;
                                    color: Theme.rgba (lblChatCount.color, 0.65);
                                }
                                implicitWidth: Math.max (lblChatCount.implicitWidth + lblChatCount.anchors.margins * 2, implicitHeight);
                                implicitHeight: (lblChatCount.implicitHeight + lblChatCount.anchors.margins * 2);
                                anchors.verticalCenter: parent.verticalCenter;

                                LabelFixed {
                                    id: lblChatCount;
                                    text: delegateChat.chatItem.unreadCount;
                                    color: ((delegateChat.chatItem &&
                                             delegateChat.chatItem.notificationSettings &&
                                             delegateChat.chatItem.notificationSettings.muteFor > 0)
                                            ? Theme.secondaryColor
                                            : Theme.highlightColor);
                                    font.bold: true;
                                    font.pixelSize: Theme.fontSizeSmall;
                                    anchors.margins: Theme.paddingSmall;
                                    anchors.centerIn: parent;
                                }
                            }
                            Image {
                                source: "image://theme/icon-s-task?%1".arg (Theme.secondaryColor);
                                visible: (delegateChat.chatItem && delegateChat.chatItem.isPinned);
                                sourceSize: Qt.size (Theme.iconSizeSmall, Theme.iconSizeSmall);
                                anchors.verticalCenter: parent.verticalCenter;
                            }
                            Image {
                                source: "image://theme/icon-m-speaker-mute?%1".arg (Theme.secondaryColor);
                                visible: (delegateChat.chatItem &&
                                          delegateChat.chatItem.notificationSettings &&
                                          delegateChat.chatItem.notificationSettings.muteFor > 0);
                                sourceSize: Qt.size (Theme.iconSizeSmall, Theme.iconSizeSmall);
                                anchors.verticalCenter: parent.verticalCenter;
                            }
                        }
                    }
                }
            }
            VerticalScrollDecorator { flickable: parent; }
        }
        MouseArea {
            id: headerConversations;
            opacity: (pulley.active ? 0.65 : 1.0);
            implicitHeight: (window.isPortrait
                             ? (layoutTitle.height + (layoutSearch.visible ? layoutSearch.height + Theme.paddingMedium : 0) + Theme.paddingMedium * 2)
                             : (Math.max (layoutTitle.height, (layoutSearch.visible ? layoutSearch.height : 0)) + Theme.paddingMedium * 2));
            anchors.topMargin: Math.max (-flickerChats.contentY, 0);
            ExtraAnchors.topDock: parent;
            onPressed: { }
            onReleased: { }

            Behavior on opacity { NumberAnimation { duration: 150; } }
            Rectangle {
                color: Helpers.panelColor;
                anchors.fill: parent;

                Rectangle {
                    color: Theme.rgba (Theme.secondaryHighlightColor, 0.65);
                    visible: flickerChats.atYBeginning;
                    implicitHeight: Theme.paddingSmall;
                    ExtraAnchors.topDock: parent;
                }
            }
            RowContainer {
                id: layoutTitle;
                spacing: Theme.paddingMedium;
                anchors.topMargin: Theme.paddingMedium;
                anchors.rightMargin: Theme.paddingLarge;
                ExtraAnchors.topRightCorner: parent;

                Item {
                    implicitWidth: Theme.iconSizeMedium;
                    implicitHeight: Theme.iconSizeMedium;
                    anchors.verticalCenter: parent.verticalCenter;

                    GlassItem {
                        color: {
                            switch (TD_Global.connectionState ? TD_Global.connectionState.typeOf : -1) {
                            case TD_ObjectType.CONNECTION_STATE_WAITING_FOR_NETWORK: return "red";
                            case TD_ObjectType.CONNECTION_STATE_CONNECTING:          return "orange";
                            case TD_ObjectType.CONNECTION_STATE_CONNECTING_TO_PROXY: return "orange";
                            case TD_ObjectType.CONNECTION_STATE_UPDATING:            return "orange";
                            case TD_ObjectType.CONNECTION_STATE_READY:               return "lime";
                            }
                            return "magenta";
                        }
                        anchors.centerIn: parent;
                    }
                }
                LabelFixed {
                    text: qsTr ("Conversations");
                    color: Theme.highlightColor;
                    horizontalAlignment: Text.AlignRight;
                    font {
                        family: Theme.fontFamilyHeading;
                        pixelSize: Theme.fontSizeLarge;
                    }
                    anchors.verticalCenter: parent.verticalCenter;
                }
            }
            RowContainer {
                id: layoutSearch;
                spacing: Theme.paddingSmall;
                visible: false;
                anchors {
                    top: (window.isPortrait ? layoutTitle.bottom : parent.top);
                    left: parent.left;
                    right: (window.isPortrait ? parent.right : layoutTitle.left);
                    topMargin: Theme.paddingMedium;
                    leftMargin: Theme.paddingLarge;
                    rightMargin: Theme.paddingLarge;
                }

                Image {
                    source: "image://theme/icon-m-search";
                    sourceSize: Qt.size (Theme.iconSizeMedium, Theme.iconSizeMedium);
                    anchors.verticalCenter: parent.verticalCenter;
                }
                TextField {
                    id: inputFilter;
                    labelVisible: false;
                    placeholderText: qsTr ("Filter...");
                    anchors.verticalCenter: parent.verticalCenter;
                    Container.horizontalStretch: 1;

                    readonly property string value : text.trim ().toLowerCase ();
                }
                IconButton {
                    id: clearButton;
                    opacity: (inputFilter.text.length > 0 ? 1.0 : 0.0);
                    implicitWidth: Theme.itemSizeSmall;
                    implicitHeight: Theme.itemSizeSmall;
                    icon.source: "image://theme/icon-m-clear";
                    icon.sourceSize: Qt.size (Theme.iconSizeMedium, Theme.iconSizeMedium);
                    anchors.verticalCenter: parent.verticalCenter;
                    onClicked: {
                        inputFilter.text = "";
                    }

                    Behavior on opacity { FadeAnimation { } }
                }
            }
        }
    }
    Component {
        id: compoDialogCountries;

        DialogCountrySelector {
            onAccepted: {
                currentCode = code;
                currentName = name;
                currentFlag = flag;
            }
        }
    }
}
