import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;

DelegateAbstractMessageContent {
    id: self;
    spacing: Theme.paddingSmall;

    property TD_MessageChatChangePhoto messageContentItem : null;

    readonly property TD_Photo     photoItem     : (messageContentItem                     ? messageContentItem.photo   : null);
    readonly property TD_PhotoSize photoSizeItem : (photoItem && photoItem.sizes.count > 0 ? photoItem.sizes.getLast () : null);

    LabelFixed {
        text: qsTr ("Changed the group photo :");
        color: Theme.secondaryHighlightColor;
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
        font.italic: true;
        font.pixelSize: Theme.fontSizeSmall;
    }
    DelegateDownloadableImage {
        size: Theme.iconSizeLarge;
        fileItem: (self.photoSizeItem
                   ? self.photoSizeItem.photo
                   : null);
        autoDownload: true;
    }
}
