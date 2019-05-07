import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;
import "../components";

Page {
    id: pageChatInfoBasicGroup;
    allowedOrientations: Orientation.All;

    property TD_Chat       chatItem       : null;
    property TD_BasicGroup basicGroupItem : null;

    readonly property TD_User creatorUserItem : (basicGroupItem ? TD_Global.getUserItemById (basicGroupItem.creatorUserId) : null);

    SilicaFlickable {
        contentWidth: width;
        contentHeight: (layoutBasicGroupInfo.height + layoutBasicGroupInfo.anchors.margins * 2);
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
            id: layoutBasicGroupInfo;
            spacing: (Theme.paddingLarge * 2);
            anchors.margins: Theme.paddingLarge;
            ExtraAnchors.topDock: parent;

            LabelFixed {
                text: qsTr ("Group chat details")
                color: Theme.highlightColor;
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                font.family: Theme.fontFamilyHeading;
                font.pixelSize: Theme.fontSizeExtraLarge;
                anchors.right: parent.right;
            }
            DelegateAvatar {
                size: (Theme.iconSizeExtraLarge * 1.65);
                fileItem: (pageChatInfoBasicGroup.chatItem && pageChatInfoBasicGroup.chatItem.photo ? pageChatInfoBasicGroup.chatItem.photo.big : null);
                anchors.horizontalCenter: parent.horizontalCenter;
            }
            LabelFixed {
                text: (pageChatInfoBasicGroup.chatItem ? pageChatInfoBasicGroup.chatItem.title : "");
                color: Theme.primaryColor;
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                horizontalAlignment: Text.AlignHCenter;
                font.family: Theme.fontFamilyHeading;
                font.pixelSize: Theme.fontSizeLarge;
                ExtraAnchors.horizontalFill: parent;
            }
            RowContainer {
                spacing: Theme.paddingLarge;
                visible: pageChatInfoBasicGroup.creatorUserItem;
                anchors.horizontalCenter: parent.horizontalCenter;

                ColumnContainer {
                    anchors.verticalCenter: parent.verticalCenter;

                    LabelFixed {
                        text: qsTr ("Created by");
                        color: Theme.secondaryHighlightColor;
                        font.pixelSize: Theme.fontSizeExtraSmall;
                        anchors.right: parent.right;
                    }
                    LabelFixed {
                        text: (pageChatInfoBasicGroup.creatorUserItem
                               ? (pageChatInfoBasicGroup.creatorUserItem.firstName + " " + pageChatInfoBasicGroup.creatorUserItem.lastName)
                               : "<undefined>");
                        color: Theme.highlightColor;
                        font.underline: true;
                        font.pixelSize: Theme.fontSizeSmall;
                        anchors.right: parent.right;
                    }
                }
                DelegateAvatar {
                    size: Theme.iconSizeMedium;
                    fileItem: (pageChatInfoBasicGroup.creatorUserItem && pageChatInfoBasicGroup.creatorUserItem.profilePhoto
                               ? pageChatInfoBasicGroup.creatorUserItem.profilePhoto.big
                               : null);
                    anchors.verticalCenter: parent.verticalCenter;
                }
            }
            LabelFixed {
                text: qsTr ("This group chat is not active anymore");
                color: Theme.primaryColor;
                visible: (pageChatInfoBasicGroup.basicGroupItem && !pageChatInfoBasicGroup.basicGroupItem.isActive);
                horizontalAlignment: Text.AlignHCenter;
                font.italic: true;
                font.pixelSize: Theme.fontSizeSmall;
                ExtraAnchors.horizontalFill: parent;
            }
            RowContainer {
                spacing: Theme.paddingLarge;
                visible: (pageChatInfoBasicGroup.basicGroupItem && pageChatInfoBasicGroup.basicGroupItem.inviteLink !== "");
                anchors.margins: Theme.paddingLarge;
                ExtraAnchors.horizontalFill: parent;

                RectangleButton {
                    icon: "icon-m-share";
                    size: Theme.iconSizeMedium;
                    anchors.verticalCenter: parent.verticalCenter;
                    onClicked: {
                        Clipboard.text = pageChatInfoBasicGroup.basicGroupItem.inviteLink;
                    }
                }
                LabelFixed {
                    text: (pageChatInfoBasicGroup.basicGroupItem ? pageChatInfoBasicGroup.basicGroupItem.inviteLink : "");
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
                        text: qsTr ("%1 members").arg (pageChatInfoBasicGroup.basicGroupItem ? pageChatInfoBasicGroup.basicGroupItem.memberCount : 0);
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
                    model: (pageChatInfoBasicGroup.basicGroupItem ? pageChatInfoBasicGroup.basicGroupItem.members : 0);
                    delegate: RowContainer {
                        id: delegateBasicGroupMember;
                        spacing: Theme.paddingMedium;
                        ExtraAnchors.horizontalFill: parent;

                        readonly property TD_ChatMember chatMemberItem : modelData;

                        readonly property TD_User memberUserItem : (chatMemberItem ? TD_Global.getUserItemById (chatMemberItem.userId) : null);

                        MouseArea {
                            anchors.fill: parent;
                            Container.ignored: true;
                            onClicked: {
                                pageStack.push (compoPageUserInfo, {
                                                    "userItem" : delegateBasicGroupMember.memberUserItem,
                                                });
                            }
                        }
                        DelegateAvatar {
                            size: Theme.iconSizeMedium;
                            fileItem: (delegateBasicGroupMember.memberUserItem && delegateBasicGroupMember.memberUserItem.profilePhoto
                                       ? delegateBasicGroupMember.memberUserItem.profilePhoto.big
                                       : null);
                            anchors.verticalCenter: parent.verticalCenter;
                        }
                        ColumnContainer {
                            Container.horizontalStretch: 1;

                            LabelFixed {
                                text: (delegateBasicGroupMember.memberUserItem
                                       ? (delegateBasicGroupMember.memberUserItem.firstName + " " + delegateBasicGroupMember.memberUserItem.lastName)
                                       : "<undefined>");
                                color: Theme.highlightColor;
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                                font.underline: true;
                                font.pixelSize: Theme.fontSizeMedium;
                                ExtraAnchors.horizontalFill: parent;
                            }
                            LabelFixed {
                                text: {
                                    if (delegateBasicGroupMember.memberUserItem && delegateBasicGroupMember.memberUserItem.status) {
                                        switch (delegateBasicGroupMember.memberUserItem.status.typeOf) {
                                        case TD_ObjectType.USER_STATUS_ONLINE:     return qsTr ("Online");
                                        case TD_ObjectType.USER_STATUS_OFFLINE:    return qsTr ("Offline since %1").arg (Qt.formatDateTime (delegateBasicGroupMember.memberUserItem.status.wasOnline));
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
                                    visible: (delegateBasicGroupMember.memberUserItem &&
                                              delegateBasicGroupMember.memberUserItem.status &&
                                              delegateBasicGroupMember.memberUserItem.status.typeOf === TD_ObjectType.USER_STATUS_ONLINE);
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
