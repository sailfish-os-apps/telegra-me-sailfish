import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;

DelegateAbstractMessageContent {
    id: self;
    spacing: Theme.paddingSmall;

    property TD_MessageChatDeleteMember messageContentItem : null;

    LabelFixed {
        text: (self.messageItem.senderUserId !== self.messageContentItem.userId
               ? qsTr ("Remove member from this group chat :")
               : qsTr ("Left this group chat"));
        color: Theme.secondaryHighlightColor;
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
        font.italic: true;
        font.pixelSize: Theme.fontSizeSmall;
        ExtraAnchors.horizontalFill: parent;
    }
    RowContainer {
        id: delegateRemovedMember;
        spacing: Theme.paddingMedium;
        visible: (self.messageItem.senderUserId !== self.messageContentItem.userId);
        ExtraAnchors.horizontalFill: parent;

        readonly property TD_User userItem : TD_Global.getUserItemById (self.messageContentItem.userId);

        DelegateDownloadableImage {
            size: Theme.iconSizeMedium;
            fileItem: (delegateRemovedMember.userItem && delegateRemovedMember.userItem.profilePhoto
                       ? delegateRemovedMember.userItem.profilePhoto.big
                       : null);
            autoDownload: true;
            anchors.verticalCenter: parent.verticalCenter;
        }
        LabelFixed {
            text: (delegateRemovedMember.userItem ? delegateRemovedMember.userItem.firstName + " " + delegateRemovedMember.userItem.lastName : "");
            color: Theme.highlightColor;
            elide: Text.ElideRight;
            maximumLineCount: 1;
            anchors.verticalCenter: parent.verticalCenter;
            Container.horizontalStretch: 1;
        }
    }
}
