import QtQuick 2.6;
import QtMultimedia 5.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;

DelegateAbstractMessageContent {
    id: self;
    optimalWidth: layout.implicitWidth;
    spacing: Theme.paddingSmall;

    property TD_MessageVoiceNote messageContentItem : null;

    readonly property TD_FormattedText captionItem   : (messageContentItem ? messageContentItem.caption   : null);
    readonly property TD_VoiceNote     voiceNoteItem : (messageContentItem ? messageContentItem.voiceNote : null);

    HelperFileState {
        id: helper;
        fileItem: (self.voiceNoteItem ? self.voiceNoteItem.voice : null);
        autoDownload: false;
    }
    WrapperAudioPlayer {
        id: player;
        source: helper.url;
        active: (TD_Global.currentMessageContent && self.messageContentItem && TD_Global.currentMessageContent === self.messageContentItem);
        autoLoad: true;
        autoPlay: true;
    }
    LabelFixed {
        text: (self.captionItem ? self.captionItem.text : "");
        visible: (text !== "");
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
        ExtraAnchors.horizontalFill: parent;
    }
    RowContainer {
        id: layout;
        spacing: Theme.paddingMedium;
        ExtraAnchors.horizontalFill: parent;

        RectangleButton {
            icon: ((helper.downloadable && !helper.downloading && !helper.downloaded)
                   ? "icon-m-cloud-download"
                   : ((helper.downloaded && !player.playing)
                      ? "icon-m-play"
                      : "icon-m-pause"));
            size: Theme.iconSizeMedium;
            active: player.playing;
            implicitWidth: Theme.itemSizeMedium;
            implicitHeight: Theme.itemSizeMedium;
            anchors.verticalCenter: parent.verticalCenter;
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

            ProgressCircle {
                value: helper.progress;
                visible: (helper.downloading || helper.uploading);
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
                        player.seek (Math.round (player.duration * mouse.x / width));
                    }
                }
                Repeater {
                    model: (self.voiceNoteItem && self.voiceNoteItem.waveform !== ""
                            ? TD_Global.parseWaveform (self.voiceNoteItem.waveform)
                            : 0);
                    delegate: Rectangle {
                        color: ((model.index / 100) <= player.progress ? Theme.highlightColor : Theme.secondaryColor);
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
                        implicitWidth: (parent.width * player.progress);
                        ExtraAnchors.leftDock: parent;
                    }
                }
            }
            LabelFixed {
                text: (self.voiceNoteItem
                       ?  (player.playing
                           ? qsTr ("(Listening...)")
                           : (self.messageContentItem.isListened
                              ? qsTr ("(Listened)")
                              : qsTr ("(Not listened yet)")))
                       : "");
                color: Theme.secondaryColor;
                font.pixelSize: Theme.fontSizeSmall;
            }
            LabelFixed {
                text: (self.voiceNoteItem
                       ? (player.playing
                          ? ("-" + TD_Global.formatTime (player.remaining, false))
                          : TD_Global.formatTime ((self.voiceNoteItem.duration * 1000), false))
                       : "--:--");
                color: (player.playing ? Theme.highlightColor : Theme.primaryColor);
                font.pixelSize: Theme.fontSizeSmall;
            }
        }
    }
}
