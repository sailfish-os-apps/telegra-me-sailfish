import QtQuick 2.6;
import QtMultimedia 5.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import Qt.labs.folderlistmodel 2.1;
import QtDocGallery 5.0;
import Nemo.Thumbnailer 1.0;
import harbour.Telegrame 1.0;
import "../components";

Page {
    id: page;
    allowedOrientations: Orientation.All;
    Component.onCompleted: {
        loadMoreMessages (15); // FIXME : maybe a better way...
    }

    property string currentMsgType : "MSGTYPE_01_TEXT";

    property TD_Chat currentChat : null;

    property TD_MessageContent currentMessageContent : null;

    property bool groupImagesInAlbums : true;
    property bool groupVideosInAlbums : true;

    property string currentRecording : "";

    readonly property var msgTypes : ({
                                          "MSGTYPE_01_TEXT"    : { "label" : qsTr ("Text message"),        "type" : TD_ObjectType.MESSAGE_TEXT,       "icon" : "icon-m-text-input" },
                                          "MSGTYPE_02_PHOTO"   : { "label" : qsTr ("Photo (album)"),       "type" : TD_ObjectType.MESSAGE_PHOTO,      "icon" : "icon-m-camera" },
                                          "MSGTYPE_03_VIDEO"   : { "label" : qsTr ("Video"),               "type" : TD_ObjectType.MESSAGE_VIDEO,      "icon" : "icon-m-video" },
                                          "MSGTYPE_04_MUSIC"   : { "label" : qsTr ("Music"),               "type" : TD_ObjectType.MESSAGE_AUDIO,      "icon" : "icon-m-music" },
                                          "MSGTYPE_05_STICKER" : { "label" : qsTr ("Sticker"),             "type" : TD_ObjectType.MESSAGE_STICKER,    "icon" : "icon-m-other" },
                                          "MSGTYPE_06_ANIM"    : { "label" : qsTr ("GIF animation"),       "type" : TD_ObjectType.MESSAGE_ANIMATION,  "icon" : "icon-m-favorite" },
                                          "MSGTYPE_07_VOICE"   : { "label" : qsTr ("Voice note"),          "type" : TD_ObjectType.MESSAGE_VOICE_NOTE, "icon" : "icon-m-mic" },
                                          "MSGTYPE_08_BUBBLE"  : { "label" : qsTr ("Video bubble"),        "type" : TD_ObjectType.MESSAGE_VIDEO_NOTE, "icon" : "icon-m-play" },
                                          "MSGTYPE_09_FILE"    : { "label" : qsTr ("File transfer"),       "type" : TD_ObjectType.MESSAGE_DOCUMENT,   "icon" : "icon-m-attach" },
                                      });

    function downloadFile (fileItem) {
        TD_Global.send ({
                            "@type" : "downloadFile",
                            "file_id" : fileItem.id,
                            "priority" : 1,
                        });
    }

    function cancelDownloadFile (fileItem) {
        TD_Global.send ({
                            "@type" : "cancelDownloadFile",
                            "file_id" : fileItem.id,
                            "only_if_pending" : false,
                        });
    }

    function loadMoreMessages (count) {
        TD_Global.send ({
                            "@type" : "getChatHistory",
                            "chat_id" :  currentChat.id,
                            "from_message_id" : currentChat.messagesModel.getFirst ().id, // Identifier of the message starting from which history must be fetched; use 0 to get results from the begining
                            "offset" : 0, // Specify 0 to get results from exactly the from_message_id or a negative offset to get the specified message and some newer messages
                            "limit" : count, // The maximum number of messages to be returned; must be positive and can't be greater than 100. If the offset is negative, the limit must be greater than -offset. Fewer messages may be returned than specified by the limit, even if the end of the message history has not been reached
                            "only_local" : false, // If true, returns only messages that are available locally without sending network requests
                        });
    }

    Component {
        id: compoMsgText;

        Label {
            id: delegateMsgText;
            text: (formattedTextItem ? formattedTextItem.text : "");
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere;

            property TD_MessageText messageContentItem : null;

            readonly property TD_FormattedText formattedTextItem : (messageContentItem ? messageContentItem.text : null);
        }
    }
    Component {
        id: compoMsgPhoto;

        ColumnContainer {
            id: delegateMsgPhoto;

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

            Label {
                text: (delegateMsgPhoto.captionItem ? delegateMsgPhoto.captionItem.text : "");
                visible: (text !== "");
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                ExtraAnchors.horizontalFill: parent;
            }
            DelegateDownloadableImage {
                width: (delegateMsgPhoto.photoSizeItem ? Math.min (delegateMsgPhoto.photoSizeItem .width, delegateMsgPhoto.width) : 1);
                fileItem: (delegateMsgPhoto.photoSizeItem ? delegateMsgPhoto.photoSizeItem.photo : null);
                Container.forcedHeight: (delegateMsgPhoto.photoSizeItem ? delegateMsgPhoto.photoSizeItem.height * width / delegateMsgPhoto.photoSizeItem.width : 1);
            }
        }
    }
    Component {
        id: compoMsgDocument;

        ColumnContainer {
            id: delegateMsgDocument;

            property TD_MessageDocument messageContentItem : null;

            readonly property TD_FormattedText captionItem   : (messageContentItem  ? messageContentItem.caption  : null);
            readonly property TD_Document      documentItem  : (messageContentItem  ? messageContentItem.document : null);
            readonly property TD_File          fileItem      : (documentItem        ? documentItem.document       : null);
            readonly property TD_LocalFile     localFileItem : (fileItem            ? fileItem.local              : null);

            readonly property string size : {
                if (localFileItem && fileItem) {
                    if (localFileItem.canBeDownloaded && !localFileItem.isDownloadingActive && !localFileItem.isDownloadingCompleted) { // TO BE DOWNLOADED
                        return "(%1)".arg (TD_Global.formatSize (fileItem.expectedSize));
                    }
                    else if (localFileItem.canBeDownloaded && localFileItem.isDownloadingActive && !localFileItem.isDownloadingCompleted) { // DOWNLOADING
                        return "(%1 / %2)".arg (TD_Global.formatSize (localFileItem.downloadedSize)).arg (TD_Global.formatSize (fileItem.expectedSize));
                    }
                    else if (localFileItem.canBeDownloaded && !localFileItem.isDownloadingActive && localFileItem.isDownloadingCompleted) { // DOWNLOADED
                        return "(%1)".arg (TD_Global.formatSize (localFileItem.downloadedSize));
                    }
                    else { }
                }
                return "";
            }

            readonly property string status : {
                if (localFileItem && fileItem) {
                    if (localFileItem.canBeDownloaded && !localFileItem.isDownloadingActive && !localFileItem.isDownloadingCompleted) { // TO BE DOWNLOADED
                        return qsTr ("Click to download")
                    }
                    else if (localFileItem.canBeDownloaded && localFileItem.isDownloadingActive && !localFileItem.isDownloadingCompleted) { // DOWNLOADING
                        return qsTr ("Downloading, please wait...");
                    }
                    else if (localFileItem.canBeDownloaded && !localFileItem.isDownloadingActive && localFileItem.isDownloadingCompleted) { // DOWNLOADED
                        return qsTr ("Downloaded, click to open");
                    }
                    else { }
                }
                return "";
            }

            function click () {
                if (localFileItem.canBeDownloaded && !localFileItem.isDownloadingActive && !localFileItem.isDownloadingCompleted) { // TO BE DOWNLOADED
                    downloadFile (fileItem); // START DOWNLOAD
                }
                else if (localFileItem.canBeDownloaded && localFileItem.isDownloadingActive && !localFileItem.isDownloadingCompleted) { // DOWNLOADING
                    cancelDownloadFile (fileItem); // CANCEL DOWNLOAD
                }
                else if (localFileItem.canBeDownloaded && !localFileItem.isDownloadingActive && localFileItem.isDownloadingCompleted) { // DOWNLOADED
                    Qt.openUrlExternally (TD_Global.urlFromLocalPath (localFileItem.path));  // OPEN FILE
                }
                else { }
            }

            Label {
                text: (delegateMsgDocument.captionItem ? delegateMsgDocument.captionItem.text : "");
                visible: (text !== "");
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                ExtraAnchors.horizontalFill: parent;
            }
            RowContainer {
                spacing: Theme.paddingMedium;
                ExtraAnchors.horizontalFill: parent;

                MouseArea {
                    anchors.fill: parent;
                    Container.ignored: true;
                    onClicked: {
                        delegateMsgDocument.click ();
                    }

                    Rectangle {
                        color: "transparent";
                        border {
                            width: 1;
                            color: Theme.secondaryColor;
                        }
                        anchors {
                            fill: parent;
                            margins: -Theme.paddingSmall;
                        }
                    }
                }
                Image {
                    source: (delegateMsgDocument.documentItem
                             ? "qrc:///symbols/filetypes/%1.svg".arg (TD_Global.getSvgIconForMimeType (delegateMsgDocument.documentItem.mimeType))
                             : "");
                    sourceSize: Qt.size (Theme.iconSizeMedium, Theme.iconSizeMedium);
                    anchors.verticalCenter: parent.verticalCenter;
                }
                ColumnContainer {
                    anchors.verticalCenter: parent.verticalCenter;
                    Container.horizontalStretch: 1;

                    Label {
                        text: (delegateMsgDocument.documentItem ? delegateMsgDocument.documentItem.fileName : "");
                        elide: Text.ElideMiddle;
                        font.underline: true;
                        ExtraAnchors.horizontalFill: parent;
                    }
                    Label {
                        text: delegateMsgDocument.size;
                        color: Theme.secondaryColor;
                        font.pixelSize: Theme.fontSizeSmall;

                        BusyIndicator {
                            size: BusyIndicatorSize.ExtraSmall;
                            running: (delegateMsgDocument.localFileItem && delegateMsgDocument.localFileItem.isDownloadingActive);
                            anchors {
                                left: parent.right;
                                margins: Theme.paddingMedium;
                                verticalCenter: parent.verticalCenter;
                            }
                        }
                    }
                }
            }
            Label {
                text: delegateMsgDocument.status;
                color: Theme.secondaryColor;
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                font.italic: true;
                font.pixelSize: Theme.fontSizeSmall;
                ExtraAnchors.horizontalFill: parent;
            }
        }
    }
    Component {
        id: compoMsgSticker;

        DelegateDownloadableImage {
            id: delegateMsgSticker;
            size: (page.width * 0.35);
            fileItem: (stickerItem ? stickerItem.sticker : null);
            background: false;
            implicitWidth: (stickerItem
                            ? ((stickerItem.width > stickerItem.height)
                               ? size
                               : (stickerItem.width * size / stickerItem.height))
                            : 0);
            implicitHeight: (stickerItem
                             ? ((stickerItem.height > stickerItem.width)
                                ? size
                                : (stickerItem.height * size / stickerItem.width))
                             : 0);

            property TD_MessageSticker messageContentItem : null;

            readonly property TD_Sticker stickerItem : (messageContentItem ? messageContentItem.sticker : null);
        }
    }
    Component {
        id: compoMsgVideo;

        ColumnContainer {
            id: delegateMsgVideo;

            property TD_MessageVideo messageContentItem : null;

            readonly property TD_FormattedText captionItem   : (messageContentItem  ? messageContentItem.caption : null);
            readonly property TD_Video         videoItem     : (messageContentItem  ? messageContentItem.video   : null);
            readonly property TD_PhotoSize     photoSizeItem : (videoItem           ? videoItem.thumbnail        : null);

            HelperFileState {
                id: helperMsgVideoFile;
                fileItem: (delegateMsgVideo.videoItem ? delegateMsgVideo.videoItem.video : null)
            }
            Label {
                text: (delegateMsgVideo.captionItem ? delegateMsgVideo.captionItem.text : "");
                visible: (text !== "");
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                ExtraAnchors.horizontalFill: parent;
            }
            ColumnContainer {
                MouseArea {
                    implicitWidth: (delegateMsgVideo.videoItem ? Math.min (delegateMsgVideo.videoItem.width, delegateMsgVideo.width) : 1);
                    Container.forcedHeight: (delegateMsgVideo.videoItem ? delegateMsgVideo.videoItem.height * implicitWidth / delegateMsgVideo.videoItem.width : 1);
                    onClicked: {
                        if (helperMsgVideoFile.downloadable && !helperMsgVideoFile.downloading && !helperMsgVideoFile.downloaded) {
                            helperMsgVideoFile.tryDownload (true); // START DOWNLOAD
                        }
                        else if (helperMsgVideoFile.downloadable && helperMsgVideoFile.downloading && !helperMsgVideoFile.downloaded) {
                            helperMsgVideoFile.cancelDownload (); // CANCEL DOWNLOAD
                        }
                        else if (helperMsgVideoFile.downloaded) {
                            if (currentMessageContent !== delegateMsgVideo.messageContentItem) {
                                currentMessageContent = delegateMsgVideo.messageContentItem;
                            }
                            else {
                                if (playerVideo.playing) {
                                    playerVideo.pause ();
                                }
                                else {
                                    playerVideo.play ();
                                }
                            }
                        }
                    }

                    DelegateDownloadableImage {
                        fileItem: (delegateMsgVideo.photoSizeItem ? delegateMsgVideo.photoSizeItem.photo : null);
                        anchors.fill: parent;
                    }
                    WrapperVideoPlayer {
                        id: playerVideo;
                        source: helperMsgVideoFile.url;
                        active: (currentMessageContent && delegateMsgVideo.messageContentItem && currentMessageContent === delegateMsgVideo.messageContentItem);
                        autoLoad: true;
                        autoPlay: true;
                        anchors.fill: parent;
                    }
                    Image {
                        source: ((helperMsgVideoFile.downloadable && !helperMsgVideoFile.downloading && !helperMsgVideoFile.downloaded)
                                 ? "image://theme/icon-m-cloud-download?#808080"
                                 : ((helperMsgVideoFile.downloaded && !playerVideo.playing)
                                    ? "image://theme/icon-m-play?#808080"
                                    : ""));
                        anchors.centerIn: parent;
                    }
                    ProgressCircle {
                        value: helperMsgVideoFile.progress;
                        visible: (helperMsgVideoFile.downloading || helperMsgVideoFile.uploading);
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
                        implicitWidth: (parent.width * playerVideo.progress);
                        ExtraAnchors.leftDock: parent;
                    }
                }
            }
        }
    }
    Component {
        id: compoMsgAudio;

        ColumnContainer {
            id: delegateMsgAudio;

            property TD_MessageAudio messageContentItem : null;

            readonly property TD_Audio     audioItem     : (messageContentItem ? messageContentItem.audio      : null);
            readonly property TD_File      fileItem      : (audioItem          ? audioItem.audio               : null);
            readonly property TD_LocalFile localFileItem : (fileItem           ? fileItem.local                : null);
            readonly property TD_PhotoSize photoSizeItem : (audioItem          ? audioItem.albumCoverThumbnail : null);

            property int  remaining : 0;
            property bool playing   : false;

            Label {
                text: (delegateMsgAudio.audioItem
                       ? delegateMsgAudio.audioItem.fileName
                       : "");
                elide: Text.ElideRight;
                font.pixelSize: Theme.fontSizeSmall;
                ExtraAnchors.horizontalFill: parent;
            }
            Label {
                text: (delegateMsgAudio.audioItem
                       ? (delegateMsgAudio.audioItem.title !== ""
                          ? delegateMsgAudio.audioItem.title
                          : "")
                       : "");
                visible: (text !== "");
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                font.bold: true;
                ExtraAnchors.horizontalFill: parent;
            }
            Label {
                text: (delegateMsgAudio.audioItem
                       ? (delegateMsgAudio.audioItem.performer !== ""
                          ? delegateMsgAudio.audioItem.performer
                          : "")
                       : "");
                visible: (text !== "");
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                font.bold: true;
                ExtraAnchors.horizontalFill: parent;
            }
            RowContainer {
                spacing: Theme.paddingMedium;

                MouseArea {
                    implicitWidth: (Theme.iconSizeExtraLarge * 2);
                    implicitHeight: (Theme.iconSizeExtraLarge * 2);
                    anchors.verticalCenter: parent.verticalCenter;
                    onClicked: {
                        if (delegateMsgAudio.localFileItem) {
                            if (delegateMsgAudio.localFileItem.canBeDownloaded && !delegateMsgAudio.localFileItem.isDownloadingActive && !delegateMsgAudio.localFileItem.isDownloadingCompleted) {
                                downloadFile (delegateMsgAudio.fileItem); // START DOWNLOAD
                            }
                            else if (delegateMsgAudio.localFileItem.canBeDownloaded && delegateMsgAudio.localFileItem.isDownloadingActive && !delegateMsgAudio.localFileItem.isDownloadingCompleted) {
                                cancelDownloadFile (delegateMsgAudio.fileItem); // CANCEL DOWNLOAD
                            }
                            else if (delegateMsgAudio.localFileItem.isDownloadingCompleted) {
                                currentMessageContent = delegateMsgAudio.localFileItem;
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
                        fileItem: (delegateMsgAudio.photoSizeItem ? delegateMsgAudio.photoSizeItem.photo : null);
                        background: false;
                        anchors.fill: parent;
                    }
                    Image {
                        source: "image://theme/icon-m-play?#FFFFFF";
                        visible: (currentMessageContent !== delegateMsgAudio.localFileItem && delegateMsgAudio.localFileItem.isDownloadingCompleted);
                        anchors.centerIn: parent;
                    }
                    Loader {
                        active: (currentMessageContent && delegateMsgAudio.localFileItem && currentMessageContent === delegateMsgAudio.localFileItem);
                        sourceComponent: MouseArea {
                            onClicked: {
                                if (playerAudio.playbackState === MediaPlayer.PlayingState) {
                                    playerAudio.pause ();
                                }
                                else {
                                    playerAudio.play ();
                                }
                            }

                            Image {
                                source: (playerAudio.playbackState !== MediaPlayer.PlayingState
                                         ? "image://theme/icon-m-play?#FFFFFF"
                                         : "image://theme/icon-m-pause?#FFFFFF");
                                anchors.centerIn: parent;
                            }
                            MediaPlayer {
                                id: playerAudio;
                                source: (delegateMsgAudio.localFileItem && delegateMsgAudio.localFileItem.path !== ""
                                         ? TD_Global.urlFromLocalPath (delegateMsgAudio.localFileItem.path)
                                         : "");
                                autoLoad: true;
                                autoPlay: true;
                            }
                            Binding {
                                target: delegateMsgAudio;
                                property: "remaining";
                                value: (playerAudio.duration - playerAudio.position);
                            }
                            Binding {
                                target: delegateMsgAudio;
                                property: "playing";
                                value: (playerAudio.playbackState === MediaPlayer.PlayingState);
                            }
                        }
                        anchors.fill: parent;
                    }
                    Image {
                        source: "image://theme/icon-m-cloud-download?#FFFFFF";
                        visible: (delegateMsgAudio.localFileItem &&
                                  delegateMsgAudio.localFileItem.canBeDownloaded &&
                                  !delegateMsgAudio.localFileItem.isDownloadingActive &&
                                  !delegateMsgAudio.localFileItem.isDownloadingCompleted);
                        anchors.centerIn: parent;
                    }
                }
                Label {
                    text: (delegateMsgAudio.audioItem
                           ? (delegateMsgAudio.playing
                              ? ("-" + TD_Global.formatTime (delegateMsgAudio.remaining, false))
                              : TD_Global.formatTime ((delegateMsgAudio.audioItem.duration * 1000), false))
                           : "--:--");
                    color: (delegateMsgAudio.playing ? Theme.highlightColor : Theme.secondaryColor);
                    font.pixelSize: Theme.fontSizeSmall;
                    anchors.verticalCenter: parent.verticalCenter;
                }
            }
        }
    }
    Component {
        id: compoMsgAnimation;

        Item {
            id: delegateMsgAnimation;
            implicitHeight: placeholderAnim.height;
            Component.onCompleted: { download (); }
            onDownloadableChanged: { download (); }
            onDownloadingChanged:  { download (); }
            onDownloadedChanged:   { download (); }

            property TD_MessageAnimation messageContentItem : null;

            readonly property TD_FormattedText captionItem   : (messageContentItem ? messageContentItem.caption   : null);
            readonly property TD_Animation     animationItem : (messageContentItem ? messageContentItem.animation : null);
            readonly property TD_File          fileItem      : (animationItem      ? animationItem.animation      : null);
            readonly property TD_LocalFile     localFileItem : (fileItem           ? fileItem.local               : null);
            readonly property TD_PhotoSize     photoSizeItem : (animationItem      ? animationItem.thumbnail      : null);

            readonly property bool             downloadable  : (localFileItem && localFileItem.canBeDownloaded);
            readonly property bool             downloading   : (localFileItem && localFileItem.isDownloadingActive);
            readonly property bool             downloaded    : (localFileItem && localFileItem.isDownloadingCompleted);

            function download () {
                if (downloadable && !downloading && !downloaded ) {
                    downloadFile (fileItem);
                }
            }

            Item {
                id: placeholderAnim;
                implicitWidth: (delegateMsgAnimation.animationItem ? Math.min (delegateMsgAnimation.animationItem.width, delegateMsgAnimation.width) : 1);
                implicitHeight: (delegateMsgAnimation.animationItem ? delegateMsgAnimation.animationItem.height * width / delegateMsgAnimation.animationItem.width : 1);
                ExtraAnchors.topLeftCorner: parent;

                DelegateDownloadableImage {
                    fileItem: (delegateMsgAnimation.photoSizeItem ? delegateMsgAnimation.photoSizeItem.photo : null);
                    anchors.fill: parent;
                }
                Loader {
                    id: loaderAnim;
                    sourceComponent: {
                        if (delegateMsgAnimation.animationItem) {
                            switch (delegateMsgAnimation.animationItem.mimeType) {
                            case "video/mp4": return compoAnimationVideo;
                            case "image/gif": return compoAnimationGif;
                            }
                        }
                        return null;
                    }
                    anchors.fill: parent;
                }
                ProgressCircle {
                    value: (delegateMsgAnimation.localFileItem
                            ? (delegateMsgAnimation.localFileItem.downloadedSize / Math.max (delegateMsgAnimation.fileItem.size, 1) )
                            : 0);
                    visible: delegateMsgAnimation.downloading;
                    implicitWidth: BusyIndicatorSize.Medium;
                    implicitHeight: BusyIndicatorSize.Medium;
                    anchors.centerIn: parent;
                }
                Image {
                    source: "image://theme/icon-m-cloud-download?#FFFFFF";
                    visible: (!delegateMsgAnimation.downloaded && !delegateMsgAnimation.downloading && delegateMsgAnimation.downloadable);
                    anchors.centerIn: parent;
                }
            }
            Component {
                id: compoAnimationGif;

                AnimatedImage {
                    cache: true;
                    smooth: true;
                    mipmap: true;
                    source: (delegateMsgAnimation.localFileItem && delegateMsgAnimation.localFileItem.path !== ""
                             ? TD_Global.urlFromLocalPath (delegateMsgAnimation.localFileItem.path)
                             : "");
                    fillMode: Image.PreserveAspectFit;
                    antialiasing: true;
                    asynchronous: true;
                    verticalAlignment: Image.AlignVCenter;
                    horizontalAlignment: Image.AlignLeft;
                    anchors.fill: parent;

                    MouseArea {
                        anchors.fill: parent;
                        onClicked: { parent.paused = !parent.paused; }
                    }
                    Image {
                        source: "image://theme/icon-m-play?#FFFFFF";
                        visible: (delegateMsgAnimation.downloaded && parent.paused);
                        anchors.centerIn: parent;
                    }
                }
            }
            Component {
                id: compoAnimationVideo;

                Video {
                    muted: true;
                    smooth: true;
                    source: (delegateMsgAnimation.localFileItem && delegateMsgAnimation.localFileItem.path !== ""
                             ? TD_Global.urlFromLocalPath (delegateMsgAnimation.localFileItem.path)
                             : "");
                    autoLoad: false;
                    autoPlay: false;
                    fillMode: VideoOutput.PreserveAspectFit;
                    antialiasing: true;
                    anchors.fill: parent;
                    onStopped: {
                        play ();
                    }

                    MouseArea {
                        anchors.fill: parent;
                        onClicked: {
                            if (parent.playbackState !== MediaPlayer.PlayingState) {
                                parent.play ();
                            }
                            else {
                                parent.pause ();
                            }
                        }
                    }
                    Image {
                        source: "image://theme/icon-m-play?#FFFFFF";
                        visible: (delegateMsgAnimation.downloaded && parent.playbackState !== MediaPlayer.PlayingState);
                        anchors.centerIn: parent;
                    }
                }
            }
        }
    }
    Component {
        id: compoMsgVoiceNote;

        ColumnContainer {
            id: delegateMsgVoiceNote;
            spacing: Theme.paddingSmall;

            property TD_MessageVoiceNote messageContentItem : null;

            readonly property TD_FormattedText captionItem   : (messageContentItem ? messageContentItem.caption   : null);
            readonly property TD_VoiceNote     voiceNoteItem : (messageContentItem ? messageContentItem.voiceNote : null);
            readonly property TD_File          fileItem      : (voiceNoteItem      ? voiceNoteItem.voice          : null);
            readonly property TD_LocalFile     localFileItem : (fileItem           ? fileItem.local               : null);

            property bool playing   : false;
            property real progress  : 0.0;
            property int  remaining : 0;

            signal seekRequested (real ratio);

            Label {
                text: (delegateMsgVoiceNote.captionItem ? delegateMsgVoiceNote.captionItem.text : "");
                visible: (text !== "");
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                ExtraAnchors.horizontalFill: parent;
            }
            RowContainer {
                spacing: Theme.paddingMedium;
                ExtraAnchors.horizontalFill: parent;

                MouseArea {
                    implicitWidth: Theme.itemSizeMedium;
                    implicitHeight: Theme.itemSizeMedium;
                    anchors.verticalCenter: parent.verticalCenter;
                    onClicked: {
                        if (delegateMsgVoiceNote.localFileItem) {
                            if (delegateMsgVoiceNote.localFileItem.canBeDownloaded && !delegateMsgVoiceNote.localFileItem.isDownloadingActive && !delegateMsgVoiceNote.localFileItem.isDownloadingCompleted) {
                                downloadFile (delegateMsgVoiceNote.fileItem); // START DOWNLOAD
                            }
                            else if (delegateMsgVoiceNote.localFileItem.canBeDownloaded && delegateMsgVoiceNote.localFileItem.isDownloadingActive && !delegateMsgVoiceNote.localFileItem.isDownloadingCompleted) {
                                cancelDownloadFile (delegateMsgVoiceNote.fileItem); // CANCEL DOWNLOAD
                            }
                            else if (delegateMsgVoiceNote.localFileItem.isDownloadingCompleted) {
                                currentMessageContent = delegateMsgVoiceNote.localFileItem;
                            }
                        }
                    }

                    Rectangle {
                        color: (parent.pressed ? Theme.highlightColor : Theme.primaryColor);
                        radius: Theme.paddingSmall;
                        opacity: 0.15;
                        anchors.fill: parent;
                    }
                    Loader {
                        active: (currentMessageContent && delegateMsgVoiceNote.localFileItem && currentMessageContent === delegateMsgVoiceNote.localFileItem);
                        sourceComponent: MouseArea {
                            anchors.fill: parent;
                            onClicked: {
                                if (playerVoiceNote.playbackState !== MediaPlayer.PlayingState) {
                                    playerVoiceNote.play ();
                                }
                                else {
                                    playerVoiceNote.pause ();
                                }
                            }

                            Image {
                                source: (playerVoiceNote.playbackState !== MediaPlayer.PlayingState
                                         ? "image://theme/icon-m-play?#FFFFFF"
                                         : "image://theme/icon-m-pause?#FFFFFF");
                                anchors.centerIn: parent;
                            }
                            MediaPlayer {
                                id: playerVoiceNote;
                                source: (delegateMsgVoiceNote.localFileItem && delegateMsgVoiceNote.localFileItem.path !== ""
                                         ? TD_Global.urlFromLocalPath (delegateMsgVoiceNote.localFileItem.path)
                                         : "");
                                autoLoad: true;
                                autoPlay: true;
                                Component.onCompleted: {
                                    delegateMsgVoiceNote.seekRequested.connect (function (ratio) {
                                        if (ratio >= 0.0 && ratio <= 1.0) {
                                            seek (Math.round (ratio * duration));
                                        }
                                    });
                                }
                            }
                            Binding {
                                target: delegateMsgVoiceNote;
                                property: "progress";
                                value: (playerVoiceNote.duration ? playerVoiceNote.position / playerVoiceNote.duration : 0.0);
                            }
                            Binding {
                                target: delegateMsgVoiceNote;
                                property: "remaining";
                                value: (playerVoiceNote.duration - playerVoiceNote.position);
                            }
                            Binding {
                                target: delegateMsgVoiceNote;
                                property: "playing";
                                value: (playerVoiceNote.playbackState === MediaPlayer.PlayingState);
                            }
                        }
                        anchors.fill: parent;
                    }
                    Image {
                        source: "image://theme/icon-m-play?#FFFFFF";
                        visible: (delegateMsgVoiceNote.localFileItem &&
                                  delegateMsgVoiceNote.localFileItem.isDownloadingCompleted &&
                                  (!currentMessageContent ||
                                   !delegateMsgVoiceNote.localFileItem ||
                                   currentMessageContent !== delegateMsgVoiceNote.localFileItem));
                        anchors.centerIn: parent;
                    }
                    ProgressCircle {
                        value: (delegateMsgVoiceNote.localFileItem && delegateMsgVoiceNote.fileItem
                                ? (delegateMsgVoiceNote.localFileItem.downloadedSize / Math.max (delegateMsgVoiceNote.fileItem.size, 1) )
                                : 0);
                        visible: (delegateMsgVoiceNote.localFileItem && delegateMsgVoiceNote.localFileItem.isDownloadingActive);
                        implicitWidth: BusyIndicatorSize.Medium;
                        implicitHeight: BusyIndicatorSize.Medium;
                        anchors.centerIn: parent;
                    }
                    Image {
                        source: "image://theme/icon-m-cloud-download?#FFFFFF";
                        visible: (delegateMsgVoiceNote.localFileItem &&
                                  delegateMsgVoiceNote.localFileItem.canBeDownloaded &&
                                  !delegateMsgVoiceNote.localFileItem.isDownloadingCompleted &&
                                  !delegateMsgVoiceNote.localFileItem.isDownloadingActive);
                        anchors.centerIn: parent;
                    }
                }
                ColumnContainer {
                    spacing: 1;
                    anchors.verticalCenter: parent.verticalCenter;
                    Container.horizontalStretch: 1;

                    RowContainer {
                        spacing: 1;

                        MouseArea {
                            anchors.fill: parent;
                            Container.ignored: true;
                            onClicked: {
                                delegateMsgVoiceNote.seekRequested (mouse.x / width);
                            }
                        }
                        Repeater {
                            model: (delegateMsgVoiceNote.voiceNoteItem && delegateMsgVoiceNote.voiceNoteItem.waveform !== ""
                                    ? TD_Global.parseWaveform (delegateMsgVoiceNote.voiceNoteItem.waveform)
                                    : 0);
                            delegate: Rectangle {
                                color: ((model.index / 100) <= delegateMsgVoiceNote.progress ? Theme.highlightColor : Theme.secondaryColor);
                                implicitWidth: 3;
                                implicitHeight: (modelData * 2);
                                anchors.verticalCenter: parent.verticalCenter;
                            }
                        }
                        Rectangle {
                            color: Theme.primaryColor;
                            implicitHeight: 1;
                            anchors.verticalCenter: parent.verticalCenter;
                            ExtraAnchors.horizontalFill: parent;

                            Rectangle {
                                color: Theme.highlightColor;
                                implicitWidth: (parent.width * delegateMsgVoiceNote.progress);
                                ExtraAnchors.leftDock: parent;
                            }
                        }
                    }
                    Label {
                        text: (delegateMsgVoiceNote.voiceNoteItem
                               ?  (delegateMsgVoiceNote.playing
                                   ? qsTr ("(Listening...)")
                                   : (delegateMsgVoiceNote.messageContentItem.isListened
                                      ? qsTr ("(Listened)")
                                      : qsTr ("(Not listened yet)")))
                               : "");
                        color: Theme.secondaryColor;
                        font.pixelSize: Theme.fontSizeSmall;
                    }
                    Label {
                        text: (delegateMsgVoiceNote.voiceNoteItem
                               ? (delegateMsgVoiceNote.playing
                                  ? ("-" + TD_Global.formatTime (delegateMsgVoiceNote.remaining, false))
                                  : TD_Global.formatTime ((delegateMsgVoiceNote.voiceNoteItem.duration * 1000), false))
                               : "--:--");
                        color: (delegateMsgVoiceNote.playing ? Theme.highlightColor : Theme.primaryColor);
                        font.pixelSize: Theme.fontSizeSmall;
                    }
                }
            }
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
    SilicaFlickable {
        id: flickerMessages;
        clip: true;
        quickScroll: true;
        contentWidth: width;
        contentHeight: layoutMessages.height;
        anchors.fill: parent;
        anchors.bottomMargin: footerChat.height;
        onContentYChanged: {
            timerAutoMoveMove.restart ();
        }

        property int autoMoveMode : stayAtBottom;

        readonly property int stayFree     : 0;
        readonly property int stayAtTop    : 1;
        readonly property int stayAtBottom : 2;

        Binding on contentY {
            when: (flickerMessages.autoMoveMode === flickerMessages.stayAtBottom);
            value: (flickerMessages.contentHeight - flickerMessages.height);
        }
        Binding on contentY {
            when: (flickerMessages.autoMoveMode === flickerMessages.stayAtTop);
            value: 0;
        }
        Timer {
            id: timerAutoMoveMove;
            repeat: false;
            running: false;
            interval: 150;
            onTriggered: {
                if (flickerMessages.flicking || flickerMessages.dragging) {
                    flickerMessages.autoMoveMode = flickerMessages.stayFree;
                }
                else {
                    if (flickerMessages.atYBeginning) {
                        flickerMessages.autoMoveMode = flickerMessages.stayAtTop;
                    }
                    else if (flickerMessages.atYEnd) {
                        flickerMessages.autoMoveMode = flickerMessages.stayAtBottom;
                    }
                    else {
                        flickerMessages.autoMoveMode = flickerMessages.stayFree;
                    }
                }
            }
        }
        PullDownMenu {
            id: pulleyTop;

            MenuItem {
                text: qsTr ("Load 50 older messages...");
                onClicked: {
                    loadMoreMessages (50);
                }
            }
        }
        ColumnContainer {
            id: layoutMessages;
            ExtraAnchors.topDock: parent;

            Item {
                ExtraAnchors.horizontalFill: parent;
                Container.forcedHeight: headerChat.height;
            }
            Repeater {
                model: (currentChat ? currentChat.messagesModel : 0);
                delegate: Item {
                    id: delegateMsg;
                    implicitHeight: (layoutMsg.height + layoutMsg.anchors.margins * 1.5);
                    anchors {
                        leftMargin: (!delegateMsg.messageItem.isOutgoing ? Theme.paddingLarge * 5 : Theme.paddingMedium);
                        rightMargin: (delegateMsg.messageItem.isOutgoing ? Theme.paddingLarge * 5 : Theme.paddingMedium);
                    }
                    ExtraAnchors.horizontalFill: parent;

                    readonly property TD_Message messageItem : modelData;
                    readonly property TD_User    userItem    : (messageItem ? TD_Global.getUserItemById (messageItem.senderUserId) : null);

                    Binding {
                        target: loaderMsgContent.item;
                        property: "messageContentItem";
                        value: delegateMsg.messageItem.content;
                        when: (loaderMsgContent.item && delegateMsg.messageItem && delegateMsg.messageItem.content);
                    }
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
                            spacing: 1;
                            Container.horizontalStretch: 1;

                            Label {
                                text: (delegateMsg.userItem ? delegateMsg.userItem.firstName + " " + delegateMsg.userItem.lastName : "");
                                color: Theme.highlightColor;
                                ExtraAnchors.horizontalFill: parent;
                            }
                            Loader {
                                id: loaderMsgContent;
                                sourceComponent: {
                                    if (delegateMsg.messageItem && delegateMsg.messageItem.content) {
                                        switch (delegateMsg.messageItem.content.typeOf) {
                                        case TD_ObjectType.MESSAGE_TEXT:       return compoMsgText;
                                        case TD_ObjectType.MESSAGE_PHOTO:      return compoMsgPhoto;
                                        case TD_ObjectType.MESSAGE_DOCUMENT:   return compoMsgDocument;
                                        case TD_ObjectType.MESSAGE_STICKER:    return compoMsgSticker;
                                        case TD_ObjectType.MESSAGE_VIDEO:      return compoMsgVideo;
                                        case TD_ObjectType.MESSAGE_AUDIO:      return compoMsgAudio;
                                        case TD_ObjectType.MESSAGE_ANIMATION:  return compoMsgAnimation;
                                        case TD_ObjectType.MESSAGE_VOICE_NOTE: return compoMsgVoiceNote;
                                        }
                                    }
                                    return compoMsgUnsupported;
                                }
                                ExtraAnchors.horizontalFill: parent;
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
            }
        }
        VerticalScrollDecorator { flickable: parent; }
    }
    Item {
        id: footerChat;
        implicitHeight: (layoutFooter.height + layoutFooter.anchors.margins * 2);
        ExtraAnchors.bottomDock: parent;

        ColumnContainer {
            id: layoutFooter;
            verticalSpacing: 1;
            anchors.margins: 1;
            ExtraAnchors.topDock: parent;

            RowContainer {
                visible: (currentMsgType === "MSGTYPE_01_TEXT");
                anchors.margins: Theme.paddingSmall;
                ExtraAnchors.horizontalFill: parent;
                Container.forcedHeight: (implicitHeight + anchors.margins * 2);

                Item {
                    implicitHeight: Math.min (inputMsg.implicitHeight, Theme.itemSizeLarge * 2);
                    anchors.bottom: parent.bottom;
                    anchors.margins: Theme.paddingSmall;
                    Container.horizontalStretch: 1;

                    TextArea {
                        id: inputMsg;
                        labelVisible: false;
                        placeholderText: qsTr ("Text message");
                        autoScrollEnabled: true;
                        anchors.fill: parent;
                    }
                }
                RectangleButton {
                    icon: "icon-m-enter";
                    size: Theme.iconSizeMedium;
                    enabled: (inputMsg.text.trim () !== "");
                    implicitWidth: Theme.itemSizeSmall;
                    implicitHeight: Theme.itemSizeSmall;
                    anchors.bottom: parent.bottom;
                    anchors.margins: Theme.paddingSmall;
                    onClicked: {
                        var tmp = inputMsg.text.trim ();
                        if (tmp !== "") {
                            TD_Global.sendMessageText (currentChat, tmp);
                            flickerMessages.autoMoveMode = flickerMessages.stayAtBottom;
                        }
                        inputMsg.text = "";
                    }
                }
            }
            RowContainer {
                visible: (currentMsgType === "MSGTYPE_02_PHOTO");
                spacing: Theme.paddingMedium;
                anchors.margins: Theme.paddingSmall;
                Container.forcedHeight: (implicitHeight + anchors.margins * 2);
                ExtraAnchors.horizontalFill: parent;

                Label {
                    text: (TD_Global.selectedPhotosCount > 0
                           ? (groupImagesInAlbums
                              ? qsTr ("Send %1 images as an album").arg (TD_Global.selectedPhotosCount)
                              : qsTr ("Send %1 images separately").arg (TD_Global.selectedPhotosCount))
                           : qsTr ("No image selected"));
                    color: (TD_Global.selectedPhotosCount > 0 ? Theme.highlightColor : Theme.secondaryColor);
                    anchors.verticalCenter: parent.verticalCenter;
                    Container.horizontalStretch: 1;
                }
                RectangleButton {
                    icon: "icon-m-levels";
                    size: Theme.iconSizeMedium;
                    active: groupImagesInAlbums;
                    implicitWidth: Theme.itemSizeSmall;
                    implicitHeight: Theme.itemSizeSmall;
                    anchors.verticalCenter: parent.verticalCenter;
                    onClicked: {
                        groupImagesInAlbums = !groupImagesInAlbums;
                    }
                }
                RectangleButton {
                    icon: "icon-m-enter";
                    size: Theme.iconSizeMedium;
                    enabled: (TD_Global.selectedPhotosCount > 0);
                    implicitWidth: Theme.itemSizeSmall;
                    implicitHeight: Theme.itemSizeSmall;
                    anchors.verticalCenter: parent.verticalCenter;
                    onClicked: {
                        if (TD_Global.selectedPhotosCount > 0) {
                            TD_Global.sendMessagePhoto (currentChat, groupImagesInAlbums);
                            TD_Global.unselectAllPhotos ();
                            flickerMessages.autoMoveMode = flickerMessages.stayAtBottom;
                        }
                    }
                }
            }
            RowContainer {
                visible: (currentMsgType === "MSGTYPE_02_PHOTO");
                anchors.margins: 1;
                ExtraAnchors.horizontalFill: parent;
                Container.forcedHeight: (Theme.itemSizeHuge * 2);

                SilicaGridView {
                    clip: true;
                    cellWidth: (width / 4);
                    cellHeight: cellWidth;
                    quickScroll: true;
                    anchors.fill: parent;
                    model: DocumentGalleryModel {
                        id: galleryModel;
                        rootType: DocumentGallery.Image;
                        properties: ["url", "filePath", "dateTaken", "mimeType", "width", "height"];
                        autoUpdate: true;
                        sortProperties: ["-dateTaken"];
                    }
                    delegate: MouseArea {
                        id: delegatePhoto;
                        implicitWidth: GridView.view.cellWidth;
                        implicitHeight: GridView.view.cellHeight;
                        onClicked: {
                            if (selected) {
                                TD_Global.deselectPhoto (model.filePath);
                            }
                            else {
                                TD_Global.selectPhoto (model.filePath, model.width, model.height);
                            }
                        }

                        readonly property bool selected : (TD_Global.selectedPhotosCount > 0 && TD_Global.isPhotoSelected (model.filePath));

                        Image {
                            cache: false;
                            source: ("image://nemoThumbnail/" + model.url);
                            fillMode: Image.PreserveAspectCrop;
                            sourceSize: Qt.size (width, height);
                            asynchronous: true;
                            anchors.fill: parent;
                            anchors.margins: 1;

                            Rectangle {
                                color: "transparent";
                                visible: delegatePhoto.selected;
                                border {
                                    width: 3;
                                    color: Theme.highlightColor;
                                }
                                anchors.fill: parent;
                            }
                        }
                    }

                    VerticalScrollDecorator { flickable: parent; }
                }
            }
            RowContainer {
                visible: (currentMsgType === "MSGTYPE_03_VIDEO");
                spacing: Theme.paddingMedium;
                anchors.margins: Theme.paddingSmall;
                Container.forcedHeight: (implicitHeight + anchors.margins * 2);
                ExtraAnchors.horizontalFill: parent;

                Label {
                    text: (TD_Global.selectedVideosCount > 0
                           ? (groupVideosInAlbums
                              ? qsTr ("Send %1 videos as an album").arg (TD_Global.selectedVideosCount)
                              : qsTr ("Send %1 videos separately").arg (TD_Global.selectedVideosCount))
                           : qsTr ("No video selected"));
                    color: (TD_Global.selectedVideosCount > 0 ? Theme.highlightColor : Theme.secondaryColor);
                    anchors.verticalCenter: parent.verticalCenter;
                    Container.horizontalStretch: 1;
                }
                RectangleButton {
                    icon: "icon-m-levels";
                    size: Theme.iconSizeMedium;
                    active: groupVideosInAlbums;
                    implicitWidth: Theme.itemSizeSmall;
                    implicitHeight: Theme.itemSizeSmall;
                    anchors.verticalCenter: parent.verticalCenter;
                    onClicked: {
                        groupVideosInAlbums = !groupVideosInAlbums;
                    }
                }
                RectangleButton {
                    icon: "icon-m-enter";
                    size: Theme.iconSizeMedium;
                    enabled: (TD_Global.selectedVideosCount > 0);
                    implicitWidth: Theme.itemSizeSmall;
                    implicitHeight: Theme.itemSizeSmall;
                    anchors.verticalCenter: parent.verticalCenter;
                    onClicked: {
                        if (TD_Global.selectedVideosCount > 0) {
                            TD_Global.sendMessageVideo (currentChat, groupVideosInAlbums);
                            TD_Global.unselectAllVideos ();
                            flickerMessages.autoMoveMode = flickerMessages.stayAtBottom;
                        }
                    }
                }
            }
            RowContainer {
                visible: (currentMsgType === "MSGTYPE_03_VIDEO");
                anchors.margins: 1;
                ExtraAnchors.horizontalFill: parent;
                Container.forcedHeight: (Theme.itemSizeHuge * 2);

                SilicaGridView {
                    clip: true;
                    cellWidth: (width / 4);
                    cellHeight: cellWidth;
                    quickScroll: true;
                    anchors.fill: parent;
                    model: DocumentGalleryModel {
                        id: galleryModelVideo;
                        rootType: DocumentGallery.Video;
                        properties: ["url", "filePath", "dateTaken", "mimeType", "width", "height", "duration"];
                        autoUpdate: true;
                        sortProperties: ["-dateTaken"];
                    }
                    delegate: MouseArea {
                        id: delegateVideoSelect;
                        implicitWidth: GridView.view.cellWidth;
                        implicitHeight: GridView.view.cellHeight;
                        onClicked: {
                            if (selected) {
                                TD_Global.deselectVideo (model.filePath);
                            }
                            else {
                                TD_Global.selectVideo (model.filePath, model.width, model.height, model.duration);
                            }
                        }

                        readonly property bool selected : (TD_Global.selectedVideosCount > 0 && TD_Global.isVideoSelected (model.filePath));

                        Rectangle {
                            color: Theme.secondaryColor;
                            anchors.fill: parent;
                            anchors.margins: 1;

                            Thumbnail {
                                source: model.url;
                                mimeType: model.mimeType;
                                fillMode: Thumbnail.PreserveAspectCrop;
                                sourceSize: Qt.size (width, height);
                                anchors.fill: parent;
                            }
                            Rectangle {
                                color: "transparent";
                                visible: delegateVideoSelect.selected;
                                border {
                                    width: 3;
                                    color: Theme.highlightColor;
                                }
                                anchors.fill: parent;
                            }
                            Image {
                                source: "image://theme/icon-m-video?#808080";
                                sourceSize: Qt.size (Theme.iconSizeSmall, Theme.iconSizeSmall);
                                anchors.margins: Theme.paddingSmall;
                                ExtraAnchors.bottomLeftCorner: parent;
                            }
                            Label {
                                text: TD_Global.formatTime (model.duration * 1000, true);
                                color: "gray";
                                font.pixelSize: Theme.fontSizeExtraSmall;
                                anchors.margins: Theme.paddingSmall;
                                ExtraAnchors.bottomRightCorner: parent;
                            }
                        }
                    }

                    VerticalScrollDecorator { flickable: parent; }
                }
            }
            RowContainer {
                visible: (currentMsgType === "MSGTYPE_07_VOICE");
                spacing: Theme.paddingMedium;
                anchors.margins: Theme.paddingSmall;
                Container.forcedHeight: (implicitHeight + anchors.margins * 2);
                ExtraAnchors.horizontalFill: parent;

                RectangleButton {
                    id: btnRecord;
                    icon: "icon-m-call-recording-on";
                    enabled: !btnReplay.active;
                    anchors.verticalCenter: parent.verticalCenter;
                    onPressed: {
                        active = TD_Global.startRecordingAudio ();
                        if (active) {
                            currentRecording = "";
                        }
                        console.log ("RECORDING STARTED", active);
                    }
                    onReleased: {
                        if (active) {
                            active = false;
                            currentRecording = TD_Global.stopRecordingAudio ();
                            console.log ("RECORDING STOPPED", currentRecording);
                        }
                    }
                }
                RectangleButton {
                    id: btnReplay;
                    icon: "icon-m-play";
                    active: (playerRecording.playbackState === MediaPlayer.PlayingState);
                    enabled: (currentRecording !== "");
                    anchors.verticalCenter: parent.verticalCenter;
                    onClicked: {
                        if (playerRecording.playbackState !== MediaPlayer.PlayingState) {
                            playerRecording.source = TD_Global.urlFromLocalPath (currentRecording);
                            playerRecording.seek (0);
                            playerRecording.play ();
                        }
                        else {
                            playerRecording.stop ();
                            playerRecording.source = "";
                        }
                    }

                    MediaPlayer {
                        id: playerRecording;
                        autoLoad: true;
                        autoPlay: true;
                    }
                }
                Label {
                    text: (btnRecord.active
                           ? qsTr ("Recording (%1)").arg (TD_Global.formatTime (TD_Global.recordingDuration, false))
                           : (currentRecording !== ""
                              ? ((playerRecording.playbackState === MediaPlayer.PlayingState)
                                 ? qsTr ("Replaying (%1/%2)").arg (TD_Global.formatTime (playerRecording.position, false)).arg (TD_Global.formatTime (playerRecording.duration, false))
                                 : qsTr ("Send recording (%1)").arg (TD_Global.formatTime (TD_Global.recordingDuration, false)))
                              : qsTr ("Idle")));
                    color: ((btnRecord.active || btnReplay.active)
                            ? Theme.highlightColor
                            : (currentRecording !== ""
                               ? Theme.primaryColor
                               : Theme.secondaryColor));
                    anchors.verticalCenter: parent.verticalCenter;
                    Container.horizontalStretch: 1;
                }
                RectangleButton {
                    icon: "icon-m-enter";
                    size: Theme.iconSizeMedium;
                    enabled: (currentRecording !== "" && !btnRecord.active && !btnReplay.active);
                    implicitWidth: Theme.itemSizeSmall;
                    implicitHeight: Theme.itemSizeSmall;
                    anchors.verticalCenter: parent.verticalCenter;
                    onClicked: {
                        TD_Global.sendMessageVoiceNote (currentChat, currentRecording);
                        currentRecording = "";
                    }
                }
            }
            GridContainer {
                id: selectorMsgType;
                cols: capacity;
                capacity: repeaterModes.count;
                horizontalSpacing: 1;
                ExtraAnchors.horizontalFill: parent;
                Container.forcedHeight: (Theme.itemSizeSmall * 0.85);

                Repeater {
                    id: repeaterModes;
                    model: Object.getOwnPropertyNames (msgTypes);
                    delegate: RectangleButton {
                        size: Theme.iconSizeMedium;
                        icon: msgTypes [modelData]["icon"];
                        active: (currentMsgType === modelData);
                        rounded: false;
                        onClicked: {
                            currentMsgType = modelData;
                        }
                    }
                }
            }
        }
    }
    MouseArea {
        id: headerChat;
        opacity: (pulleyTop.active ? 0.0 : 1.0);
        implicitHeight: (Math.max (headerIcon.height, headerText.height) + Theme.paddingMedium * 2);
        ExtraAnchors.topDock: parent;

        Rectangle {
            z: -2;
            color: "black";
            opacity: 0.65;
            anchors.fill: parent;
        }
        Rectangle {
            z: -1;
            color: Theme.primaryColor;
            opacity: 0.35;
            anchors.fill: parent;
        }
        Label {
            id: headerText;
            text: (currentChat ? currentChat.title : "");
            color: Theme.highlightColor;
            truncationMode: TruncationMode.Fade;
            horizontalAlignment: Text.AlignRight;
            font {
                family: Theme.fontFamilyHeading;
                pixelSize: Theme.fontSizeLarge;
            }
            anchors {
                left: parent.left;
                right: headerIcon.left;
                leftMargin: (Theme.paddingLarge * 2);
                rightMargin: Theme.paddingMedium;
                verticalCenter: parent.verticalCenter;
            }
        }
        DelegateDownloadableImage {
            id: headerIcon;
            size: Theme.iconSizeLarge;
            fileItem: (currentChat && currentChat.photo ? currentChat.photo.big : null);
            autoDownload: true;
            anchors {
                right: parent.right;
                rightMargin: Theme.paddingMedium;
                verticalCenter: parent.verticalCenter;
            }
        }
    }
}
