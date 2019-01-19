import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;

DelegateAbstractMessageContent {
    id: self;
    optimalWidth: placeholder.implicitWidth;

    property TD_MessageAnimation messageContentItem : null;

    property bool paused : true;

    readonly property TD_FormattedText captionItem   : (messageContentItem ? messageContentItem.caption   : null);
    readonly property TD_Animation     animationItem : (messageContentItem ? messageContentItem.animation : null);
    readonly property TD_PhotoSize     photoSizeItem : (animationItem      ? animationItem.thumbnail      : null);

    HelperFileState {
        id: helper;
        fileItem: (animationItem ? animationItem.animation : null);
        autoDownload: true;
    }
    DelegateFormattedText {
        formattedTextItem: captionItem;
        ExtraAnchors.horizontalFill: parent;
    }
    Item {
        id: placeholder;
        implicitWidth: (animationItem ? Math.min (animationItem.width, self.width) : 1);
        implicitHeight: (animationItem ? animationItem.height * implicitWidth / animationItem.width : 1);

        DelegateDownloadableImage {
            fileItem: (photoSizeItem ? photoSizeItem.photo : null);
            autoDownload: true;
            anchors.fill: parent;
        }
        MouseArea {
            anchors.fill: parent;
            onClicked: { paused = !paused; }
        }
        Loader {
            id: loader;
            sourceComponent: {
                if (animationItem) {
                    switch (animationItem.mimeType) {
                    case "video/mp4": return compoAnimationVideo;
                    case "image/gif": return compoAnimationGif;
                    }
                }
                return null;
            }
            anchors.fill: parent;
        }
        Image {
            source: ((!helper.downloaded && !helper.downloading && helper.downloadable)
                     ? "image://theme/icon-m-cloud-download?#808080"
                     : ((helper.downloaded && self.paused)
                        ? "image://theme/icon-m-play?#808080"
                        : ""));
            sourceSize: Qt.size (Theme.iconSizeMedium, Theme.iconSizeMedium);
            anchors.centerIn: parent;
        }
        ProgressCircle {
            value: helper.progress;
            visible: (helper.downloading || helper.uploading);
            implicitWidth: BusyIndicatorSize.Medium;
            implicitHeight: BusyIndicatorSize.Medium;
            anchors.centerIn: parent;
        }
    }
    Component {
        id: compoAnimationGif;

        AnimatedImage {
            cache: true;
            paused: self.paused;
            smooth: true;
            mipmap: true;
            source: helper.url;
            fillMode: Image.PreserveAspectFit;
            antialiasing: true;
            asynchronous: true;
            verticalAlignment: Image.AlignVCenter;
            horizontalAlignment: Image.AlignLeft;
            anchors.fill: parent;
        }
    }
    Component {
        id: compoAnimationVideo;

        WrapperVideoPlayer {
            loop: true;
            muted: true;
            source: helper.url;
            active: !self.paused;
            autoLoad: true;
            autoPlay: true;
            anchors.fill: parent;
        }
    }
}
