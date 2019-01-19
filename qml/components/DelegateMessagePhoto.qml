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
            text: qsTr ("Save image in gallery");
            visible: (photoSizeItem !== null);
            enabled: (photoSizeItem &&
                      photoSizeItem.photo &&
                      photoSizeItem.photo.local &&
                      photoSizeItem.photo.local.isDownloadingCompleted);
            onClicked: {
                TD_Global.savePhotoToGallery (photoSizeItem.photo);
                emblem.visible = true;
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

        MouseArea {
            visible: img.valid;
            anchors.fill: parent;
            onClicked: {
                compoImgViewer.createObject (overlay, {
                                                 "source" : img.url,
                                             });
            }
        }
    }
    LabelFixed {
        id: emblem;
        text: qsTr ("(Saved in gallery)");
        opacity: 0.65;
        visible: TD_Global.isPhotoSavedToGallery (photoSizeItem.photo);
        font.pixelSize: Theme.fontSizeExtraSmall;
        ExtraAnchors.horizontalFill: img;
    }
}
