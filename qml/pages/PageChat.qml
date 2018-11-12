import QtQuick 2.6
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;
import "../components";

Page {
    id: page;
    allowedOrientations: Orientation.All;

    property TD_Chat currentChat : null;

    Component {
        id: compoMsgText;

        Label {
            text: (formattedTextItem ? formattedTextItem.text : "");
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere;

            property TD_MessageText messageContentItem : null;

            readonly property TD_FormattedText formattedTextItem : (messageContentItem ? messageContentItem.text : null);
        }
    }
    Component {
        id: compoMsgUnsupported;

        Label {
            text: qsTr ("<Unsupported>");
            color: "magenta";

            property TD_MessageContent messageContentItem : null;
        }
    }
    PageHeader {
        id: headerChat;
        title: (currentChat ? currentChat.title : "");
        ExtraAnchors.topDock: parent;
    }
    SilicaListView {
        clip: true;
        model: (currentChat ? currentChat.messagesModel : 0);
        delegate: Item {
            id: delegateMsg;
            implicitHeight: (layoutMsg.height + layoutMsg.anchors.margins * 2);
            anchors {
                leftMargin: (delegateMsg.messageItem.isOutgoing ? Theme.paddingLarge * 5 : Theme.paddingMedium);
                rightMargin: (!delegateMsg.messageItem.isOutgoing ? Theme.paddingLarge * 5 : Theme.paddingMedium);
            }
            ExtraAnchors.horizontalFill: parent;

            readonly property TD_Message messageItem : modelData;
            readonly property TD_User    userItem    : (messageItem ? TD_Global.getUserItemById (messageItem.senderUserId) : null);

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
                    spacing: Theme.paddingSmall;
                    Container.horizontalStretch: 1;

                    Label {
                        text: (delegateMsg.userItem ? delegateMsg.userItem.firstName + " " + delegateMsg.userItem.lastName : "");
                        color: Theme.highlightColor;
                        ExtraAnchors.horizontalFill: parent;
                    }
                    Loader {
                        id: loaderMsgContent;
                        sourceComponent: {
                            if (messageItem && messageItem.content) {
                                switch (messageItem.content.typeOf) {
                                case TD_ObjectType.MESSAGE_TEXT: return compoMsgText;
                                }
                            }
                            return compoMsgUnsupported;
                        }
                        ExtraAnchors.horizontalFill: parent;

                        Binding {
                            target: loaderMsgContent.item;
                            property: "messageContentItem";
                            value: delegateMsg.messageItem.content;
                            when: (loaderMsgContent.item && delegateMsg.messageItem && delegateMsg.messageItem.content);
                        }
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
        anchors.top: headerChat.bottom;
        ExtraAnchors.bottomDock: parent;
    }
}
