import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;

DelegateAbstractMessageContent {
    id: self;
    optimalWidth: (Math.min (window.width, window.height) * 0.35);

    property TD_MessageSticker messageContentItem : null;

    readonly property TD_Sticker stickerItem : (messageContentItem ? messageContentItem.sticker : null);

    HelperFileState {
        id: helperMsgStickerFile;
        fileItem: (self.stickerItem ? self.stickerItem.sticker : null);
        autoDownload: true;
    }
    Item {
        implicitWidth: (self.stickerItem
                        ? ((self.stickerItem.width > self.stickerItem.height)
                           ? optimalWidth
                           : (self.stickerItem.width * optimalWidth / self.stickerItem.height))
                        : 0);
        implicitHeight: (self.stickerItem
                         ? ((self.stickerItem.height > self.stickerItem.width)
                            ? optimalWidth
                            : (self.stickerItem.height * optimalWidth / self.stickerItem.width))
                         : 0);

        Image {
            cache: true;
            source: helperMsgStickerFile.url;
            sourceSize: Qt.size (width, height);
            asynchronous: true;
            anchors.fill: parent;
        }
        Image {
            source: ((helperMsgStickerFile.downloadable && !helperMsgStickerFile.downloading && !helperMsgStickerFile.downloaded)
                     ? "image://theme/icon-m-cloud-download?#808080"
                     : "");
            sourceSize: Qt.size (Theme.iconSizeMedium, Theme.iconSizeMedium);
            anchors.centerIn: parent;
        }
        ProgressCircle {
            value: helperMsgStickerFile.progress;
            visible: (helperMsgStickerFile.downloading || helperMsgStickerFile.uploading);
            implicitWidth: BusyIndicatorSize.Medium;
            implicitHeight: BusyIndicatorSize.Medium;
            anchors.centerIn: parent;
        }
    }
}
