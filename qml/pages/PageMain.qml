import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
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
                                Label {
                                    text: modelData ["name"];
                                    anchors.verticalCenter: parent.verticalCenter;
                                    Container.horizontalStretch: 1;
                                }
                                Label {
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
    Component {
        id: compoPageChat;

        PageChat { }
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

            Label {
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
                    Label {
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
                Label {
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

            Label {
                text: qsTr ("Enter the verification code you received :");
                color: Theme.highlightColor;
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                font.family: Theme.fontFamilyHeading;
                ExtraAnchors.horizontalFill: parent;
            }
            Label {
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
                Label {
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

        PageHeader {
            id: headerConversations;
            title: qsTr ("Conversations");
            ExtraAnchors.topDock: parent;

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
                anchors {
                    left: parent.left;
                    margins: Theme.paddingLarge;
                    verticalCenter: parent.verticalCenter;
                }
            }
        }
        SilicaListView {
            clip: true;
            quickScroll: true;
            model: TD_Global.sortedChatsList;
            delegate: ListItem {
                id: delegateChat;
                implicitHeight: Theme.itemSizeMedium;
                ExtraAnchors.horizontalFill: parent;
                onClicked: {
                    pageStack.push (compoPageChat, { "currentChat" : chatItem });
                }

                readonly property TD_Chat chatItem : modelData;

                RowContainer {
                    spacing: Theme.paddingMedium;
                    anchors {
                        margins: Theme.paddingMedium;
                        verticalCenter: parent.verticalCenter;
                    }
                    ExtraAnchors.horizontalFill: parent;

                    DelegateDownloadableImage {
                        size: Theme.iconSizeMedium;
                        fileItem: (delegateChat.chatItem && delegateChat.chatItem.photo ? delegateChat.chatItem.photo.big : null);
                        autoDownload: true;
                        anchors.verticalCenter: parent.verticalCenter;
                    }
                    Label {
                        text: delegateChat.chatItem.title;
                        elide: Text.ElideRight;
                        anchors.verticalCenter: parent.verticalCenter;
                        Container.horizontalStretch: 1;
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
                    Label {
                        text: delegateChat.chatItem.unreadCount;
                        color: (delegateChat.chatItem && delegateChat.chatItem.notificationSettings && delegateChat.chatItem.notificationSettings.muteFor > 0
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
            anchors.top: headerConversations.bottom;
            ExtraAnchors.bottomDock: parent;

            VerticalScrollDecorator { flickable: parent; }
        }
    }
}
