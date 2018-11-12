import QtQuick 2.6;
import QtMultimedia 5.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;
import "../components";

Page {
    id: page;
    allowedOrientations: Orientation.All;

    property TD_Chat currentChat : null;

    property TD_LocalFile currentMedia : null;

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
            readonly property TD_PhotoSize     photoSizeItem : (photoItem && photoItem.sizes.count > 0 ? photoItem.sizes.getLast () : null);

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
                    TD_Global.send ({
                                        "@type" : "downloadFile",
                                        "file_id" : fileItem.id,
                                        "priority" : 1,
                                    }); // START DOWNLOAD
                }
                else if (localFileItem.canBeDownloaded && localFileItem.isDownloadingActive && !localFileItem.isDownloadingCompleted) { // DOWNLOADING
                    // TODO : STOP DOWNLOAD ?
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

            readonly property TD_Video     videoItem     : (messageContentItem ? messageContentItem.video : null);
            readonly property TD_File      fileItem      : (videoItem          ? videoItem.video          : null);
            readonly property TD_LocalFile localFileItem : (fileItem           ? fileItem.local           : null);
            readonly property TD_PhotoSize photoSizeItem : (videoItem          ? videoItem.thumbnail      : null);

            Label {
                text: (delegateMsgVideo.captionItem ? delegateMsgVideo.captionItem.text : "");
                visible: (text !== "");
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                ExtraAnchors.horizontalFill: parent;
            }
            MouseArea {
                width: (delegateMsgVideo.videoItem ? Math.min (delegateMsgVideo.videoItem.width, delegateMsgVideo.width) : 1);
                Container.forcedHeight: (delegateMsgVideo.videoItem ? delegateMsgVideo.videoItem.height * width / delegateMsgVideo.videoItem.width : 1);
                onClicked: {
                    if (delegateMsgVideo.localFileItem) {
                        if (delegateMsgVideo.localFileItem.canBeDownloaded && !delegateMsgVideo.localFileItem.isDownloadingActive && !delegateMsgVideo.localFileItem.isDownloadingCompleted) {
                            TD_Global.send ({
                                                "@type" : "downloadFile",
                                                "file_id" : delegateMsgVideo.fileItem.id,
                                                "priority" : 1,
                                            }); // START DOWNLOAD
                        }
                        else if (delegateMsgVideo.localFileItem.isDownloadingCompleted) {
                            currentMedia = delegateMsgVideo.localFileItem;
                        }
                    }
                }

                DelegateDownloadableImage {
                    fileItem: (delegateMsgVideo.photoSizeItem ? delegateMsgVideo.photoSizeItem.photo : null);
                    anchors.fill: parent;
                }
                Image {
                    source: "image://theme/icon-m-play?#FFFFFF";
                    visible: (delegateMsgVideo.localFileItem && delegateMsgVideo.localFileItem.isDownloadingCompleted);
                    anchors.centerIn: parent;
                }
                Loader {
                    active: (currentMedia && delegateMsgVideo.localFileItem && currentMedia === delegateMsgVideo.localFileItem);
                    sourceComponent: Video {
                        id: playerVideo;
                        smooth: true;
                        source: (delegateMsgVideo.localFileItem && delegateMsgVideo.localFileItem.path !== ""
                                 ? TD_Global.urlFromLocalPath (delegateMsgVideo.localFileItem.path)
                                 : "");
                        autoLoad: true;
                        autoPlay: true;
                        fillMode: VideoOutput.PreserveAspectFit;
                        antialiasing: true;
                        anchors.fill: parent;

                        Image {
                            source: "image://theme/icon-m-play?#FFFFFF";
                            visible: (playerVideo.playbackState !== MediaPlayer.PlayingState);
                            anchors.centerIn: parent;
                        }
                        MouseArea {
                            anchors.fill: parent;
                            onClicked: {
                                if (playerVideo.playbackState === MediaPlayer.PlayingState) {
                                    playerVideo.pause ();
                                }
                                else {
                                    playerVideo.play ();
                                }
                            }
                        }
                        Rectangle {
                            color: Theme.highlightColor;
                            implicitWidth: (playerVideo.duration > 0 ? parent.width * playerVideo.position / playerVideo.duration : 0);
                            implicitHeight: Theme.paddingSmall;
                            ExtraAnchors.bottomLeftCorner: parent;
                        }
                    }
                    anchors.fill: parent;
                }
                Image {
                    source: "image://theme/icon-m-cloud-download?#FFFFFF";
                    visible: (delegateMsgVideo.localFileItem &&
                              delegateMsgVideo.localFileItem.canBeDownloaded &&
                              !delegateMsgVideo.localFileItem.isDownloadingActive &&
                              !delegateMsgVideo.localFileItem.isDownloadingCompleted);
                    anchors.centerIn: parent;
                }
                ProgressCircle {
                    value: (delegateMsgVideo.localFileItem ? delegateMsgVideo.localFileItem.downloadedSize / Math.max (delegateMsgVideo.fileItem.size, 1) : 0);
                    visible: (delegateMsgVideo.localFileItem && delegateMsgVideo.localFileItem.isDownloadingActive);
                    implicitWidth: BusyIndicatorSize.Large;
                    implicitHeight: BusyIndicatorSize.Large;
                    anchors.centerIn: parent;
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
                                TD_Global.send ({
                                                    "@type" : "downloadFile",
                                                    "file_id" : delegateMsgAudio.fileItem.id,
                                                    "priority" : 1,
                                                }); // START DOWNLOAD
                            }
                            else if (delegateMsgAudio.localFileItem.isDownloadingCompleted) {
                                currentMedia = delegateMsgAudio.localFileItem;
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
                        visible: (currentMedia !== delegateMsgAudio.localFileItem && delegateMsgAudio.localFileItem.isDownloadingCompleted);
                        anchors.centerIn: parent;
                    }
                    Loader {
                        active: (currentMedia && delegateMsgAudio.localFileItem && currentMedia === delegateMsgAudio.localFileItem);
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
                                target: lblAudioTime;
                                property: "remaining";
                                value: (playerAudio.duration - playerAudio.position);
                            }
                            Binding {
                                target: lblAudioTime;
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
                    id: lblAudioTime;
                    text: (delegateMsgAudio.audioItem
                           ? (playing
                              ? ("-" + TD_Global.formatTime ((remaining), false))
                              : TD_Global.formatTime ((delegateMsgAudio.audioItem.duration * 1000), false))
                           : "");
                    color: Theme.secondaryColor;
                    font.pixelSize: Theme.fontSizeSmall;
                    anchors.verticalCenter: parent.verticalCenter;

                    property int  remaining : 0;
                    property bool playing   : false;
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
                    TD_Global.send ({
                                        "@type" : "downloadFile",
                                        "file_id" : fileItem.id,
                                        "priority" : 1,
                                    });
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
            id: pulley;

            MenuItem {
                text: qsTr ("Load 50 older messages...");
                onClicked: {
                    TD_Global.send ({
                                        "@type" : "getChatHistory",
                                        "chat_id" :  currentChat.id,
                                        "from_message_id" : currentChat.messagesModel.getFirst ().id, // Identifier of the message starting from which history must be fetched; use 0 to get results from the begining
                                        "offset" : 0, // Specify 0 to get results from exactly the from_message_id or a negative offset to get the specified message and some newer messages
                                        "limit" : 50, // The maximum number of messages to be returned; must be positive and can't be greater than 100. If the offset is negative, the limit must be greater than -offset. Fewer messages may be returned than specified by the limit, even if the end of the message history has not been reached
                                        "only_local" : false, // If true, returns only messages that are available locally without sending network requests
                                    });
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
                    implicitHeight: (layoutMsg.height + layoutMsg.anchors.margins * 2);
                    anchors {
                        leftMargin: (delegateMsg.messageItem.isOutgoing ? Theme.paddingLarge * 5 : Theme.paddingMedium);
                        rightMargin: (!delegateMsg.messageItem.isOutgoing ? Theme.paddingLarge * 5 : Theme.paddingMedium);
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
                            spacing: Theme.paddingSmall;
                            Container.horizontalStretch: 1;

                            Label {
                                text: (delegateMsg.userItem ? delegateMsg.userItem.firstName + " " + delegateMsg.userItem.lastName : "");
                                color: Theme.highlightColor;
                                ExtraAnchors.horizontalFill: parent;
                            }
                            Loader {
                                id: loaderMsgContent;
                                sourceComponent: {
                                    if (messageItem && messageItem.content) {
                                        switch (messageItem.content.typeOf) {
                                        case TD_ObjectType.MESSAGE_TEXT:      return compoMsgText;
                                        case TD_ObjectType.MESSAGE_PHOTO:     return compoMsgPhoto;
                                        case TD_ObjectType.MESSAGE_DOCUMENT:  return compoMsgDocument;
                                        case TD_ObjectType.MESSAGE_STICKER:   return compoMsgSticker;
                                        case TD_ObjectType.MESSAGE_VIDEO:     return compoMsgVideo;
                                        case TD_ObjectType.MESSAGE_AUDIO:     return compoMsgAudio;
                                        case TD_ObjectType.MESSAGE_ANIMATION: return compoMsgAnimation;
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
    }
    MouseArea {
        id: headerChat;
        opacity: (pulley.active ? 0.0 : 1.0);
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
