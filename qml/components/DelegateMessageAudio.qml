import QtQuick 2.6;
import QtMultimedia 5.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;

DelegateAbstractMessageContent {
    id: self;

    property TD_MessageAudio messageContentItem : null;

    readonly property TD_Audio     audioItem     : (messageContentItem ? messageContentItem.audio      : null);
    readonly property TD_PhotoSize photoSizeItem : (audioItem          ? audioItem.albumCoverThumbnail : null);

    HelperFileState {
        id: helper;
        fileItem: (self.audioItem ? self.audioItem.audio : null);
        autoDownload: false;
    }
    WrapperAudioPlayer {
        id: player;
        source: helper.url;
        active: (TD_Global.currentMessageContent && self.messageContentItem && TD_Global.currentMessageContent === self.messageContentItem);
        autoLoad: true;
        autoPlay: true;
    }
    DelegateFormattedText {
        formattedTextItem: (messageContentItem ? messageContentItem.caption : null);
        ExtraAnchors.horizontalFill: parent;
    }
    LabelFixed {
        text: (self.audioItem ? self.audioItem.fileName : "");
        elide: Text.ElideRight;
        font.pixelSize: Theme.fontSizeSmall;
        ExtraAnchors.horizontalFill: parent;
    }
    LabelFixed {
        text: (self.audioItem ? self.audioItem.title : "");
        visible: (text !== "");
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
        font.bold: true;
        ExtraAnchors.horizontalFill: parent;
    }
    LabelFixed {
        text: (self.audioItem ? self.audioItem.performer : "");
        visible: (text !== "");
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
        font.bold: true;
        ExtraAnchors.horizontalFill: parent;
    }
    RowContainer {
        spacing: Theme.paddingMedium;

        ColumnContainer {
            anchors.verticalCenter: parent.verticalCenter;

            MouseArea {
                implicitWidth: (Theme.iconSizeExtraLarge * 2);
                implicitHeight: (Theme.iconSizeExtraLarge * 2);
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

                Image {
                    source: "qrc:///images/cd-box.svg";
                    visible: !imgAlbumCover.valid;
                    fillMode: Image.PreserveAspectFit;
                    anchors.fill: parent;
                }
                DelegateDownloadableImage {
                    id: imgAlbumCover;
                    fileItem: (self.photoSizeItem ? self.photoSizeItem.photo : null);
                    background: false;
                    autoDownload: true;
                    anchors.fill: parent;
                }
                Image {
                    source: ((helper.downloadable && !helper.downloading && !helper.downloaded)
                             ? "image://theme/icon-m-cloud-download?#808080"
                             : ((helper.downloaded && !player.playing)
                                ? "image://theme/icon-m-play?#808080"
                                : "image://theme/icon-m-pause?#808080"));
                    sourceSize: Qt.size (Theme.iconSizeMedium, Theme.iconSizeMedium);
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
        }
        LabelFixed {
            text: (self.audioItem
                   ? (player.playing
                      ? ("-" + TD_Global.formatTime (player.remaining, false))
                      : TD_Global.formatTime ((self.audioItem.duration * 1000), false))
                   : "--:--");
            color: (player.playing ? Theme.highlightColor : Theme.secondaryColor);
            font.pixelSize: Theme.fontSizeSmall;
            anchors.verticalCenter: parent.verticalCenter;
        }
    }
}
