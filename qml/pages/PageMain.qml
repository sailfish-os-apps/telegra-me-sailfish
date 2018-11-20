import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import Nemo.Notifications 1.0;
import harbour.Telegrame 1.0;
import "../InternationalPhoneCodes.js" as InternationalPhoneCodes;
import "../components";

Page {
    id: page;
    allowedOrientations: Orientation.All;

    property string currentCode : "";
    property string currentName : "";
    property string currentFlag : "";

    readonly property var countriesModel : {
        var ret = ([]);
        for (var i = 0; i < InternationalPhoneCodes.allCountries.length; ++i) {
            var tmp  = InternationalPhoneCodes.allCountries [i];
            ret.push ({
                          "name" : tmp [0].replace (/\s+\(.+\)/, ""),
                          "iso2" : tmp [1],
                          "code" : tmp [2],
                          "flag" : "qrc:///RegionFlags/png/%1.png".arg (tmp [1].toUpperCase ()),
                      });
        }
        return ret;
    }

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

    Component {
        id: compoDialogCountries;

        Dialog {
            id: dlgCountries;
            onDone: {
                if (result == DialogResult.Accepted) {
                    //
                }
            }

            property string code  : "";
            property string flag  : "";
            property string name  : "";

            DialogHeader {
                id: headerDialCode;
                title: qsTr ("Select country/region");
                ExtraAnchors.topDock: parent;
            }
            TextField {
                id: inputFilter;
                placeholderText: qsTr ("Filter...");
                anchors {
                    top: headerDialCode.bottom;
                    margins: Theme.paddingSmall;
                }
                ExtraAnchors.horizontalFill: parent;

                readonly property string value : (text.trim ().toLowerCase ());
            }
            SilicaFlickable {
                clip: true;
                quickScroll: true;
                contentWidth: width;
                contentHeight: layoutCountries.height;
                anchors.top: inputFilter.bottom;
                ExtraAnchors.bottomDock: parent;

                ColumnContainer {
                    id: layoutCountries;
                    ExtraAnchors.topDock: parent;

                    Repeater {
                        model: countriesModel;
                        delegate: ListItem {
                            visible: (modelData ["name"].toLowerCase ().indexOf (inputFilter.value) >= 0 || modelData ["code"].indexOf (inputFilter.value) >= 0);
                            highlighted: (dlgCountries.code === modelData ["code"]);
                            implicitHeight: (layoutItem.height + layoutItem.anchors.margins * 2);
                            ExtraAnchors.horizontalFill: parent;
                            onClicked: {
                                dlgCountries.code = modelData ["code"];
                                dlgCountries.name = modelData ["name"];
                                dlgCountries.flag = modelData ["flag"];
                            }

                            RowContainer {
                                id: layoutItem;
                                spacing: Theme.paddingMedium;
                                anchors {
                                    margins: Theme.paddingMedium;
                                    verticalCenter: parent.verticalCenter;
                                }
                                ExtraAnchors.horizontalFill: parent;

                                Item {
                                    implicitWidth: Theme.iconSizeMedium;
                                    implicitHeight: Theme.iconSizeMedium;
                                    anchors.verticalCenter: parent.verticalCenter;

                                    Image {
                                        cache: true;
                                        source: modelData ["flag"];
                                        fillMode: Image.PreserveAspectFit;
                                        sourceSize: Qt.size (width, height);
                                        asynchronous: false;
                                        verticalAlignment: Image.AlignVCenter;
                                        horizontalAlignment: Image.AlignHCenter;
                                        anchors.fill: parent;
                                    }
                                }
                                LabelFixed {
                                    text: modelData ["name"];
                                    anchors.verticalCenter: parent.verticalCenter;
                                    Container.horizontalStretch: 1;
                                }
                                LabelFixed {
                                    text: ("+" + modelData ["code"]);
                                    opacity: 0.65;
                                    anchors.verticalCenter: parent.verticalCenter;
                                }
                            }
                        }
                    }
                }
                VerticalScrollDecorator { flickable: parent; }
            }
        }
    }
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
                text: qsTr ("Choose a country and enter phone number :");
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
                    dialog.accepted.connect (function () {
                        currentCode = dialog ["code"];
                        currentName = dialog ["name"];
                        currentFlag = dialog ["flag"];
                    });
                }

                Rectangle {
                    color: (parent.pressed ? Theme.highlightColor : Theme.primaryColor);
                    radius: Theme.paddingSmall;
                    opacity: 0.15;
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
                    color: (parent.pressed ? Theme.highlightColor : Theme.primaryColor);
                    radius: Theme.paddingSmall;
                    opacity: 0.15;
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
                    color: (parent.pressed ? Theme.highlightColor : Theme.primaryColor);
                    radius: Theme.paddingSmall;
                    opacity: 0.15;
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
                        visible: (inputFilter.value === "" || chatItem.title.toLowerCase ().indexOf (inputFilter.value) >= 0);
                        contentHeight: (Theme.iconSizeMedium + Theme.paddingMedium * 2);
                        implicitHeight: (Theme.iconSizeMedium + Theme.paddingMedium * 2);
                        menu: ContextMenu {
                            MenuItem {
                                text: (delegateChat.chatItem.isPinned ? qsTr ("Un-pin from favorites") : qsTr ("Pin to favorites"));
                                enabled: false;
                                onClicked: {
                                    // TODO
                                }
                            }
                            MenuItem {
                                text: (delegateChat.chatItem.notificationSettings.muteFor > 0 ? qsTr ("Un-mute notifications") : qsTr ("Mute notifications"));
                                enabled: false;
                                onClicked: {
                                    // TODO
                                }
                            }
                            MenuItem {
                                text: qsTr ("Remove chat history");
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
                                            });
                        }
                        onUnreadCountChanged: {
                            updateNotif ();
                        }
                        onLastMsgItemChanged: {
                            updateNotif ();
                        }
                        onDescriptionChanged: {
                            updateNotif ();
                        }
                        Component.onCompleted: {
                            updateNotif ();
                        }
                        Component.onDestruction: {
                            notification.close ();
                        }

                        readonly property TD_Chat           chatItem           : modelData;
                        readonly property TD_ChatPhoto      chatPhotoItem      : (chatItem ? chatItem.photo : null);
                        readonly property TD_Message        lastMsgItem        : (chatItem ? chatItem.messagesModel.lastItem : null);
                        readonly property TD_User           lastMsgUserItem    : (lastMsgItem ? TD_Global.getUserItemById (lastMsgItem.senderUserId) : null);
                        readonly property TD_MessageContent lastMsgContentItem : (lastMsgItem ? lastMsgItem.content : null);
                        readonly property int               unreadCount        : (chatItem.notificationSettings.muteFor === 0 ? chatItem.unreadCount : 0);
                        readonly property string            description        : (lastMsgItem ? lastMsgItem.preview () : "");

                        function updateNotif () {
                            if (lastMsgItem) {
                                notification.body = description;
                                notification.timestamp = lastMsgItem.date;
                                notification.itemCount = unreadCount;
                                if (TD_Global.currentChat !== chatItem && !lastMsgItem.isOutgoing) {
                                    notification.previewSummary = notification.summary;
                                    notification.previewBody    = notification.body;
                                }
                                else {
                                    notification.previewSummary = "";
                                    notification.previewBody    = "";
                                }
                                if (unreadCount > 0) {
                                    notification.publish ();
                                }
                                else {
                                    notification.close ();
                                }
                            }
                        }

                        Notification {
                            id: notification;
                            icon: avatarChat.url;
                            appIcon: avatarChat.url;
                            appName: "Telegra'me";
                            summary: delegateChat.chatItem.title;
                            replacesId: delegateChat.chatItem.id;
                            maxContentLines: 3;
                            remoteActions: [
                                {
                                    "name" : "default",
                                    "displayName ": "Show chat",
                                    "icon" : avatarChat.url,
                                    "service" : "org.uniqueconception.telegrame",
                                    "path" : "/org/uniqueconception/telegrame",
                                    "iface" : "org.uniqueconception.telegrame",
                                    "method" : "showChat",
                                    "arguments" : [
                                        "argument",
                                        delegateChat.chatItem.id,
                                    ]
                                }
                            ]
                            onClicked: {
                                while (pageStack.currentPage !== page) {
                                    pageStack.navigateBack ();
                                }
                                pageStack.push (compoPageChat, {
                                                    "currentChat" : delegateChat.chatItem
                                                });
                                window.activate ();
                            }
                        }
                        RowContainer {
                            id: layoutChat;
                            spacing: Theme.paddingMedium;
                            anchors.margins: Theme.paddingMedium;
                            anchors.verticalCenter: parent.verticalCenter;
                            ExtraAnchors.horizontalFill: parent;

                            DelegateDownloadableImage {
                                id: avatarChat;
                                size: Theme.iconSizeMedium;
                                fileItem: (delegateChat.chatPhotoItem ? delegateChat.chatPhotoItem.big : null);
                                autoDownload: true;
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
                            Image {
                                source: "image://theme/icon-s-task?#808080";
                                visible: (delegateChat.chatItem && delegateChat.chatItem.isPinned);
                                sourceSize: Qt.size (Theme.iconSizeSmall, Theme.iconSizeSmall);
                                anchors.verticalCenter: parent.verticalCenter;
                            }
                            Image {
                                source: "image://theme/icon-m-speaker-mute?#808080";
                                visible: (delegateChat.chatItem && delegateChat.chatItem.notificationSettings && delegateChat.chatItem.notificationSettings.muteFor > 0);
                                sourceSize: Qt.size (Theme.iconSizeSmall, Theme.iconSizeSmall);
                                anchors.verticalCenter: parent.verticalCenter;
                            }
                            Item {
                                visible: (delegateChat.chatItem.unreadCount > 0);
                                Container.forcedWidth: Theme.paddingMedium;
                            }
                            LabelFixed {
                                text: delegateChat.chatItem.unreadCount;
                                color: ((delegateChat.chatItem && delegateChat.chatItem.notificationSettings && delegateChat.chatItem.notificationSettings.muteFor > 0)
                                        ? Theme.secondaryColor
                                        : Theme.highlightColor);
                                visible: (delegateChat.chatItem.unreadCount > 0);
                                anchors.verticalCenter: parent.verticalCenter;

                                Rectangle {
                                    z: -1;
                                    color: Theme.secondaryColor;
                                    radius: (height * 0.5);
                                    opacity: 0.35;
                                    implicitWidth: Math.max (parent.width + Theme.paddingMedium * 2, implicitHeight);
                                    implicitHeight: (parent.height + Theme.paddingSmall * 2);
                                    anchors.centerIn: parent;
                                }
                            }
                            Item {
                                visible: (delegateChat.chatItem.unreadCount > 0);
                                Container.forcedWidth: Theme.paddingMedium;
                            }
                        }
                    }
                }
            }
            VerticalScrollDecorator { flickable: parent; }
        }
        Item {
            id: headerConversations;
            implicitHeight: layoutHeader.height;
            ExtraAnchors.topDock: parent;

            Rectangle {
                color: Qt.rgba (1.0 - Theme.primaryColor.r, 1.0 - Theme.primaryColor.g, 1.0 - Theme.primaryColor.b, 0.85);
                anchors.fill: parent;
            }
            ColumnContainer {
                id: layoutHeader;
                ExtraAnchors.topDock: parent;

                RowContainer {
                    spacing: Theme.paddingMedium;
                    anchors.leftMargin: Theme.paddingMedium;
                    anchors.rightMargin: Theme.paddingLarge;
                    ExtraAnchors.horizontalFill: parent;

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
                        anchors.verticalCenter: parent.verticalCenter;
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
                        Container.horizontalStretch: 1;
                    }
                }
                SearchField {
                    id: inputFilter;
                    placeholderText: qsTr ("Filter...");
                    ExtraAnchors.horizontalFill: parent;

                    readonly property string value : text.trim ().toLowerCase ();
                }
            }
        }
    }
}
