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

    property TD_StickerSet currentStickerSet : (TD_Global.stickerSetsList.count > 0 ? TD_Global.stickerSetsList.getFirst () : null);

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
                autoDownload: true;
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

            HelperFileState {
                id: helperMsgDocumentFile;
                fileItem: (delegateMsgDocument.documentItem ? delegateMsgDocument.documentItem.document : null);
                autoDownload: false;
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
                        if (helperMsgDocumentFile.uploading) {
                            // NOTHING WE CAN DO
                        }
                        else {
                            if (helperMsgDocumentFile.downloaded) {
                                Qt.openUrlExternally (helperMsgDocumentFile.url);
                            }
                            else {
                                if (helperMsgDocumentFile.downloadable) {
                                    if (helperMsgDocumentFile.downloading) {
                                        helperMsgDocumentFile.cancelDownload ();
                                    }
                                    else {
                                        helperMsgDocumentFile.tryDownload (true);
                                    }
                                }
                            }
                        }
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
                        text: ((helperMsgDocumentFile.downloading || helperMsgDocumentFile.uploading)
                               ? "(%1 / %2)".arg (TD_Global.formatSize (helperMsgDocumentFile.currentSize)).arg (TD_Global.formatSize (helperMsgDocumentFile.totalSize))
                               : "(%1)".arg (TD_Global.formatSize (helperMsgDocumentFile.totalSize)));
                        color: Theme.secondaryColor;
                        font.pixelSize: Theme.fontSizeSmall;

                        BusyIndicator {
                            size: BusyIndicatorSize.ExtraSmall;
                            running: (helperMsgDocumentFile.downloading || helperMsgDocumentFile.uploading);
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
                text: (helperMsgDocumentFile.downloading
                       ? qsTr ("Downloading, please wait...")
                       : (helperMsgDocumentFile.uploading
                          ? qsTr ("Uploading, please wait...")
                          : (helperMsgDocumentFile.downloaded
                             ? qsTr ("Downloaded, click to open")
                             : qsTr ("Click to download"))));
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

        ColumnContainer {
            id: delegateMsgSticker;

            property TD_MessageSticker messageContentItem : null;

            readonly property TD_Sticker stickerItem : (messageContentItem ? messageContentItem.sticker : null);

            readonly property int size : (page.width * 0.35);

            HelperFileState {
                id: helperMsgStickerFile;
                fileItem: (delegateMsgSticker.stickerItem ? delegateMsgSticker.stickerItem.sticker : null);
                autoDownload: true;
            }
            Item {
                implicitWidth: (delegateMsgSticker.stickerItem
                                ? ((delegateMsgSticker.stickerItem.width > delegateMsgSticker.stickerItem.height)
                                   ? delegateMsgSticker.size
                                   : (delegateMsgSticker.stickerItem.width * delegateMsgSticker.size / delegateMsgSticker.stickerItem.height))
                                : 0);
                implicitHeight: (delegateMsgSticker.stickerItem
                                 ? ((delegateMsgSticker.stickerItem.height > delegateMsgSticker.stickerItem.width)
                                    ? delegateMsgSticker.size
                                    : (delegateMsgSticker.stickerItem.height * delegateMsgSticker.size / delegateMsgSticker.stickerItem.width))
                                 : 0);

                Image {
                    cache: true;
                    source: helperMsgStickerFile.url;
                    sourceSize: Qt.size (width, height);
                    asynchronous: true;
                    anchors.fill: parent;
                }

                Image {
                    source: ((helperMsgStickerFile.downloadable && !helperMsgStickerFile.downloading && !helper.downloaded)
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
                fileItem: (delegateMsgVideo.videoItem ? delegateMsgVideo.videoItem.video : null);
                autoDownload: false;
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
                        if (helperMsgVideoFile.uploading) {
                            // NOTHING WE CAN DO
                        }
                        else {
                            if (helperMsgVideoFile.downloaded) {
                                if (currentMessageContent === delegateMsgVideo.messageContentItem) {
                                    if (playerVideo.playing) {
                                        playerVideo.pause ();
                                    }
                                    else {
                                        playerVideo.play ();
                                    }
                                }
                                else {
                                    currentMessageContent = delegateMsgVideo.messageContentItem;
                                }
                            }
                            else {
                                if (helperMsgVideoFile.downloadable) {
                                    if (helperMsgVideoFile.downloading) {
                                        helperMsgVideoFile.cancelDownload ();
                                    }
                                    else {
                                        helperMsgVideoFile.tryDownload (true);
                                    }
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
                        sourceSize: Qt.size (Theme.iconSizeMedium, Theme.iconSizeMedium);
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
            readonly property TD_PhotoSize photoSizeItem : (audioItem          ? audioItem.albumCoverThumbnail : null);

            HelperFileState {
                id: helperMsgAudioFile;
                fileItem: (delegateMsgAudio.audioItem ? delegateMsgAudio.audioItem.audio : null);
                autoDownload: false;
            }
            WrapperAudioPlayer {
                id: playerAudio;
                source: helperMsgAudioFile.url;
                active: (currentMessageContent && delegateMsgAudio.messageContentItem && currentMessageContent === delegateMsgAudio.messageContentItem);
                autoLoad: true;
                autoPlay: true;
            }
            Label {
                text: (delegateMsgAudio.audioItem ? delegateMsgAudio.audioItem.fileName : "");
                elide: Text.ElideRight;
                font.pixelSize: Theme.fontSizeSmall;
                ExtraAnchors.horizontalFill: parent;
            }
            Label {
                text: (delegateMsgAudio.audioItem ? delegateMsgAudio.audioItem.title : "");
                visible: (text !== "");
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                font.bold: true;
                ExtraAnchors.horizontalFill: parent;
            }
            Label {
                text: (delegateMsgAudio.audioItem ? delegateMsgAudio.audioItem.performer : "");
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
                            if (helperMsgAudioFile.uploading) {
                                // NOTHING WE CAN DO
                            }
                            else {
                                if (helperMsgAudioFile.downloaded) {
                                    if (currentMessageContent === delegateMsgAudio.messageContentItem) {
                                        if (playerAudio.playing) {
                                            playerAudio.pause ();
                                        }
                                        else {
                                            playerAudio.play ();
                                        }
                                    }
                                    else {
                                        currentMessageContent = delegateMsgAudio.messageContentItem;
                                    }
                                }
                                else {
                                    if (helperMsgAudioFile.downloadable) {
                                        if (helperMsgAudioFile.downloading) {
                                            helperMsgAudioFile.cancelDownload ();
                                        }
                                        else {
                                            helperMsgAudioFile.tryDownload (true);
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
                            fileItem: (delegateMsgAudio.photoSizeItem ? delegateMsgAudio.photoSizeItem.photo : null);
                            background: false;
                            autoDownload: true;
                            anchors.fill: parent;
                        }
                        Image {
                            source: ((helperMsgAudioFile.downloadable && !helperMsgAudioFile.downloading && !helperMsgAudioFile.downloaded)
                                     ? "image://theme/icon-m-cloud-download?#808080"
                                     : ((helperMsgAudioFile.downloaded && !playerAudio.playing)
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
                            implicitWidth: (parent.width * playerAudio.progress);
                            ExtraAnchors.leftDock: parent;
                        }
                    }
                }
                Label {
                    text: (delegateMsgAudio.audioItem
                           ? (playerAudio.playing
                              ? ("-" + TD_Global.formatTime (playerAudio.remaining, false))
                              : TD_Global.formatTime ((delegateMsgAudio.audioItem.duration * 1000), false))
                           : "--:--");
                    color: (playerAudio.playing ? Theme.highlightColor : Theme.secondaryColor);
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

            property TD_MessageAnimation messageContentItem : null;

            property bool paused : true;

            readonly property TD_FormattedText captionItem   : (messageContentItem ? messageContentItem.caption   : null);
            readonly property TD_Animation     animationItem : (messageContentItem ? messageContentItem.animation : null);
            readonly property TD_PhotoSize     photoSizeItem : (animationItem      ? animationItem.thumbnail      : null);

            HelperFileState {
                id: helperMsgAnimationFile;
                fileItem: (delegateMsgAnimation.animationItem ? delegateMsgAnimation.animationItem.animation : null);
                autoDownload: true;
            }
            Item {
                id: placeholderAnim;
                implicitWidth: (delegateMsgAnimation.animationItem ? Math.min (delegateMsgAnimation.animationItem.width, delegateMsgAnimation.width) : 1);
                implicitHeight: (delegateMsgAnimation.animationItem ? delegateMsgAnimation.animationItem.height * implicitWidth / delegateMsgAnimation.animationItem.width : 1);
                ExtraAnchors.topLeftCorner: parent;

                DelegateDownloadableImage {
                    fileItem: (delegateMsgAnimation.photoSizeItem ? delegateMsgAnimation.photoSizeItem.photo : null);
                    autoDownload: true;
                    anchors.fill: parent;
                }
                MouseArea {
                    anchors.fill: parent;
                    onClicked: { delegateMsgAnimation.paused = !delegateMsgAnimation.paused; }
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
                Image {
                    source: ((!helperMsgAnimationFile.downloaded && !helperMsgAnimationFile.downloading && helperMsgAnimationFile.downloadable)
                             ? "image://theme/icon-m-cloud-download?#808080"
                             : ((helperMsgAnimationFile.downloaded && delegateMsgAnimation.paused)
                                ? "image://theme/icon-m-play?#808080"
                                : ""));
                    sourceSize: Qt.size (Theme.iconSizeMedium, Theme.iconSizeMedium);
                    anchors.centerIn: parent;
                }
                ProgressCircle {
                    value: helperMsgAnimationFile.progress;
                    visible: (helperMsgAnimationFile.downloading || helperMsgAnimationFile.uploading);
                    implicitWidth: BusyIndicatorSize.Medium;
                    implicitHeight: BusyIndicatorSize.Medium;
                    anchors.centerIn: parent;
                }
            }
            Component {
                id: compoAnimationGif;

                AnimatedImage {
                    cache: true;
                    paused: delegateMsgAnimation.paused;
                    smooth: true;
                    mipmap: true;
                    source: helperMsgAnimationFile.url;
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
                    source: helperMsgAnimationFile.url;
                    active: !delegateMsgAnimation.paused;
                    autoLoad: true;
                    autoPlay: true;
                    anchors.fill: parent;
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

            HelperFileState {
                id: helperMsgVoiceNoteFile;
                fileItem: (delegateMsgVoiceNote.voiceNoteItem ? delegateMsgVoiceNote.voiceNoteItem.voice : null);
                autoDownload: false;
            }
            WrapperAudioPlayer {
                id: playerVoiceNote;
                source: helperMsgVoiceNoteFile.url;
                active: (currentMessageContent && delegateMsgVoiceNote.messageContentItem && currentMessageContent === delegateMsgVoiceNote.messageContentItem);
                autoLoad: true;
                autoPlay: true;
            }
            Label {
                text: (delegateMsgVoiceNote.captionItem ? delegateMsgVoiceNote.captionItem.text : "");
                visible: (text !== "");
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                ExtraAnchors.horizontalFill: parent;
            }
            RowContainer {
                spacing: Theme.paddingMedium;
                ExtraAnchors.horizontalFill: parent;

                RectangleButton {
                    icon: ((helperMsgVoiceNoteFile.downloadable && !helperMsgVoiceNoteFile.downloading && !helperMsgVoiceNoteFile.downloaded)
                           ? "icon-m-cloud-download"
                           : ((helperMsgVoiceNoteFile.downloaded && !playerVoiceNote.playing)
                              ? "icon-m-play"
                              : "icon-m-pause"));
                    size: Theme.iconSizeMedium;
                    active: playerVoiceNote.playing;
                    implicitWidth: Theme.itemSizeMedium;
                    implicitHeight: Theme.itemSizeMedium;
                    anchors.verticalCenter: parent.verticalCenter;
                    onClicked: {
                        if (helperMsgVoiceNoteFile.uploading) {
                            // NOTHING WE CAN DO
                        }
                        else {
                            if (helperMsgVoiceNoteFile.downloaded) {
                                if (currentMessageContent === delegateMsgVoiceNote.messageContentItem) {
                                    if (playerVoiceNote.playing) {
                                        playerVoiceNote.pause ();
                                    }
                                    else {
                                        playerVoiceNote.play ();
                                    }
                                }
                                else {
                                    currentMessageContent = delegateMsgVoiceNote.messageContentItem;
                                }
                            }
                            else {
                                if (helperMsgVoiceNoteFile.downloadable) {
                                    if (helperMsgVoiceNoteFile.downloading) {
                                        helperMsgVoiceNoteFile.cancelDownload ();
                                    }
                                    else {
                                        helperMsgVoiceNoteFile.tryDownload (true);
                                    }
                                }
                            }
                        }
                    }

                    ProgressCircle {
                        value: helperMsgVoiceNoteFile.progress;
                        visible: (helperMsgVoiceNoteFile.downloading || helperMsgVoiceNoteFile.uploading);
                        implicitWidth: BusyIndicatorSize.Medium;
                        implicitHeight: BusyIndicatorSize.Medium;
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
                                playerVoiceNote.seek (Math.round (playerVoiceNote.duration * mouse.x / width));
                            }
                        }
                        Repeater {
                            model: (delegateMsgVoiceNote.voiceNoteItem && delegateMsgVoiceNote.voiceNoteItem.waveform !== ""
                                    ? TD_Global.parseWaveform (delegateMsgVoiceNote.voiceNoteItem.waveform)
                                    : 0);
                            delegate: Rectangle {
                                color: ((model.index / 100) <= playerVoiceNote.progress ? Theme.highlightColor : Theme.secondaryColor);
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
                                implicitWidth: (parent.width * playerVoiceNote.progress);
                                ExtraAnchors.leftDock: parent;
                            }
                        }
                    }
                    Label {
                        text: (delegateMsgVoiceNote.voiceNoteItem
                               ?  (playerVoiceNote.playing
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
                               ? (playerVoiceNote.playing
                                  ? ("-" + TD_Global.formatTime (playerVoiceNote.remaining, false))
                                  : TD_Global.formatTime ((delegateMsgVoiceNote.voiceNoteItem.duration * 1000), false))
                               : "--:--");
                        color: (playerVoiceNote.playing ? Theme.highlightColor : Theme.primaryColor);
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

        Rectangle {
            color: Qt.rgba (1.0 - Theme.primaryColor.r, 1.0 - Theme.primaryColor.g, 1.0 - Theme.primaryColor.b, 0.85);
            anchors.fill: parent;
        }
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
            SilicaGridView {
                clip: true;
                model: (currentStickerSet ? currentStickerSet.stickers : 0);
                visible: (currentMsgType === "MSGTYPE_05_STICKER");
                cellWidth: (width / Math.floor (width / (Theme.iconSizeLarge + Theme.paddingSmall * 2)));
                cellHeight: cellWidth;
                quickScroll: true;
                delegate: MouseArea {
                    id: delegateSelectorSticker;
                    implicitWidth: GridView.view.cellWidth;
                    implicitHeight: GridView.view.cellHeight;
                    onClicked: {
                        TD_Global.sendMessageSticker (currentChat, stickerItem);
                        flickerMessages.autoMoveMode = flickerMessages.stayAtBottom;
                    }

                    readonly property TD_Sticker stickerItem : modelData;

                    HelperFileState {
                        id: helperSelectorStickerFile;
                        fileItem: (delegateSelectorSticker.stickerItem ? delegateSelectorSticker.stickerItem.sticker : null);
                        autoDownload: true;
                    }
                    Image {
                        cache: true;
                        source: helperSelectorStickerFile.url;
                        fillMode: Image.PreserveAspectFit;
                        sourceSize: Qt.size (Theme.iconSizeLarge, Theme.iconSizeLarge);
                        asynchronous: true;
                        verticalAlignment: Image.AlignVCenter;
                        horizontalAlignment: Image.AlignHCenter;
                        anchors.centerIn: parent;
                    }
                    ProgressCircle {
                        value: helperSelectorStickerFile.progress;
                        visible: helperSelectorStickerFile.downloading;
                        implicitWidth: BusyIndicatorSize.Medium;
                        implicitHeight: BusyIndicatorSize.Medium;
                        anchors.centerIn: parent;
                    }
                }
                ExtraAnchors.horizontalFill: parent;
                Container.forcedHeight: (Theme.itemSizeHuge * 1.65);
            }
            ListView {
                model: TD_Global.stickerSetsList;
                spacing: 1;
                visible: (currentMsgType === "MSGTYPE_05_STICKER");
                orientation: ListView.Horizontal;
                delegate: MouseArea {
                    id: delegateSelectorStickerSet;
                    implicitWidth: height;
                    ExtraAnchors.verticalFill: parent;
                    onClicked: {
                        currentStickerSet = stickerSetItem;
                    }

                    readonly property TD_StickerSet stickerSetItem : modelData;
                    readonly property TD_Sticker    coverItem      : (stickerSetItem && stickerSetItem.covers.count >= 1 ? stickerSetItem.covers.getFirst () : null);

                    readonly property bool active : (currentStickerSet === stickerSetItem);

                    HelperFileState {
                        id: helperSelectorStickerSetFile;
                        fileItem: (delegateSelectorStickerSet.coverItem ? delegateSelectorStickerSet.coverItem.sticker : null);
                        autoDownload: true;
                    }
                    Rectangle {
                        color: (delegateSelectorStickerSet.active || pressed ? Theme.highlightColor : Theme.primaryColor);
                        opacity: (delegateSelectorStickerSet.active ? 0.35 : 0.15);
                        anchors.fill: parent;
                    }
                    Image {
                        cache: true;
                        source: helperSelectorStickerSetFile.url;
                        fillMode: Image.PreserveAspectFit;
                        sourceSize: Qt.size (Theme.iconSizeMedium * 0.85, Theme.iconSizeMedium * 0.85);
                        asynchronous: true;
                        verticalAlignment: Image.AlignVCenter;
                        horizontalAlignment: Image.AlignHCenter;
                        anchors.centerIn: parent;
                    }
                    ProgressCircle {
                        value: helperSelectorStickerSetFile.progress;
                        visible: helperSelectorStickerSetFile.downloading;
                        implicitWidth: BusyIndicatorSize.Small;
                        implicitHeight: BusyIndicatorSize.Small;
                        anchors.centerIn: parent;
                    }
                }
                ExtraAnchors.horizontalFill: parent;
                Container.forcedHeight: (Theme.iconSizeMedium * 1.15);
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

        Behavior on opacity { NumberAnimation { duration: 150; } }
        Rectangle {
            color: Qt.rgba (1.0 - Theme.primaryColor.r, 1.0 - Theme.primaryColor.g, 1.0 - Theme.primaryColor.b, 0.85);
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
