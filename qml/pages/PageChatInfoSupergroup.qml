import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;
import "../components";

Page {
    id: pageChatInfoSupergroup;
    allowedOrientations: Orientation.All;

    property TD_Chat       chatItem       : null;
    property TD_Supergroup supergroupItem : null;

    SilicaFlickable {
        contentWidth: width;
        contentHeight: (layoutSupergroupInfo.height + layoutSupergroupInfo.anchors.margins * 2);
        anchors.fill: parent;

        PullDownMenu {
            MenuItem {
                text: qsTr ("Leave group [TODO]");
                enabled: false;
                onClicked: {
                    // TODO
                }
            }
        }
        ColumnContainer {
            id: layoutSupergroupInfo;
            spacing: (Theme.paddingLarge * 2);
            anchors.margins: Theme.paddingLarge;
            ExtraAnchors.topDock: parent;

            LabelFixed {
                text: qsTr ("Supergroup chat details")
                color: Theme.highlightColor;
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                font.family: Theme.fontFamilyHeading;
                font.pixelSize: Theme.fontSizeExtraLarge;
                anchors.right: parent.right;
            }
            DelegateAvatar {
                size: (Theme.iconSizeExtraLarge * 1.65);
                fileItem: (pageChatInfoSupergroup.chatItem && pageChatInfoSupergroup.chatItem.photo ? pageChatInfoSupergroup.chatItem.photo.big : null);
                anchors.horizontalCenter: parent.horizontalCenter;
            }
            LabelFixed {
                text: (pageChatInfoSupergroup.chatItem ? pageChatInfoSupergroup.chatItem.title : "");
                color: Theme.primaryColor;
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                horizontalAlignment: Text.AlignHCenter;
                font.family: Theme.fontFamilyHeading;
                font.pixelSize: Theme.fontSizeLarge;
                ExtraAnchors.horizontalFill: parent;
            }
            LabelFixed {
                text: (pageChatInfoSupergroup.supergroupItem ? pageChatInfoSupergroup.supergroupItem.description : "");
                color: Theme.secondaryColor;
                visible: (text !== "");
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                font.family: Theme.fontFamilyHeading;
                font.pixelSize: Theme.fontSizeSmall;
                anchors.margins: Theme.paddingLarge;
                ExtraAnchors.horizontalFill: parent;

                Rectangle {
                    z: -1;
                    color: Theme.rgba (Theme.secondaryColor, 0.15);
                    anchors {
                        fill: parent;
                        margins: -Theme.paddingSmall;
                    }
                }
            }
            RowContainer {
                spacing: Theme.paddingLarge;
                visible: (pageChatInfoSupergroup.supergroupItem && pageChatInfoSupergroup.supergroupItem.username !== "");
                anchors.margins: Theme.paddingLarge;
                ExtraAnchors.horizontalFill: parent;

                RectangleButton {
                    icon: "icon-m-link";
                    size: Theme.iconSizeMedium;
                    anchors.verticalCenter: parent.verticalCenter;
                    onClicked: {
                        Clipboard.text = pageChatInfoSupergroup.supergroupItem.username;
                    }
                }
                LabelFixed {
                    text: (pageChatInfoSupergroup.supergroupItem ? "@" + pageChatInfoSupergroup.supergroupItem.username : "");
                    color: Theme.secondaryHighlightColor;
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                    font.underline: true;
                    font.pixelSize: Theme.fontSizeSmall;
                    anchors.verticalCenter: parent.verticalCenter;
                }
            }
            RowContainer {
                spacing: Theme.paddingLarge;
                visible: (pageChatInfoSupergroup.supergroupItem && pageChatInfoSupergroup.supergroupItem.inviteLink !== "");
                anchors.margins: Theme.paddingLarge;
                ExtraAnchors.horizontalFill: parent;

                RectangleButton {
                    icon: "icon-m-share";
                    size: Theme.iconSizeMedium;
                    anchors.verticalCenter: parent.verticalCenter;
                    onClicked: {
                        Clipboard.text = pageChatInfoSupergroup.supergroupItem.inviteLink;
                    }
                }
                LabelFixed {
                    text: (pageChatInfoSupergroup.supergroupItem ? pageChatInfoSupergroup.supergroupItem.inviteLink : "");
                    color: Theme.secondaryHighlightColor;
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                    font.underline: true;
                    font.pixelSize: Theme.fontSizeSmall;
                    anchors.verticalCenter: parent.verticalCenter;
                    Container.horizontalStretch: 1;
                }
            }
            Item {
                Container.forcedHeight: Theme.paddingSmall;
            }
            ColumnContainer {
                visible: (pageChatInfoSupergroup.supergroupItem && !pageChatInfoSupergroup.supergroupItem.isChannel);
                spacing: Theme.paddingMedium;
                anchors.margins: Theme.paddingLarge;
                ExtraAnchors.horizontalFill: parent;

                RowContainer {
                    spacing: Theme.paddingLarge;
                    ExtraAnchors.horizontalFill: parent;

                    Rectangle {
                        color: Theme.rgba (Theme.secondaryColor, 0.35);
                        implicitHeight: 1;
                        anchors.verticalCenter: parent.verticalCenter;
                        Container.horizontalStretch: 1;
                    }
                    LabelFixed {
                        text: qsTr ("%1 members").arg (pageChatInfoSupergroup.supergroupItem ? pageChatInfoSupergroup.supergroupItem.memberCount : 0);
                        color: Theme.secondaryColor;
                        font.pixelSize: Theme.fontSizeSmall;
                        anchors.verticalCenter: parent.verticalCenter;
                    }
                    Rectangle {
                        color: Theme.rgba (Theme.secondaryColor, 0.35);
                        implicitHeight: 1;
                        anchors.verticalCenter: parent.verticalCenter;
                        Container.horizontalStretch: 1;
                    }
                }
                Repeater {
                    model: (pageChatInfoSupergroup.supergroupItem ? pageChatInfoSupergroup.supergroupItem.members : 0);
                    delegate: RowContainer {
                        id: delegateSupergroupMember;
                        spacing: Theme.paddingMedium;
                        ExtraAnchors.horizontalFill: parent;

                        readonly property TD_ChatMember chatMemberItem : modelData;

                        readonly property TD_User memberUserItem : (chatMemberItem ? TD_Global.getUserItemById (chatMemberItem.userId) : null);

                        DelegateAvatar {
                            size: Theme.iconSizeMedium;
                            fileItem: (delegateSupergroupMember.memberUserItem && delegateSupergroupMember.memberUserItem.profilePhoto
                                       ? delegateSupergroupMember.memberUserItem.profilePhoto.big
                                       : null);
                            anchors.verticalCenter: parent.verticalCenter;

                            MouseArea {
                                anchors.fill: parent;
                                Container.ignored: true;
                                onClicked: {
                                    pageStack.push (compoPageUserInfo, {
                                                        "userItem" : delegateSupergroupMember.memberUserItem,
                                                    });
                                }
                            }
                        }
                        ColumnContainer {
                            Container.horizontalStretch: 1;

                            LabelFixed {
                                text: (delegateSupergroupMember.memberUserItem
                                       ? (delegateSupergroupMember.memberUserItem.firstName + " " + delegateSupergroupMember.memberUserItem.lastName)
                                       : "<undefined>");
                                color: Theme.highlightColor;
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                                font.underline: true;
                                font.pixelSize: Theme.fontSizeMedium;
                                ExtraAnchors.horizontalFill: parent;
                            }
                            LabelFixed {
                                text: {
                                    if (delegateSupergroupMember.memberUserItem && delegateSupergroupMember.memberUserItem.status) {
                                        switch (delegateSupergroupMember.memberUserItem.status.typeOf) {
                                        case TD_ObjectType.USER_STATUS_ONLINE:     return qsTr ("Online");
                                        case TD_ObjectType.USER_STATUS_OFFLINE:    return qsTr ("Offline since %1").arg (Qt.formatDateTime (delegateSupergroupMember.memberUserItem.status.wasOnline));
                                        case TD_ObjectType.USER_STATUS_LAST_MONTH: return qsTr ("Seen last month");
                                        case TD_ObjectType.USER_STATUS_LAST_WEEK:  return qsTr ("Seen last week");
                                        case TD_ObjectType.USER_STATUS_RECENTLY:   return qsTr ("Recently");
                                        case TD_ObjectType.USER_STATUS_EMPTY:      return qsTr ("");
                                        }
                                    }
                                    return "";
                                }
                                color: Theme.secondaryColor;
                                font {
                                    family: Theme.fontFamilyHeading;
                                    pixelSize: Theme.fontSizeExtraSmall;
                                }

                                Rectangle {
                                    color: "lime";
                                    radius: (Theme.paddingMedium * 0.5);
                                    visible: (delegateSupergroupMember.memberUserItem &&
                                              delegateSupergroupMember.memberUserItem.status &&
                                              delegateSupergroupMember.memberUserItem.status.typeOf === TD_ObjectType.USER_STATUS_ONLINE);
                                    antialiasing: true;
                                    implicitWidth: Theme.paddingMedium;
                                    implicitHeight: Theme.paddingMedium;
                                    anchors {
                                        left: parent.right;
                                        margins: Theme.paddingMedium;
                                        verticalCenter: parent.verticalCenter;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
