import QtQuick 2.6;
import QtMultimedia 5.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import Qt.labs.folderlistmodel 2.1;
import QtDocGallery 5.0;
import Nemo.Thumbnailer 1.0;
import Nemo.Notifications 1.0;
import Nemo.Configuration 1.0;
import harbour.Telegrame 1.0;
import "cover";
import "pages";
import "components";

ApplicationWindow {
    id: window;
    cover: compoPageCover;
    initialPage: compoPageMain;
    allowedOrientations: Orientation.All;
    onActiveChanged: {
        TD_Global.setUserOnlineState (active);
    }
    Component.onCompleted: {
        TD_Global.setUserOnlineState (true);
    }
    Component.onDestruction: {
        TD_Global.setUserOnlineState (false);
    }

    property int currentMsgType : TD_ObjectType.MESSAGE_TEXT;

    property bool showInputPanel : false;

    property string currentRecording : "";

    property TD_StickerSet currentStickerSet : (TD_Global.stickerSetsList.count > 0 ? TD_Global.stickerSetsList.getFirst () : null);

    property alias groupImagesInAlbums            : configGroupImagesInAlbum.value;
    property alias groupVideosInAlbums            : configGroupVideosInAlbum.value;
    property alias sendTextMsgOnEnterKey          : configSendTextMsgOnEnterKey.value;
    property alias includeMutedChatsInUnreadCount : configIncludeMutedChatsInUnreadCount.value;

    readonly property bool active      : (Qt.application.state === Qt.ApplicationActive);
    readonly property bool isPortrait  : (window.orientation === Orientation.Portrait || window.orientation === Orientation.PortraitInverted);
    readonly property bool isLandscape : (window.orientation === Orientation.Landscape || window.orientation === Orientation.LandscapeInverted);

    Connections {
        target: TD_Global;
        onShowChatRequested: {
            if (chatItem) {
                console.log ("DISPLAY REQUESTED", chatItem.id);
                window.activate ();
                while (pageStack.depth > 1) {
                    pageStack.navigateBack (PageStackAction.Immediate);
                }
                pageStack.push (compoPageChat, {
                                    "currentChat" : chatItem,
                                },
                                PageStackAction.Immediate);
            }
        }
    }
    ConfigurationValue {
        id: configGroupImagesInAlbum;
        key: "/apps/telegrame/group_images_in_album";
        defaultValue: true;
    }
    ConfigurationValue {
        id: configGroupVideosInAlbum;
        key: "/apps/telegrame/group_videos_in_album";
        defaultValue: true;
    }
    ConfigurationValue {
        id: configSendTextMsgOnEnterKey;
        key: "/apps/telegrame/send_text_msg_on_enter_key";
        defaultValue: false;
    }
    ConfigurationValue {
        id: configIncludeMutedChatsInUnreadCount;
        key: "/apps/telegrame/include_muted_chats_in_unread_count";
        defaultValue: false;
    }
    Item {
        rotation: {
            switch (window.orientation) {
            case Orientation.Portrait:          return 0;
            case Orientation.Landscape:         return 90;
            case Orientation.PortraitInverted:  return 180;
            case Orientation.LandscapeInverted: return 270;
            }
            return 0;
        }
        implicitWidth: (rotation % 180 !== 0 ? parent.height : parent.width);
        implicitHeight: (rotation % 180 !== 0 ? parent.width : parent.height);
        anchors.centerIn: parent;

        MouseArea {
            id: footerChat;
            visible: enabled;
            enabled: showInputPanel;
            opacity: (enabled ? 1.0 : 0.0);
            implicitHeight: (layoutFooter.height + layoutFooter.anchors.margins * 2);
            ExtraAnchors.bottomDock: parent;
            onPressed: { }
            onReleased: { }

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
                    visible: (currentMsgType === TD_ObjectType.MESSAGE_TEXT);
                    anchors.margins: Theme.paddingSmall;
                    ExtraAnchors.horizontalFill: parent;
                    Container.forcedHeight: (implicitHeight + anchors.margins * 2);
                    onVisibleChanged: {
                        if (!visible && btnSendMsgText.textBox.activeFocus) {
                            btnSendMsgText.textBox.focus = false;
                        }
                    }

                    Item {
                        implicitHeight: Math.min (btnSendMsgText.textBox.implicitHeight, Theme.itemSizeLarge * 2);
                        anchors.bottom: parent.bottom;
                        anchors.margins: Theme.paddingSmall;
                        Container.horizontalStretch: 1;

                        TextField {
                            id: inputMsgSingle;
                            visible: sendTextMsgOnEnterKey;
                            labelVisible: false;
                            placeholderText: qsTr ("Text message");
                            anchors.fill: parent;
                            Keys.onReturnPressed: {
                                btnSendMsgText.execute ();
                            }
                        }
                        TextArea {
                            id: inputMsg;
                            visible: !sendTextMsgOnEnterKey;
                            labelVisible: false;
                            placeholderText: qsTr ("Text message");
                            autoScrollEnabled: true;
                            anchors.fill: parent;
                        }
                    }
                    RectangleButton {
                        id: btnSendMsgText;
                        icon: "icon-m-enter";
                        size: (Theme.iconSizeMedium * 0.65);
                        enabled: (textBox.text.trim () !== "");
                        implicitWidth: Theme.itemSizeExtraSmall;
                        implicitHeight: Theme.itemSizeExtraSmall;
                        anchors.bottom: parent.bottom;
                        anchors.margins: Theme.paddingSmall;
                        onClicked: {
                            execute ();
                        }

                        readonly property Item textBox : (sendTextMsgOnEnterKey ? inputMsgSingle : inputMsg);

                        function execute () {
                            textBox.focus = false;
                            var tmp = textBox.text.trim ();
                            if (tmp !== "") {
                                TD_Global.sendMessageText (TD_Global.currentChat, tmp);
                                //TD_Global.autoScrollDownRequested (true);
                            }
                            textBox.text = "";
                        }
                    }
                }
                RowContainer {
                    visible: (currentMsgType === TD_ObjectType.MESSAGE_PHOTO);
                    spacing: Theme.paddingMedium;
                    anchors.margins: Theme.paddingSmall;
                    Container.forcedHeight: (implicitHeight + anchors.margins * 2);
                    ExtraAnchors.horizontalFill: parent;

                    LabelFixed {
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
                        active: groupImagesInAlbums;
                        size: (Theme.iconSizeMedium * 0.65);
                        implicitWidth: Theme.itemSizeExtraSmall;
                        implicitHeight: Theme.itemSizeExtraSmall;
                        anchors.verticalCenter: parent.verticalCenter;
                        onClicked: {
                            groupImagesInAlbums = !groupImagesInAlbums;
                        }
                    }
                    RectangleButton {
                        icon: "icon-m-enter";
                        enabled: (TD_Global.selectedPhotosCount > 0);
                        size: (Theme.iconSizeMedium * 0.65);
                        implicitWidth: Theme.itemSizeExtraSmall;
                        implicitHeight: Theme.itemSizeExtraSmall;
                        anchors.verticalCenter: parent.verticalCenter;
                        onClicked: {
                            if (TD_Global.selectedPhotosCount > 0) {
                                TD_Global.sendMessagePhoto (TD_Global.currentChat, groupImagesInAlbums);
                                TD_Global.unselectAllPhotos ();
                                //TD_Global.autoScrollDownRequested (true);
                            }
                        }
                    }
                }
                RowContainer {
                    visible: (currentMsgType === TD_ObjectType.MESSAGE_PHOTO);
                    anchors.margins: 1;
                    ExtraAnchors.horizontalFill: parent;
                    Container.forcedHeight: (isPortrait ? Theme.itemSizeHuge * 2 : Theme.itemSizeHuge * 1.35);

                    SilicaGridView {
                        clip: true;
                        cellWidth: (isPortrait ? width / 4 : width / 7);
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
                    visible: (currentMsgType === TD_ObjectType.MESSAGE_VIDEO);
                    spacing: Theme.paddingMedium;
                    anchors.margins: Theme.paddingSmall;
                    Container.forcedHeight: (implicitHeight + anchors.margins * 2);
                    ExtraAnchors.horizontalFill: parent;

                    LabelFixed {
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
                        active: groupVideosInAlbums;
                        size: (Theme.iconSizeMedium * 0.65);
                        implicitWidth: Theme.itemSizeExtraSmall;
                        implicitHeight: Theme.itemSizeExtraSmall;
                        anchors.verticalCenter: parent.verticalCenter;
                        onClicked: {
                            groupVideosInAlbums = !groupVideosInAlbums;
                        }
                    }
                    RectangleButton {
                        icon: "icon-m-enter";
                        enabled: (TD_Global.selectedVideosCount > 0);
                        size: (Theme.iconSizeMedium * 0.65);
                        implicitWidth: Theme.itemSizeExtraSmall;
                        implicitHeight: Theme.itemSizeExtraSmall;
                        anchors.verticalCenter: parent.verticalCenter;
                        onClicked: {
                            if (TD_Global.selectedVideosCount > 0) {
                                TD_Global.sendMessageVideo (TD_Global.currentChat, groupVideosInAlbums);
                                TD_Global.unselectAllVideos ();
                                //TD_Global.autoScrollDownRequested (true);
                            }
                        }
                    }
                }
                RowContainer {
                    visible: (currentMsgType === TD_ObjectType.MESSAGE_VIDEO);
                    anchors.margins: 1;
                    ExtraAnchors.horizontalFill: parent;
                    Container.forcedHeight: (isPortrait ? Theme.itemSizeHuge * 2 : Theme.itemSizeHuge * 1.35);

                    SilicaGridView {
                        clip: true;
                        cellWidth: (isPortrait ? width / 4 : width / 7);
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
                                    color: Qt.rgba (1.0 - Theme.primaryColor.r, 1.0 - Theme.primaryColor.g, 1.0 - Theme.primaryColor.b, 0.65);
                                    implicitHeight: (layoutVideoInfo.height + layoutVideoInfo.anchors.margins * 2);
                                    ExtraAnchors.bottomDock: parent;

                                    RowContainer {
                                        id: layoutVideoInfo;
                                        spacing: Theme.paddingMedium;
                                        anchors.margins: Theme.paddingSmall;
                                        ExtraAnchors.bottomDock: parent;

                                        Image {
                                            source: "image://theme/icon-m-video?%1".arg (Theme.primaryColor);
                                            sourceSize: Qt.size (Theme.iconSizeSmall, Theme.iconSizeSmall);
                                            anchors.verticalCenter: parent.verticalCenter;
                                        }
                                        LabelFixed {
                                            text: TD_Global.formatTime (model.duration * 1000, true);
                                            color: Theme.primaryColor;
                                            font.pixelSize: Theme.fontSizeExtraSmall;
                                            anchors.verticalCenter: parent.verticalCenter;
                                        }
                                    }
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
                            }
                        }

                        VerticalScrollDecorator { flickable: parent; }
                    }
                }
                SilicaGridView {
                    clip: true;
                    model: (currentStickerSet ? currentStickerSet.stickers : 0);
                    visible: (currentMsgType === TD_ObjectType.MESSAGE_STICKER);
                    cellWidth: (width / Math.floor (width / (Theme.iconSizeLarge + Theme.paddingSmall * 2)));
                    cellHeight: cellWidth;
                    quickScroll: true;
                    delegate: MouseArea {
                        id: delegateSelectorSticker;
                        implicitWidth: GridView.view.cellWidth;
                        implicitHeight: GridView.view.cellHeight;
                        onClicked: {
                            TD_Global.sendMessageSticker (TD_Global.currentChat, stickerItem);
                            //TD_Global.autoScrollDownRequested (true);
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
                    Container.forcedHeight: (isPortrait ? Theme.itemSizeHuge * 1.65 : Theme.itemSizeHuge * 1.15);
                }
                SilicaListView {
                    model: TD_Global.stickerSetsList;
                    spacing: 1;
                    visible: (currentMsgType === TD_ObjectType.MESSAGE_STICKER);
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
                    visible: (currentMsgType === TD_ObjectType.MESSAGE_DOCUMENT);
                    spacing: Theme.paddingMedium;
                    anchors.margins: Theme.paddingSmall;
                    Container.forcedHeight: (implicitHeight + anchors.margins * 2);
                    ExtraAnchors.horizontalFill: parent;

                    RectangleButton {
                        icon: "icon-m-back";
                        size: (Theme.iconSizeMedium * 0.65);
                        implicitWidth: Theme.itemSizeExtraSmall;
                        implicitHeight: Theme.itemSizeExtraSmall;
                        enabled: (modelDocuments.parentFolder !== "file:///");
                        anchors.verticalCenter: parent.verticalCenter;
                        onClicked: {
                            modelDocuments.folder = modelDocuments.parentFolder;
                        }
                    }
                    LabelFixed {
                        text: TD_Global.localPathFromUrl (modelDocuments.folder);
                        elide: Text.ElideLeft;
                        color: Theme.highlightColor;
                        font.pixelSize: Theme.fontSizeSmall;
                        anchors.verticalCenter: parent.verticalCenter;
                        Container.horizontalStretch: 1;
                    }
                }
                SilicaListView {
                    clip: true;
                    spacing: 1;
                    visible: (currentMsgType === TD_ObjectType.MESSAGE_DOCUMENT);
                    orientation: ListView.Vertical;
                    model: FolderListModel {
                        id: modelDocuments;
                        folder: "file:///home/nemo";
                        rootFolder: "file:///";
                        showDirs: true;
                        showDirsFirst: true;
                        showDotAndDotDot: false;
                        showFiles: true;
                        showHidden: false;
                        sortReversed: false;
                        sortField: FolderListModel.Name;
                    }
                    delegate: MouseArea {
                        id: delegateSelectorDocument;
                        implicitHeight: (layoutDocument.height + Theme.paddingSmall * 2);
                        ExtraAnchors.horizontalFill: parent;
                        onClicked: {
                            if (model.fileIsDir) {
                                modelDocuments.folder = model.fileURL;
                            }
                            else {
                                TD_Global.sendMessageDocument (TD_Global.currentChat, model.filePath);
                            }
                        }

                        Rectangle {
                            color: Theme.highlightColor;
                            opacity: 0.15;
                            visible: parent.pressed;
                            anchors.fill: parent;
                        }
                        RowContainer {
                            id: layoutDocument;
                            spacing: Theme.paddingMedium;
                            anchors {
                                margins: Theme.paddingMedium;
                                verticalCenter: parent.verticalCenter;
                            }
                            ExtraAnchors.horizontalFill: parent;

                            Image {
                                source: "qrc:///symbols/filetypes/%1.svg".arg (model.fileIsDir ? "folder-closed" : TD_Global.getSvgIconForMimeType (mimeType));
                                sourceSize: Qt.size (Theme.iconSizeMedium * 0.85, Theme.iconSizeMedium * 0.85);
                                anchors.verticalCenter: parent.verticalCenter;

                                readonly property string mimeType : TD_Global.getMimeTypeForPath (model.filePath);
                            }
                            ColumnContainer {
                                Container.horizontalStretch: 1;

                                LabelFixed {
                                    text: model.fileName;
                                    elide: Text.ElideMiddle;
                                    ExtraAnchors.horizontalFill: parent;
                                }
                                LabelFixed {
                                    text: TD_Global.formatSize (model.fileSize);
                                    color: Theme.secondaryColor;
                                    visible: !model.fileIsDir;
                                    font.pixelSize: Theme.fontSizeExtraSmall;
                                    ExtraAnchors.horizontalFill: parent;
                                }
                            }
                        }
                    }
                    ExtraAnchors.horizontalFill: parent;
                    Container.forcedHeight: (isPortrait ? Theme.iconSizeExtraLarge * 2 : Theme.iconSizeExtraLarge * 1.35);
                }
                RowContainer {
                    visible: (currentMsgType === TD_ObjectType.MESSAGE_VOICE_NOTE);
                    spacing: Theme.paddingMedium;
                    anchors.margins: Theme.paddingSmall;
                    Container.forcedHeight: (implicitHeight + anchors.margins * 2);
                    ExtraAnchors.horizontalFill: parent;

                    RectangleButton {
                        id: btnRecord;
                        icon: "icon-m-call-recording-on";
                        enabled: !btnReplay.active;
                        size: (Theme.iconSizeMedium * 0.65);
                        implicitWidth: Theme.itemSizeExtraSmall;
                        implicitHeight: Theme.itemSizeExtraSmall;
                        anchors.verticalCenter: parent.verticalCenter;
                        onPressed: {
                            active = TD_Global.startRecordingAudio ();
                            if (active) {
                                console.log ("RECORDING STARTED", active);
                                currentRecording = "";
                            }
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
                        size: (Theme.iconSizeMedium * 0.65);
                        implicitWidth: Theme.itemSizeExtraSmall;
                        implicitHeight: Theme.itemSizeExtraSmall;
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
                            onPlaybackStateChanged: {
                                if (playbackState === MediaPlayer.StoppedState) {
                                    source = "";
                                }
                            }
                        }
                    }
                    RectangleButton {
                        id: btnReset;
                        icon: "icon-m-delete";
                        enabled: (currentRecording !== "" && !btnRecord.active && !btnReplay.active);
                        size: (Theme.iconSizeMedium * 0.65);
                        implicitWidth: Theme.itemSizeExtraSmall;
                        implicitHeight: Theme.itemSizeExtraSmall;
                        anchors.verticalCenter: parent.verticalCenter;
                        onClicked: {
                            TD_Global.removeRecording (currentRecording);
                            currentRecording = "";
                        }
                    }
                    LabelFixed {
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
                        enabled: (currentRecording !== "" && !btnRecord.active && !btnReplay.active);
                        size: (Theme.iconSizeMedium * 0.65);
                        implicitWidth: Theme.itemSizeExtraSmall;
                        implicitHeight: Theme.itemSizeExtraSmall;
                        anchors.verticalCenter: parent.verticalCenter;
                        onClicked: {
                            TD_Global.sendMessageVoiceNote (TD_Global.currentChat, currentRecording);
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
                        model: [
                            TD_ObjectType.MESSAGE_TEXT,
                            TD_ObjectType.MESSAGE_PHOTO,
                            TD_ObjectType.MESSAGE_VIDEO,
                            //TD_ObjectType.MESSAGE_AUDIO,
                            TD_ObjectType.MESSAGE_STICKER,
                            //TD_ObjectType.MESSAGE_ANIMATION,
                            TD_ObjectType.MESSAGE_VOICE_NOTE,
                            //TD_ObjectType.MESSAGE_VIDEO_NOTE,
                            TD_ObjectType.MESSAGE_DOCUMENT,
                        ];
                        delegate: RectangleButton {
                            size: Theme.iconSizeMedium;
                            active: (currentMsgType === modelData);
                            rounded: false;
                            icon: {
                                switch (modelData) {
                                case TD_ObjectType.MESSAGE_TEXT:       return "icon-m-text-input";
                                case TD_ObjectType.MESSAGE_PHOTO:      return "icon-m-camera";
                                case TD_ObjectType.MESSAGE_VIDEO:      return "icon-m-video";
                                case TD_ObjectType.MESSAGE_AUDIO:      return "icon-m-music";
                                case TD_ObjectType.MESSAGE_STICKER:    return "icon-m-other";
                                case TD_ObjectType.MESSAGE_ANIMATION:  return "icon-m-favorite";
                                case TD_ObjectType.MESSAGE_VOICE_NOTE: return "icon-m-mic";
                                case TD_ObjectType.MESSAGE_VIDEO_NOTE: return "icon-m-play";
                                case TD_ObjectType.MESSAGE_DOCUMENT:   return "icon-m-attach";
                                }
                            }
                            onClicked: {
                                currentMsgType = modelData;
                            }
                        }
                    }
                }
            }
        }
    }
    Component {
        id: compoMsgText;

        ColumnContainer {
            id: delegateMsgText;

            property TD_Message     messageItem        : null;
            property TD_MessageText messageContentItem : null;

            readonly property TD_FormattedText formattedTextItem : (messageContentItem ? messageContentItem.text    : null);
            readonly property TD_WebPage       webPage           : (messageContentItem ? messageContentItem.webPage : null);

            TextEdit {
                id: editText;
                text: (delegateMsgText.formattedTextItem ? delegateMsgText.formattedTextItem.text : "");
                color: Theme.primaryColor;
                readOnly: true;
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                selectByMouse: false;
                selectByKeyboard: false;
                font.family: Theme.fontFamily;
                font.pixelSize: Theme.fontSizeMedium
                ExtraAnchors.horizontalFill: parent;
                onLinkActivated: {
                    console.log ("LINK", link);
                    if (link.indexOf ("td:") === 0) {
                        // TODO : parse and activate
                    }
                    else {
                        Qt.openUrlExternally (link);
                    }
                }

                TextFormatter {
                    id: formatter;
                    entities: (delegateMsgText.formattedTextItem ? delegateMsgText.formattedTextItem.entities : null);
                    textDocument: editText.textDocument;
                    primaryColor: Theme.primaryColor;
                    secondaryColor: Theme.secondaryColor;
                    highlightColor: Theme.highlightColor;
                }
            }
            Loader {
                active: delegateMsgText.webPage;
                visible: active;
                sourceComponent: RowContainer {
                    spacing: Theme.paddingMedium;

                    Rectangle {
                        color: Theme.secondaryColor;
                        implicitWidth: 4;
                        ExtraAnchors.verticalFill: parent;
                    }
                    ColumnContainer {
                        Container.horizontalStretch: 1;

                        LabelFixed {
                            text: (delegateMsgText.webPage ? delegateMsgText.webPage.siteName : "");
                            color: Theme.highlightColor;
                            visible: (text !== "");
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                            ExtraAnchors.horizontalFill: parent;
                        }
                        LabelFixed {
                            text: (delegateMsgText.webPage ? delegateMsgText.webPage.title : "");
                            elide: Text.ElideRight;
                            visible: (text !== "");
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                            maximumLineCount: 3;
                            font.bold: true;
                            ExtraAnchors.horizontalFill: parent;
                        }
                        LabelFixed {
                            text: (delegateMsgText.webPage ? delegateMsgText.webPage.description : "");
                            elide: Text.ElideRight;
                            visible: (text !== "");
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                            maximumLineCount: 2;
                            font.pixelSize: Theme.fontSizeSmall;
                            ExtraAnchors.horizontalFill: parent;
                        }
                        //Loader {
                        //    active: (delegateMsgText.webPage && delegateMsgText.webPage.photo);
                        //    visible: active;
                        //    sourceComponent: DelegatePhoto {
                        //        photo: (delegateMsgText.webPage ? delegateMsgText.webPage.photo : null);
                        //    }
                        //    ExtraAnchors.verticalFill: parent;
                        //}
                        //Loader {
                        //    active: (delegateMsgText.webPage && delegateMsgText.webPage.document);
                        //    visible: active;
                        //    sourceComponent: DelegateDocument {
                        //        document: (delegateMsgText.webPage ? delegateMsgText.webPage.document : null);
                        //    }
                        //    ExtraAnchors.verticalFill: parent;
                        //}
                        //Loader {
                        //    active: (delegateMsgText.webPage && delegateMsgText.webPage.sticker);
                        //    visible: active;
                        //    sourceComponent: DelegateSticker {
                        //        sticker: (delegateMsgText.webPage ? delegateMsgText.webPage.sticker : null);
                        //    }
                        //    ExtraAnchors.verticalFill: parent;
                        //}
                        //Loader {
                        //    active: (delegateMsgText.webPage && delegateMsgText.webPage.animation);
                        //    visible: active;
                        //    sourceComponent: DelegateAnimation {
                        //        animation: (delegateMsgText.webPage ? delegateMsgText.webPage.animation : null);
                        //    }
                        //    ExtraAnchors.verticalFill: parent;
                        //}
                    }
                }
                ExtraAnchors.horizontalFill: parent;
            }
        }
    }
    Component {
        id: compoMsgPhoto;

        ColumnContainer {
            id: delegateMsgPhoto;

            property TD_Message      messageItem        : null;
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

            LabelFixed {
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
            spacing: Theme.paddingMedium;

            property TD_Message         messageItem        : null;
            property TD_MessageDocument messageContentItem : null;

            readonly property TD_FormattedText captionItem   : (messageContentItem  ? messageContentItem.caption   : null);
            readonly property TD_Document      documentItem  : (messageContentItem  ? messageContentItem.document  : null);
            readonly property TD_PhotoSize     photoSizeItem : (documentItem        ? documentItem.thumbnail       : null);

            HelperFileState {
                id: helperMsgDocumentFile;
                fileItem: (delegateMsgDocument.documentItem ? delegateMsgDocument.documentItem.document : null);
                autoDownload: false;
            }
            HelperFileState {
                id: helperMsgDocumentThumbnailFile;
                fileItem: (delegateMsgDocument.photoSizeItem ? delegateMsgDocument.photoSizeItem.photo : null);
                autoDownload: true;
            }
            LabelFixed {
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
                        color: Theme.secondaryHighlightColor;
                        opacity: 0.15;
                        border {
                            width: 1;
                            color: Theme.highlightColor;
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

                    Image {
                        cache: false;
                        source: helperMsgDocumentThumbnailFile.url;
                        visible: (status === Image.Ready);
                        fillMode: Image.PreserveAspectCrop;
                        asynchronous: true;
                        verticalAlignment: Image.AlignVCenter;
                        horizontalAlignment: Image.AlignHCenter;
                        anchors.fill: parent;
                    }
                }
                ColumnContainer {
                    anchors.verticalCenter: parent.verticalCenter;
                    Container.horizontalStretch: 1;

                    LabelFixed {
                        text: (delegateMsgDocument.documentItem ? delegateMsgDocument.documentItem.fileName : "");
                        elide: Text.ElideMiddle;
                        font.underline: true;
                        ExtraAnchors.horizontalFill: parent;
                    }
                    LabelFixed {
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
            LabelFixed {
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

            property TD_Message        messageItem        : null;
            property TD_MessageSticker messageContentItem : null;

            readonly property TD_Sticker stickerItem : (messageContentItem ? messageContentItem.sticker : null);

            readonly property int size : (window.width * 0.35);

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
    }
    Component {
        id: compoMsgVideo;

        ColumnContainer {
            id: delegateMsgVideo;

            property TD_Message      messageItem        : null;
            property TD_MessageVideo messageContentItem : null;

            readonly property TD_FormattedText captionItem   : (messageContentItem  ? messageContentItem.caption : null);
            readonly property TD_Video         videoItem     : (messageContentItem  ? messageContentItem.video   : null);
            readonly property TD_PhotoSize     photoSizeItem : (videoItem           ? videoItem.thumbnail        : null);

            HelperFileState {
                id: helperMsgVideoFile;
                fileItem: (delegateMsgVideo.videoItem ? delegateMsgVideo.videoItem.video : null);
                autoDownload: false;
            }
            LabelFixed {
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
                                if (TD_Global.currentMessageContent === delegateMsgVideo.messageContentItem) {
                                    if (playerVideo.playing) {
                                        playerVideo.pause ();
                                    }
                                    else {
                                        playerVideo.play ();
                                    }
                                }
                                else {
                                    TD_Global.currentMessageContent = delegateMsgVideo.messageContentItem;
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
                        autoDownload: true;
                        anchors.fill: parent;
                    }
                    WrapperVideoPlayer {
                        id: playerVideo;
                        source: helperMsgVideoFile.url;
                        active: (TD_Global.currentMessageContent && delegateMsgVideo.messageContentItem && TD_Global.currentMessageContent === delegateMsgVideo.messageContentItem);
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

            property TD_Message      messageItem        : null;
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
                active: (TD_Global.currentMessageContent && delegateMsgAudio.messageContentItem && TD_Global.currentMessageContent === delegateMsgAudio.messageContentItem);
                autoLoad: true;
                autoPlay: true;
            }
            LabelFixed {
                text: (delegateMsgAudio.audioItem ? delegateMsgAudio.audioItem.fileName : "");
                elide: Text.ElideRight;
                font.pixelSize: Theme.fontSizeSmall;
                ExtraAnchors.horizontalFill: parent;
            }
            LabelFixed {
                text: (delegateMsgAudio.audioItem ? delegateMsgAudio.audioItem.title : "");
                visible: (text !== "");
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                font.bold: true;
                ExtraAnchors.horizontalFill: parent;
            }
            LabelFixed {
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
                                    if (TD_Global.currentMessageContent === delegateMsgAudio.messageContentItem) {
                                        if (playerAudio.playing) {
                                            playerAudio.pause ();
                                        }
                                        else {
                                            playerAudio.play ();
                                        }
                                    }
                                    else {
                                        TD_Global.currentMessageContent = delegateMsgAudio.messageContentItem;
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
                LabelFixed {
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

            property TD_Message          messageItem        : null;
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

            property TD_Message          messageItem        : null;
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
                active: (TD_Global.currentMessageContent && delegateMsgVoiceNote.messageContentItem && TD_Global.currentMessageContent === delegateMsgVoiceNote.messageContentItem);
                autoLoad: true;
                autoPlay: true;
            }
            LabelFixed {
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
                                if (TD_Global.currentMessageContent === delegateMsgVoiceNote.messageContentItem) {
                                    if (playerVoiceNote.playing) {
                                        playerVoiceNote.pause ();
                                    }
                                    else {
                                        playerVoiceNote.play ();
                                    }
                                }
                                else {
                                    TD_Global.currentMessageContent = delegateMsgVoiceNote.messageContentItem;
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
                    LabelFixed {
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
                    LabelFixed {
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
        id: compoMsgChatJoinByLink;

        LabelFixed {
            text: qsTr ("Joined the group chat using the invite link");
            color: Theme.secondaryHighlightColor;
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
            font.italic: true;

            property TD_Message               messageItem        : null;
            property TD_MessageChatJoinByLink messageContentItem : null;
        }
    }
    Component {
        id: compoMsgChatAddMembers;

        ColumnContainer {
            id: delegateMsgChatAddMembers;
            spacing: Theme.paddingSmall;

            property TD_Message               messageItem        : null;
            property TD_MessageChatAddMembers messageContentItem : null;

            LabelFixed {
                text: qsTr ("Added members to this group chat :");
                color: Theme.secondaryHighlightColor;
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                font.italic: true;
                ExtraAnchors.horizontalFill: parent;
            }
            Repeater {
                model: delegateMsgChatAddMembers.messageContentItem.memberUserIds;
                delegate: RowContainer {
                    id: delegateAddedMember;
                    spacing: Theme.paddingMedium;
                    ExtraAnchors.horizontalFill: parent;

                    readonly property TD_User userItem : TD_Global.getUserItemById (modelData);

                    DelegateDownloadableImage {
                        size: Theme.iconSizeMedium;
                        fileItem: (delegateAddedMember.userItem && delegateAddedMember.userItem.profilePhoto
                                   ? delegateAddedMember.userItem.profilePhoto.big
                                   : null);
                        autoDownload: true;
                        anchors.verticalCenter: parent.verticalCenter;
                    }
                    LabelFixed {
                        text: (delegateAddedMember.userItem ? delegateAddedMember.userItem.firstName + " " + delegateAddedMember.userItem.lastName : "");
                        color: Theme.highlightColor;
                        elide: Text.ElideRight;
                        maximumLineCount: 1;
                        anchors.verticalCenter: parent.verticalCenter;
                        Container.horizontalStretch: 1;
                    }
                }
            }
        }
    }
    Component {
        id: compoMsgChatDeleteMember;

        ColumnContainer {
            id: delegateMsgChatDeleteMember;
            spacing: Theme.paddingSmall;

            property TD_Message                 messageItem        : null;
            property TD_MessageChatDeleteMember messageContentItem : null;

            LabelFixed {
                text: (delegateMsgChatDeleteMember.messageItem.senderUserId !== delegateMsgChatDeleteMember.messageContentItem.userId
                       ? qsTr ("Remove member from this group chat :")
                       : qsTr ("Left this group chat"));
                color: Theme.secondaryHighlightColor;
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                font.italic: true;
                ExtraAnchors.horizontalFill: parent;
            }
            RowContainer {
                id: delegateRemovedMember;
                spacing: Theme.paddingMedium;
                visible: (delegateMsgChatDeleteMember.messageItem.senderUserId !== delegateMsgChatDeleteMember.messageContentItem.userId);
                ExtraAnchors.horizontalFill: parent;

                readonly property TD_User userItem : TD_Global.getUserItemById (delegateMsgChatDeleteMember.messageContentItem.userId);

                DelegateDownloadableImage {
                    size: Theme.iconSizeMedium;
                    fileItem: (delegateRemovedMember.userItem && delegateRemovedMember.userItem.profilePhoto
                               ? delegateRemovedMember.userItem.profilePhoto.big
                               : null);
                    autoDownload: true;
                    anchors.verticalCenter: parent.verticalCenter;
                }
                LabelFixed {
                    text: (delegateRemovedMember.userItem ? delegateRemovedMember.userItem.firstName + " " + delegateRemovedMember.userItem.lastName : "");
                    color: Theme.highlightColor;
                    elide: Text.ElideRight;
                    maximumLineCount: 1;
                    anchors.verticalCenter: parent.verticalCenter;
                    Container.horizontalStretch: 1;
                }
            }
        }
    }
    Component {
        id: compoMsgChatChangeTitle;

        LabelFixed {
            text: qsTr ("Changed the group title to '%1'").arg (messageContentItem.title);
            color: Theme.secondaryHighlightColor;
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
            font.italic: true;

            property TD_Message                messageItem        : null;
            property TD_MessageChatChangeTitle messageContentItem : null;
        }
    }
    Component {
        id: compoMsgChatUpgradeFrom;

        LabelFixed {
            text: qsTr ("Upgraded from basic group");
            color: Theme.secondaryHighlightColor;
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
            font.italic: true;

            property TD_Message                messageItem        : null;
            property TD_MessageChatUpgradeFrom messageContentItem : null;
        }
    }
    Component {
        id: compoMsgChatUpgradeTo;

        LabelFixed {
            text: qsTr ("Upgraded to supergroup");
            color: Theme.secondaryHighlightColor;
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
            font.italic: true;

            property TD_Message              messageItem        : null;
            property TD_MessageChatUpgradeTo messageContentItem : null;
        }
    }
    Component {
        id: compoMsgChatContactRegistered;

        LabelFixed {
            text: qsTr ("Registered in Telegram");
            color: Theme.secondaryHighlightColor;
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
            font.italic: true;

            property TD_Message                  messageItem        : null;
            property TD_MessageContactRegistered messageContentItem : null;
        }
    }
    Component {
        id: compoMsgBasicGroupChatCreate;

        LabelFixed {
            text: qsTr ("Group chat '%1' created").arg (messageContentItem.title);
            color: Theme.secondaryHighlightColor;
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
            font.italic: true;

            property TD_Message                     messageItem        : null;
            property TD_MessageBasicGroupChatCreate messageContentItem : null;
        }
    }
    Component {
        id: compoMsgSupergroupChatCreate;

        LabelFixed {
            text: qsTr ("Supergroup chat '%1' created").arg (messageContentItem.title);
            color: Theme.secondaryHighlightColor;
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
            font.italic: true;

            property TD_Message                     messageItem        : null;
            property TD_MessageSupergroupChatCreate messageContentItem : null;
        }
    }
    Component {
        id: compoMsgCall;

        LabelFixed {
            text: {
                if (callDiscardReasonItem) {
                    switch (callDiscardReasonItem.typeOf) {
                    case TD_ObjectType.CALL_DISCARD_REASON_HUNG_UP:      return qsTr ("Call finished (%1)").arg (TD_Global.formatTime (messageContentItem.duration, false));
                    case TD_ObjectType.CALL_DISCARD_REASON_MISSED:       return qsTr ("Call missed");
                    case TD_ObjectType.CALL_DISCARD_REASON_DECLINED:     return qsTr ("Call declined");
                    case TD_ObjectType.CALL_DISCARD_REASON_DISCONNECTED: return qsTr ("Call disconnected");
                    case TD_ObjectType.CALL_DISCARD_REASON_EMPTY:        return qsTr ("Call unknown state");
                    }
                }
                return qsTr ("Call");
            }
            color: Theme.secondaryHighlightColor;
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
            font.italic: true;

            property TD_Message     messageItem        : null;
            property TD_MessageCall messageContentItem : null;

            readonly property TD_CallDiscardReason callDiscardReasonItem : (messageContentItem ? messageContentItem.discardReason : null);
        }
    }
    Component {
        id: compoMsgChatChangePhoto;

        ColumnContainer {
            id: delegateMsgChatChangePhoto;
            spacing: Theme.paddingSmall;

            property TD_Message                messageItem        : null;
            property TD_MessageChatChangePhoto messageContentItem : null;

            readonly property TD_Photo     photoItem     : (messageContentItem                     ? messageContentItem.photo   : null);
            readonly property TD_PhotoSize photoSizeItem : (photoItem && photoItem.sizes.count > 0 ? photoItem.sizes.getLast () : null);

            LabelFixed {
                text: qsTr ("Changed the group photo :");
                color: Theme.secondaryHighlightColor;
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                font.italic: true;
            }
            DelegateDownloadableImage {
                size: Theme.iconSizeLarge;
                fileItem: (delegateMsgChatChangePhoto.photoSizeItem
                           ? delegateMsgChatChangePhoto.photoSizeItem.photo
                           : null);
                autoDownload: true;
            }
        }
    }
    Component {
        id: compoMsgUnsupported;

        LabelFixed {
            text: qsTr ("<Unsupported>");
            color: "magenta";

            property TD_Message        messageItem        : null;
            property TD_MessageContent messageContentItem : null;
        }
    }
    Component {
        id: compoPageCover;

        CoverPage { }
    }
    Component {
        id: compoPageMain;

        PageMain { }
    }
    Component {
        id: compoPageContacts;

        PageContacts { }
    }
    Component {
        id: compoPageChat;

        PageChat { }
    }
    Component {
        id: compoPageSettings;

        PageSettings { }
    }
    Component {
        id: compoPageAbout;

        PageAbout { }
    }
    Component {
        id: compoPageUserInfo;

        Page {
            id: pageUserInfo;
            allowedOrientations: Orientation.Portrait;

            property TD_User userItem : null;

            SilicaFlickable {
                contentWidth: width;
                contentHeight: (layoutUserInfo.height + layoutUserInfo.anchors.margins * 2);
                anchors.fill: parent;

                ColumnContainer {
                    id: layoutUserInfo;
                    spacing: Theme.paddingMedium;
                    ExtraAnchors.topDock: parent;

                    Item {
                        Container.forcedHeight: headerUserInfo.height;
                    }
                    DelegateDownloadableImage {
                        size: Theme.iconSizeExtraLarge;
                        fileItem: (pageUserInfo.userItem && pageUserInfo.userItem.profilePhoto ? pageUserInfo.userItem.profilePhoto.big : null);
                        autoDownload: true;
                        anchors.horizontalCenter: parent.horizontalCenter;
                    }
                    LabelFixed {
                        text: (pageUserInfo.userItem ? pageUserInfo.userItem.firstName : "");
                        color: Theme.primaryColor;
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                        font.family: Theme.fontFamilyHeading;
                        font.pixelSize: Theme.fontSizeLarge;
                        anchors.horizontalCenter: parent.horizontalCenter;
                    }
                    LabelFixed {
                        text: (pageUserInfo.userItem ? pageUserInfo.userItem.lastName : "");
                        color: Theme.primaryColor;
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                        font.family: Theme.fontFamilyHeading;
                        font.pixelSize: Theme.fontSizeLarge;
                        anchors.horizontalCenter: parent.horizontalCenter;
                    }
                    Item {
                        Container.forcedHeight: Theme.paddingLarge;
                    }
                    RowContainer {
                        spacing: Theme.paddingLarge;
                        visible: (pageUserInfo.userItem && pageUserInfo.userItem.username !== "");
                        anchors.margins: Theme.paddingLarge;
                        ExtraAnchors.horizontalFill: parent;

                        RectangleButton {
                            icon: "icon-m-link";
                            size: Theme.iconSizeMedium;
                            anchors.verticalCenter: parent.verticalCenter;
                            onClicked: {
                                Clipboard.text = pageUserInfo.userItem.username;
                            }
                        }
                        LabelFixed {
                            text: (pageUserInfo.userItem ? "@" + pageUserInfo.userItem.username : "");
                            color: Theme.secondaryHighlightColor;
                            font.underline: true;
                            font.pixelSize: Theme.fontSizeLarge;
                            anchors.verticalCenter: parent.verticalCenter;
                        }
                    }
                    RowContainer {
                        spacing: Theme.paddingLarge;
                        visible: (pageUserInfo.userItem && pageUserInfo.userItem.phoneNumber !== "");
                        anchors.margins: Theme.paddingLarge;
                        ExtraAnchors.horizontalFill: parent;

                        RectangleButton {
                            icon: "icon-m-answer";
                            size: Theme.iconSizeMedium;
                            anchors.verticalCenter: parent.verticalCenter;
                            onClicked: {
                                Qt.openUrlExternally ("tel:+" + pageUserInfo.userItem.phoneNumber);
                            }
                        }
                        LabelFixed {
                            text: (pageUserInfo.userItem ? "+" + pageUserInfo.userItem.phoneNumber : "");
                            color: Theme.secondaryHighlightColor;
                            font.underline: true;
                            font.pixelSize: Theme.fontSizeLarge;
                            anchors.verticalCenter: parent.verticalCenter;
                        }
                    }
                    Item {
                        Container.forcedHeight: Theme.paddingLarge;
                    }
                    MouseArea {
                        id: btn;
                        opacity: (enabled ? 1.0 : 0.35);
                        implicitWidth: Math.max (Theme.itemSizeSmall, lbl.width + Theme.paddingMedium * 2);
                        implicitHeight: Math.max (Theme.itemSizeSmall, lbl.height + Theme.paddingMedium * 2);
                        anchors.horizontalCenter: parent.horizontalCenter;
                        onClicked: {
                            console.log ("PRIVATE CHAT REQUESTED", pageUserInfo.userItem.id);
                            var chatItem = TD_Global.getChatItemById (userItem.id);
                            if (chatItem) {
                                TD_Global.showChat (chatItem);
                            }
                            else {
                                TD_Global.createPrivateChat (pageUserInfo.userItem);
                            }
                        }

                        Rectangle {
                            color: (parent.pressed ? Theme.highlightColor : Theme.primaryColor);
                            radius: Theme.paddingSmall;
                            opacity: 0.15;
                            antialiasing: true;
                            anchors.fill: parent;
                        }
                        LabelFixed {
                            id: lbl;
                            text: qsTr ("Open private chat");
                            anchors.centerIn: parent;
                        }
                    }
                }
            }
            Rectangle {
                id: headerUserInfo;
                color: Qt.rgba (1.0 - Theme.primaryColor.r, 1.0 - Theme.primaryColor.g, 1.0 - Theme.primaryColor.b, 0.85);
                implicitHeight: (title.height + title.anchors.margins * 2);
                ExtraAnchors.topDock: parent;

                LabelFixed {
                    id: title;
                    text: qsTr ("Contact info");
                    color: Theme.highlightColor;
                    font {
                        family: Theme.fontFamilyHeading;
                        pixelSize: Theme.fontSizeLarge;
                    }
                    anchors {
                        right: parent.right
                        margins: Theme.paddingLarge;
                        verticalCenter: parent.verticalCenter;
                    }
                }
            }
        }
    }
    Component {
        id: compoPageChatInfoPrivate;

        Page {
            id: pageChatInfoPrivate;
            allowedOrientations: Orientation.Portrait;

            property TD_Chat chatItem : null;
            property TD_User userItem : null;

            SilicaFlickable {
                contentWidth: width;
                contentHeight: (layoutUserInfo.height + layoutUserInfo.anchors.margins * 2);
                anchors.fill: parent;

                PullDownMenu {
                    MenuItem {
                        text: qsTr ("Delete contact [TODO]");
                        enabled: false;
                        onClicked: {
                            // TODO
                        }
                    }
                    MenuItem {
                        text: qsTr ("Block user [TODO]");
                        enabled: false;
                        onClicked: {
                            // TODO
                        }
                    }
                    MenuItem {
                        text: qsTr ("Edit contact [TODO]");
                        enabled: false;
                        onClicked: {
                            // TODO
                        }
                    }
                }
                ColumnContainer {
                    id: layoutUserInfo;
                    spacing: (Theme.paddingLarge * 2);
                    anchors.margins: Theme.paddingLarge;
                    ExtraAnchors.topDock: parent;

                    LabelFixed {
                        text: qsTr ("User details")
                        color: Theme.highlightColor;
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                        font.family: Theme.fontFamilyHeading;
                        font.pixelSize: Theme.fontSizeExtraLarge;
                        anchors.right: parent.right;
                    }
                    RowContainer {
                        spacing: Theme.paddingLarge;
                        anchors.margins: Theme.paddingLarge;
                        ExtraAnchors.horizontalFill: parent;

                        DelegateDownloadableImage {
                            size: Theme.iconSizeExtraLarge;
                            fileItem: (pageChatInfoPrivate.chatItem && pageChatInfoPrivate.chatItem.photo ? pageChatInfoPrivate.chatItem.photo.big : null);
                            autoDownload: true;
                            anchors.verticalCenter: parent.verticalCenter;
                        }
                        LabelFixed {
                            text: (pageChatInfoPrivate.chatItem ? pageChatInfoPrivate.chatItem.title : "");
                            color: Theme.primaryColor;
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                            font.family: Theme.fontFamilyHeading;
                            font.pixelSize: Theme.fontSizeLarge;
                            anchors.verticalCenter: parent.verticalCenter;
                            Container.horizontalStretch: 1;
                        }
                    }
                    RowContainer {
                        spacing: Theme.paddingLarge;
                        visible: (pageChatInfoPrivate.userItem && pageChatInfoPrivate.userItem.username !== "");
                        anchors.margins: Theme.paddingLarge;
                        ExtraAnchors.horizontalFill: parent;

                        RectangleButton {
                            icon: "icon-m-link";
                            size: Theme.iconSizeMedium;
                            anchors.verticalCenter: parent.verticalCenter;
                            onClicked: {
                                Clipboard.text = pageChatInfoPrivate.userItem.username;
                            }
                        }
                        LabelFixed {
                            text: (pageChatInfoPrivate.userItem ? "@" + pageChatInfoPrivate.userItem.username : "");
                            color: Theme.secondaryHighlightColor;
                            font.underline: true;
                            font.pixelSize: Theme.fontSizeLarge;
                            anchors.verticalCenter: parent.verticalCenter;
                        }
                    }
                    RowContainer {
                        spacing: Theme.paddingLarge;
                        visible: (pageChatInfoPrivate.userItem && pageChatInfoPrivate.userItem.phoneNumber !== "");
                        anchors.margins: Theme.paddingLarge;
                        ExtraAnchors.horizontalFill: parent;

                        RectangleButton {
                            icon: "icon-m-answer";
                            size: Theme.iconSizeMedium;
                            anchors.verticalCenter: parent.verticalCenter;
                            onClicked: {
                                Qt.openUrlExternally ("tel:+" + pageChatInfoPrivate.userItem.phoneNumber);
                            }
                        }
                        LabelFixed {
                            text: (pageChatInfoPrivate.userItem ? "+" + pageChatInfoPrivate.userItem.phoneNumber : "");
                            color: Theme.secondaryHighlightColor;
                            font.underline: true;
                            font.pixelSize: Theme.fontSizeLarge;
                            anchors.verticalCenter: parent.verticalCenter;
                        }
                    }
                }
            }
        }
    }
    Component {
        id: compoPageChatInfoBasicGroup;

        Page {
            id: pageChatInfoBasicGroup;
            allowedOrientations: Orientation.Portrait;

            property TD_Chat       chatItem       : null;
            property TD_BasicGroup basicGroupItem : null;

            readonly property TD_User creatorUserItem : (basicGroupItem ? TD_Global.getUserItemById (basicGroupItem.creatorUserId) : null);

            SilicaFlickable {
                contentWidth: width;
                contentHeight: (layoutBasicGroupInfo.height + layoutBasicGroupInfo.anchors.margins * 2);
                anchors.fill: parent;

                PullDownMenu {
                    MenuItem {
                        text: qsTr ("Leave group [TODO]");
                        enabled: false;
                        onClicked: {
                            // TODO
                        }
                    }
                }
                ColumnContainer {
                    id: layoutBasicGroupInfo;
                    spacing: (Theme.paddingLarge * 2);
                    anchors.margins: Theme.paddingLarge;
                    ExtraAnchors.topDock: parent;

                    LabelFixed {
                        text: qsTr ("Group chat details")
                        color: Theme.highlightColor;
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                        font.family: Theme.fontFamilyHeading;
                        font.pixelSize: Theme.fontSizeExtraLarge;
                        anchors.right: parent.right;
                    }
                    RowContainer {
                        spacing: Theme.paddingLarge;
                        anchors.margins: Theme.paddingLarge;
                        ExtraAnchors.horizontalFill: parent;

                        DelegateDownloadableImage {
                            size: Theme.iconSizeExtraLarge;
                            fileItem: (pageChatInfoBasicGroup.chatItem && pageChatInfoBasicGroup.chatItem.photo ? pageChatInfoBasicGroup.chatItem.photo.big : null);
                            autoDownload: true;
                            anchors.verticalCenter: parent.verticalCenter;
                        }
                        LabelFixed {
                            text: (pageChatInfoBasicGroup.chatItem ? pageChatInfoBasicGroup.chatItem.title : "");
                            color: Theme.primaryColor;
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                            font.family: Theme.fontFamilyHeading;
                            font.pixelSize: Theme.fontSizeLarge;
                            anchors.verticalCenter: parent.verticalCenter;
                            Container.horizontalStretch: 1;
                        }
                    }
                    RowContainer {
                        spacing: Theme.paddingLarge;
                        visible: pageChatInfoBasicGroup.creatorUserItem;
                        anchors.margins: Theme.paddingLarge;
                        ExtraAnchors.horizontalFill: parent;

                        ColumnContainer {
                            anchors.verticalCenter: parent.verticalCenter;
                            Container.horizontalStretch: 1;

                            LabelFixed {
                                text: qsTr ("Created by");
                                color: Theme.secondaryHighlightColor;
                                font.pixelSize: Theme.fontSizeExtraSmall;
                                anchors.right: parent.right;
                            }
                            LabelFixed {
                                text: (pageChatInfoBasicGroup.creatorUserItem
                                       ? (pageChatInfoBasicGroup.creatorUserItem.firstName + " " + pageChatInfoBasicGroup.creatorUserItem.lastName)
                                       : "<undefined>");
                                color: Theme.highlightColor;
                                font.underline: true;
                                font.pixelSize: Theme.fontSizeMedium;
                                anchors.right: parent.right;
                            }
                        }
                        DelegateDownloadableImage {
                            size: Theme.iconSizeMedium;
                            fileItem: (pageChatInfoBasicGroup.creatorUserItem && pageChatInfoBasicGroup.creatorUserItem.profilePhoto
                                       ? pageChatInfoBasicGroup.creatorUserItem.profilePhoto.big
                                       : null);
                            autoDownload: true;
                            anchors.verticalCenter: parent.verticalCenter;
                        }
                    }
                    LabelFixed {
                        text: qsTr ("This group chat is not active anymore");
                        color: Theme.primaryColor;
                        visible: (pageChatInfoBasicGroup.basicGroupItem && !pageChatInfoBasicGroup.basicGroupItem.isActive);
                        horizontalAlignment: Text.AlignHCenter;
                        font.italic: true;
                        font.pixelSize: Theme.fontSizeSmall;
                        ExtraAnchors.horizontalFill: parent;
                    }
                    RowContainer {
                        spacing: Theme.paddingLarge;
                        visible: (pageChatInfoBasicGroup.basicGroupItem && pageChatInfoBasicGroup.basicGroupItem.inviteLink !== "");
                        anchors.margins: Theme.paddingLarge;
                        ExtraAnchors.horizontalFill: parent;

                        RectangleButton {
                            icon: "icon-m-share";
                            size: Theme.iconSizeMedium;
                            anchors.verticalCenter: parent.verticalCenter;
                            onClicked: {
                                Clipboard.text = pageChatInfoBasicGroup.basicGroupItem.inviteLink;
                            }
                        }
                        LabelFixed {
                            text: (pageChatInfoBasicGroup.basicGroupItem ? pageChatInfoBasicGroup.basicGroupItem.inviteLink : "");
                            color: Theme.secondaryHighlightColor;
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                            font.underline: true;
                            font.pixelSize: Theme.fontSizeLarge;
                            anchors.verticalCenter: parent.verticalCenter;
                            Container.horizontalStretch: 1;
                        }
                    }
                    Item {
                        Container.forcedHeight: Theme.paddingSmall;
                    }
                    ColumnContainer {
                        spacing: Theme.paddingMedium;
                        anchors.margins: Theme.paddingLarge;
                        ExtraAnchors.horizontalFill: parent;

                        RowContainer {
                            spacing: Theme.paddingLarge;
                            ExtraAnchors.horizontalFill: parent;

                            Rectangle {
                                color: Theme.secondaryColor;
                                opacity: 0.35;
                                implicitHeight: 1;
                                anchors.verticalCenter: parent.verticalCenter;
                                Container.horizontalStretch: 1;
                            }
                            LabelFixed {
                                text: qsTr ("%1 members").arg (pageChatInfoBasicGroup.basicGroupItem ? pageChatInfoBasicGroup.basicGroupItem.memberCount : 0);
                                color: Theme.secondaryColor;
                                font.pixelSize: Theme.fontSizeSmall;
                                anchors.verticalCenter: parent.verticalCenter;
                            }
                            Rectangle {
                                color: Theme.secondaryColor;
                                opacity: 0.35;
                                implicitHeight: 1;
                                anchors.verticalCenter: parent.verticalCenter;
                                Container.horizontalStretch: 1;
                            }
                        }
                        Repeater {
                            model: (pageChatInfoBasicGroup.basicGroupItem ? pageChatInfoBasicGroup.basicGroupItem.members : 0);
                            delegate: RowContainer {
                                id: delegateBasicGroupMember;
                                spacing: Theme.paddingMedium;
                                ExtraAnchors.horizontalFill: parent;

                                readonly property TD_ChatMember chatMemberItem : modelData;

                                readonly property TD_User memberUserItem : (chatMemberItem ? TD_Global.getUserItemById (chatMemberItem.userId) : null);

                                DelegateDownloadableImage {
                                    size: Theme.iconSizeMedium;
                                    fileItem: (delegateBasicGroupMember.memberUserItem && delegateBasicGroupMember.memberUserItem.profilePhoto
                                               ? delegateBasicGroupMember.memberUserItem.profilePhoto.big
                                               : null);
                                    autoDownload: true;
                                    anchors.verticalCenter: parent.verticalCenter;
                                }
                                ColumnContainer {
                                    Container.horizontalStretch: 1;

                                    LabelFixed {
                                        text: (delegateBasicGroupMember.memberUserItem
                                               ? (delegateBasicGroupMember.memberUserItem.firstName + " " + delegateBasicGroupMember.memberUserItem.lastName)
                                               : "<undefined>");
                                        color: Theme.highlightColor;
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                                        font.underline: true;
                                        font.pixelSize: Theme.fontSizeMedium;
                                        ExtraAnchors.horizontalFill: parent;
                                    }
                                    LabelFixed {
                                        text: {
                                            if (delegateBasicGroupMember.memberUserItem && delegateBasicGroupMember.memberUserItem.status) {
                                                switch (delegateBasicGroupMember.memberUserItem.status.typeOf) {
                                                case TD_ObjectType.USER_STATUS_ONLINE:     return qsTr ("Online");
                                                case TD_ObjectType.USER_STATUS_OFFLINE:    return qsTr ("Offline since %1").arg (Qt.formatDateTime (delegateBasicGroupMember.memberUserItem.status.wasOnline));
                                                case TD_ObjectType.USER_STATUS_LAST_MONTH: return qsTr ("Seen last month");
                                                case TD_ObjectType.USER_STATUS_LAST_WEEK:  return qsTr ("Seen last week");
                                                case TD_ObjectType.USER_STATUS_RECENTLY:   return qsTr ("Recently");
                                                case TD_ObjectType.USER_STATUS_EMPTY:      return qsTr ("");
                                                }
                                            }
                                            return "";
                                        }
                                        color: Theme.secondaryColor;
                                        font {
                                            family: Theme.fontFamilyHeading;
                                            pixelSize: Theme.fontSizeExtraSmall;
                                        }

                                        Rectangle {
                                            color: "lime";
                                            radius: (Theme.paddingMedium * 0.5);
                                            visible: (delegateBasicGroupMember.memberUserItem &&
                                                      delegateBasicGroupMember.memberUserItem.status &&
                                                      delegateBasicGroupMember.memberUserItem.status.typeOf === TD_ObjectType.USER_STATUS_ONLINE);
                                            antialiasing: true;
                                            implicitWidth: Theme.paddingMedium;
                                            implicitHeight: Theme.paddingMedium;
                                            anchors {
                                                left: parent.right;
                                                margins: Theme.paddingMedium;
                                                verticalCenter: parent.verticalCenter;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    Component {
        id: compoPageChatInfoSupergroup;

        Page {
            id: pageChatInfoSupergroup;
            allowedOrientations: Orientation.Portrait;

            property TD_Chat       chatItem       : null;
            property TD_Supergroup supergroupItem : null;

            SilicaFlickable {
                contentWidth: width;
                contentHeight: (layoutSupergroupInfo.height + layoutSupergroupInfo.anchors.margins * 2);
                anchors.fill: parent;

                PullDownMenu {
                    MenuItem {
                        text: qsTr ("Leave group [TODO]");
                        enabled: false;
                        onClicked: {
                            // TODO
                        }
                    }
                }
                ColumnContainer {
                    id: layoutSupergroupInfo;
                    spacing: (Theme.paddingLarge * 2);
                    anchors.margins: Theme.paddingLarge;
                    ExtraAnchors.topDock: parent;

                    LabelFixed {
                        text: qsTr ("Supergroup chat details")
                        color: Theme.highlightColor;
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                        font.family: Theme.fontFamilyHeading;
                        font.pixelSize: Theme.fontSizeExtraLarge;
                        anchors.right: parent.right;
                    }
                    RowContainer {
                        spacing: Theme.paddingLarge;
                        anchors.margins: Theme.paddingLarge;
                        ExtraAnchors.horizontalFill: parent;

                        DelegateDownloadableImage {
                            size: Theme.iconSizeExtraLarge;
                            fileItem: (pageChatInfoSupergroup.chatItem && pageChatInfoSupergroup.chatItem.photo ? pageChatInfoSupergroup.chatItem.photo.big : null);
                            autoDownload: true;
                            anchors.verticalCenter: parent.verticalCenter;
                        }
                        LabelFixed {
                            text: (pageChatInfoSupergroup.chatItem ? pageChatInfoSupergroup.chatItem.title : "");
                            color: Theme.primaryColor;
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                            font.family: Theme.fontFamilyHeading;
                            font.pixelSize: Theme.fontSizeLarge;
                            anchors.verticalCenter: parent.verticalCenter;
                            Container.horizontalStretch: 1;
                        }
                    }
                    LabelFixed {
                        text: (pageChatInfoSupergroup.supergroupItem ? pageChatInfoSupergroup.supergroupItem.description : "");
                        color: Theme.secondaryColor;
                        visible: (text !== "");
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                        font.family: Theme.fontFamilyHeading;
                        font.pixelSize: Theme.fontSizeSmall;
                        anchors.margins: Theme.paddingLarge;
                        ExtraAnchors.horizontalFill: parent;

                        Rectangle {
                            z: -1;
                            color: Theme.secondaryColor;
                            opacity: 0.15;
                            anchors {
                                fill: parent;
                                margins: -Theme.paddingSmall;
                            }
                        }
                    }
                    RowContainer {
                        spacing: Theme.paddingLarge;
                        visible: (pageChatInfoSupergroup.supergroupItem && pageChatInfoSupergroup.supergroupItem.username !== "");
                        anchors.margins: Theme.paddingLarge;
                        ExtraAnchors.horizontalFill: parent;

                        RectangleButton {
                            icon: "icon-m-link";
                            size: Theme.iconSizeMedium;
                            anchors.verticalCenter: parent.verticalCenter;
                            onClicked: {
                                Clipboard.text = pageChatInfoSupergroup.supergroupItem.username;
                            }
                        }
                        LabelFixed {
                            text: (pageChatInfoSupergroup.supergroupItem ? "@" + pageChatInfoSupergroup.supergroupItem.username : "");
                            color: Theme.secondaryHighlightColor;
                            font.underline: true;
                            font.pixelSize: Theme.fontSizeLarge;
                            anchors.verticalCenter: parent.verticalCenter;
                        }
                    }
                    RowContainer {
                        spacing: Theme.paddingLarge;
                        visible: (pageChatInfoSupergroup.supergroupItem && pageChatInfoSupergroup.supergroupItem.inviteLink !== "");
                        anchors.margins: Theme.paddingLarge;
                        ExtraAnchors.horizontalFill: parent;

                        RectangleButton {
                            icon: "icon-m-share";
                            size: Theme.iconSizeMedium;
                            anchors.verticalCenter: parent.verticalCenter;
                            onClicked: {
                                Clipboard.text = pageChatInfoSupergroup.supergroupItem.inviteLink;
                            }
                        }
                        LabelFixed {
                            text: (pageChatInfoSupergroup.supergroupItem ? pageChatInfoSupergroup.supergroupItem.inviteLink : "");
                            color: Theme.secondaryHighlightColor;
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                            font.underline: true;
                            font.pixelSize: Theme.fontSizeLarge;
                            anchors.verticalCenter: parent.verticalCenter;
                            Container.horizontalStretch: 1;
                        }
                    }
                    Item {
                        Container.forcedHeight: Theme.paddingSmall;
                    }
                    ColumnContainer {
                        visible: (pageChatInfoSupergroup.supergroupItem && !pageChatInfoSupergroup.supergroupItem.isChannel);
                        spacing: Theme.paddingMedium;
                        anchors.margins: Theme.paddingLarge;
                        ExtraAnchors.horizontalFill: parent;

                        RowContainer {
                            spacing: Theme.paddingLarge;
                            ExtraAnchors.horizontalFill: parent;

                            Rectangle {
                                color: Theme.secondaryColor;
                                opacity: 0.35;
                                implicitHeight: 1;
                                anchors.verticalCenter: parent.verticalCenter;
                                Container.horizontalStretch: 1;
                            }
                            LabelFixed {
                                text: qsTr ("%1 members").arg (pageChatInfoSupergroup.supergroupItem ? pageChatInfoSupergroup.supergroupItem.memberCount : 0);
                                color: Theme.secondaryColor;
                                font.pixelSize: Theme.fontSizeSmall;
                                anchors.verticalCenter: parent.verticalCenter;
                            }
                            Rectangle {
                                color: Theme.secondaryColor;
                                opacity: 0.35;
                                implicitHeight: 1;
                                anchors.verticalCenter: parent.verticalCenter;
                                Container.horizontalStretch: 1;
                            }
                        }
                        Repeater {
                            model: (pageChatInfoSupergroup.supergroupItem ? pageChatInfoSupergroup.supergroupItem.members : 0);
                            delegate: RowContainer {
                                id: delegateSupergroupMember;
                                spacing: Theme.paddingMedium;
                                ExtraAnchors.horizontalFill: parent;

                                readonly property TD_ChatMember chatMemberItem : modelData;

                                readonly property TD_User memberUserItem : (chatMemberItem ? TD_Global.getUserItemById (chatMemberItem.userId) : null);

                                DelegateDownloadableImage {
                                    size: Theme.iconSizeMedium;
                                    fileItem: (delegateSupergroupMember.memberUserItem && delegateSupergroupMember.memberUserItem.profilePhoto
                                               ? delegateSupergroupMember.memberUserItem.profilePhoto.big
                                               : null);
                                    autoDownload: true;
                                    anchors.verticalCenter: parent.verticalCenter;
                                }
                                ColumnContainer {
                                    Container.horizontalStretch: 1;

                                    LabelFixed {
                                        text: (delegateSupergroupMember.memberUserItem
                                               ? (delegateSupergroupMember.memberUserItem.firstName + " " + delegateSupergroupMember.memberUserItem.lastName)
                                               : "<undefined>");
                                        color: Theme.highlightColor;
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                                        font.underline: true;
                                        font.pixelSize: Theme.fontSizeMedium;
                                        ExtraAnchors.horizontalFill: parent;
                                    }
                                    LabelFixed {
                                        text: {
                                            if (delegateSupergroupMember.memberUserItem && delegateSupergroupMember.memberUserItem.status) {
                                                switch (delegateSupergroupMember.memberUserItem.status.typeOf) {
                                                case TD_ObjectType.USER_STATUS_ONLINE:     return qsTr ("Online");
                                                case TD_ObjectType.USER_STATUS_OFFLINE:    return qsTr ("Offline since %1").arg (Qt.formatDateTime (delegateSupergroupMember.memberUserItem.status.wasOnline));
                                                case TD_ObjectType.USER_STATUS_LAST_MONTH: return qsTr ("Seen last month");
                                                case TD_ObjectType.USER_STATUS_LAST_WEEK:  return qsTr ("Seen last week");
                                                case TD_ObjectType.USER_STATUS_RECENTLY:   return qsTr ("Recently");
                                                case TD_ObjectType.USER_STATUS_EMPTY:      return qsTr ("");
                                                }
                                            }
                                            return "";
                                        }
                                        color: Theme.secondaryColor;
                                        font {
                                            family: Theme.fontFamilyHeading;
                                            pixelSize: Theme.fontSizeExtraSmall;
                                        }

                                        Rectangle {
                                            color: "lime";
                                            radius: (Theme.paddingMedium * 0.5);
                                            visible: (delegateSupergroupMember.memberUserItem &&
                                                      delegateSupergroupMember.memberUserItem.status &&
                                                      delegateSupergroupMember.memberUserItem.status.typeOf === TD_ObjectType.USER_STATUS_ONLINE);
                                            antialiasing: true;
                                            implicitWidth: Theme.paddingMedium;
                                            implicitHeight: Theme.paddingMedium;
                                            anchors {
                                                left: parent.right;
                                                margins: Theme.paddingMedium;
                                                verticalCenter: parent.verticalCenter;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
