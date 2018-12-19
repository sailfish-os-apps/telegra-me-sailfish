import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;
import QtQml.Models 2.2;

DelegateAbstractMessageContent {
    id: self;
    spacing: Theme.paddingSmall;
    optimalWidth: img.width;
    additionalContextMenuItems: ObjectModel {
        MenuItem {
            text: qsTr ("Open image in viewer");
            visible: (photoSizeItem !== null);
            enabled: (photoSizeItem && photoSizeItem.photo && photoSizeItem.photo.local && photoSizeItem.photo.local.isDownloadingCompleted);
            onClicked: {
                Qt.openUrlExternally (TD_Global.urlFromLocalPath (photoSizeItem.photo.local.path));
            }
        }
    }

    property TD_MessagePhoto messageContentItem : null;

    readonly property TD_Photo         photoItem     : (messageContentItem ? messageContentItem.photo   : null);
    readonly property TD_FormattedText captionItem   : (messageContentItem ? messageContentItem.caption : null);
    readonly property TD_PhotoSize     photoSizeItem : {
        var ret = null;
        if (photoItem && photoItem.sizes.count > 0) {
            var tmp = photoItem.sizes.get ("x");
            ret = (tmp ? tmp : photoItem.sizes.getLast ());
        }
        return ret;
    }

    DelegateFormattedText {
        formattedTextItem: (messageContentItem ? messageContentItem.caption : null);
        ExtraAnchors.horizontalFill: parent;
    }
    DelegateDownloadableImage {
        id: img;
        width: (self.photoSizeItem ? Math.min (self.photoSizeItem .width, self.width) : 1);
        fileItem: (self.photoSizeItem ? self.photoSizeItem.photo : null);
        autoDownload: true;
        Container.forcedHeight: (self.photoSizeItem ? self.photoSizeItem.height * width / self.photoSizeItem.width : 1);
    }
}
