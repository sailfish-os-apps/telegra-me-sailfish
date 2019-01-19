import QtQuick 2.6;
import QtMultimedia 5.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;
import QtQml.Models 2.2;

DelegateAbstractMessageContent {
    id: self;
    optimalWidth: vid.width;
    additionalContextMenuItems: ObjectModel {
        MenuItem {
            text: qsTr ("Save video to gallery");
            enabled: (videoItem && videoItem.video && videoItem.video.local && videoItem.video.local.isDownloadingCompleted);
            onClicked: {
                TD_Global.saveVideoToGallery (videoItem.video);
                emblem.visible = true;
            }
        }
    }

    property TD_MessageVideo messageContentItem : null;

    readonly property TD_Video     videoItem     : (messageContentItem ? messageContentItem.video : null);
    readonly property TD_PhotoSize photoSizeItem : (videoItem          ? videoItem.thumbnail      : null);

    HelperFileState {
        id: helper;
        fileItem: (videoItem ? videoItem.video : null);
        autoDownload: false;
    }
    DelegateFormattedText {
        formattedTextItem: (messageContentItem ? messageContentItem.caption : null);
        ExtraAnchors.horizontalFill: parent;
    }
    Item {
        Container.forcedHeight: Theme.paddingSmall;
    }
    MouseArea {
        id: vid;
        implicitWidth: (videoItem ? Math.min (videoItem.width, self.width) : 1);
        Container.forcedHeight: (videoItem ? videoItem.height * implicitWidth / videoItem.width : 1);
        onClicked: {
            if (helper.uploading) {
                // NOTHING WE CAN DO
            }
            else {
                if (helper.downloaded) {
                    if (TD_Global.currentMessageContent === self.messageContentItem) {
                        if (player.playing) {
                            player.pause ();
                        }
                        else {
                            player.play ();
                        }
                    }
                    else {
                        TD_Global.currentMessageContent = self.messageContentItem;
                    }
                }
                else {
                    if (helper.downloadable) {
                        if (helper.downloading) {
                            helper.cancelDownload ();
                        }
                        else {
                            helper.tryDownload (true);
                        }
                    }
                }
            }
        }

        DelegateDownloadableImage {
            fileItem: (photoSizeItem ? photoSizeItem.photo : null);
            autoDownload: true;
            anchors.fill: parent;
        }
        WrapperVideoPlayer {
            id: player;
            source: helper.url;
            active: (TD_Global.currentMessageContent && messageContentItem && TD_Global.currentMessageContent === messageContentItem);
            autoLoad: true;
            autoPlay: true;
            anchors.fill: parent;
        }
        Image {
            source: ((helper.downloadable && !helper.downloading && !helper.downloaded)
                     ? "image://theme/icon-m-cloud-download?#808080"
                     : ((helper.downloaded && !player.playing)
                        ? "image://theme/icon-m-play?#808080"
                        : ""));
            sourceSize: Qt.size (Theme.iconSizeMedium, Theme.iconSizeMedium);
            anchors.centerIn: parent;
        }
        ProgressCircle {
            value: helper.progress;
            visible: (helper.downloading || helper.uploading);
            implicitWidth: BusyIndicatorSize.Large;
            implicitHeight: BusyIndicatorSize.Large;
            anchors.centerIn: parent;
        }
    }
    Item {
        implicitHeight: Theme.paddingSmall;
        ExtraAnchors.horizontalFill: parent;

        Rectangle {
            color: Theme.secondaryColor;
            anchors.fill: parent;
        }
        Rectangle {
            color: Theme.highlightColor;
            implicitWidth: (parent.width * player.progress);
            ExtraAnchors.leftDock: parent;
        }
    }
    LabelFixed {
        id: emblem;
        text: qsTr ("(saved in gallery)");
        opacity: 0.65;
        visible: TD_Global.isVideoSavedToGallery (videoItem.video);
        horizontalAlignment: Text.AlignHCenter;
        font.pixelSize: Theme.fontSizeExtraSmall;
        ExtraAnchors.horizontalFill: vid;
    }
}
