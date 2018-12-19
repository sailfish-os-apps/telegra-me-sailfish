import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;

DelegateAbstractMessageContent {
    id: self;
    spacing: Theme.paddingSmall;

    property TD_MessageChatAddMembers messageContentItem : null;

    LabelFixed {
        text: qsTr ("Added members to this group chat :");
        color: Theme.secondaryHighlightColor;
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
        font.italic: true;
        font.pixelSize: Theme.fontSizeSmall;
        ExtraAnchors.horizontalFill: parent;
    }
    Repeater {
        model: self.messageContentItem.memberUserIds;
        delegate: RowContainer {
            id: delegateAddedMember;
            spacing: Theme.paddingMedium;
            ExtraAnchors.horizontalFill: parent;

            readonly property TD_User userItem : TD_Global.getUserItemById (modelData);

            DelegateDownloadableImage {
                size: Theme.iconSizeMedium;
                fileItem: (delegateAddedMember.userItem && delegateAddedMember.userItem.profilePhoto
                           ? delegateAddedMember.userItem.profilePhoto.big
                           : null);
                autoDownload: true;
                anchors.verticalCenter: parent.verticalCenter;
            }
            LabelFixed {
                text: (delegateAddedMember.userItem ? delegateAddedMember.userItem.firstName + " " + delegateAddedMember.userItem.lastName : "");
                color: Theme.highlightColor;
                elide: Text.ElideRight;
                maximumLineCount: 1;
                anchors.verticalCenter: parent.verticalCenter;
                Container.horizontalStretch: 1;
            }
        }
    }
}
