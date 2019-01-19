import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;
import QtQml.Models 2.2;

DelegateAbstractMessageContent {
    id: self;
    spacing: Theme.paddingMedium;
    additionalContextMenuItems: ObjectModel {
        MenuItem {
            text: qsTr ("Save a copy in 'Downloads'");
            visible: (documentItem !== null);
            enabled: (documentItem &&
                      documentItem.document &&
                      documentItem.document.local &&
                      documentItem.document.local.isDownloadingCompleted);
            onClicked: {
                TD_Global.downloadDocument (documentItem);
                emblem.visible = true;
            }
        }
    }


    property TD_MessageDocument messageContentItem : null;

    readonly property TD_Document  documentItem  : (messageContentItem ? messageContentItem.document : null);
    readonly property TD_PhotoSize photoSizeItem : (documentItem       ? documentItem.thumbnail      : null);

    HelperFileState {
        id: helper;
        fileItem: (documentItem ? documentItem.document : null);
        autoDownload: false;
    }
    DelegateFormattedText {
        formattedTextItem: (messageContentItem ? messageContentItem.caption : null);
        ExtraAnchors.horizontalFill: parent;
    }
    MouseArea {
        implicitHeight: (layout.height + layout.anchors.margins * 2);
        ExtraAnchors.horizontalFill: parent;
        onClicked: {
            if (helper.uploading) {
                // NOTHING WE CAN DO
            }
            else {
                if (helper.downloaded) {
                    Qt.openUrlExternally (helper.url);
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

        Rectangle {
            color: Theme.rgba (Theme.secondaryHighlightColor, 0.15);
            border {
                width: 1;
                color: Theme.highlightColor;
            }
            anchors.fill: parent;
        }
        RowContainer {
            id: layout;
            spacing: Theme.paddingMedium;
            anchors {
                margins: Theme.paddingSmall;
                verticalCenter: parent.verticalCenter;
            }
            ExtraAnchors.horizontalFill: parent;

            Image {
                source: (self.documentItem
                         ? "qrc:///symbols/filetypes/%1.svg".arg (TD_Global.getSvgIconForMimeType (documentItem.mimeType))
                         : "");
                sourceSize: Qt.size (Theme.iconSizeMedium, Theme.iconSizeMedium);
                anchors.verticalCenter: parent.verticalCenter;

                DelegateDownloadableImage {
                    cache: false;
                    fileItem: (photoSizeItem ? photoSizeItem.photo : null);
                    background: false;
                    autoDownload: true;
                    asynchronous: true;
                    anchors.fill: parent;
                }
            }
            ColumnContainer {
                anchors.verticalCenter: parent.verticalCenter;
                Container.horizontalStretch: 1;

                LabelFixed {
                    text: (documentItem ? documentItem.fileName : "");
                    elide: Text.ElideMiddle;
                    font.underline: true;
                    ExtraAnchors.horizontalFill: parent;
                }
                RowContainer {
                    spacing: Theme.paddingSmall;
                    ExtraAnchors.horizontalFill: parent;

                    BusyIndicator {
                        size: BusyIndicatorSize.ExtraSmall;
                        visible: running;
                        running: (helper.downloading || helper.uploading);
                        anchors.verticalCenter: parent.verticalCenter;
                    }
                    LabelFixed {
                        text: {
                            var ret = "";
                            ret += "(";
                            ret +=  (helper.downloading
                                     ? qsTr ("Downloading")
                                     : (helper.uploading
                                        ? qsTr ("Uploading")
                                        : (helper.downloaded
                                           ? qsTr ("Complete, tap to open")
                                           : qsTr ("Tap to download"))));
                            ret += " ";
                            ret += ((helper.downloading || helper.uploading)
                                     ? "%1/%2".arg (TD_Global.formatSize (helper.currentSize)).arg (TD_Global.formatSize (helper.totalSize))
                                     : "%1".arg (TD_Global.formatSize (helper.totalSize)));
                            ret += ")";
                            return ret;
                        }
                        color: Theme.secondaryColor;
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                        font.pixelSize: Theme.fontSizeSmall;
                        anchors.verticalCenter: parent.verticalCenter;
                        Container.horizontalStretch: 1;
                    }
                }
            }
        }
    }
    LabelFixed {
        id: emblem;
        text: qsTr ("(copied in 'Downloads')");
        opacity: 0.65;
        visible: TD_Global.isDocumentDownloaded (documentItem);
        horizontalAlignment: Text.AlignHCenter;
        font.pixelSize: Theme.fontSizeExtraSmall;
        ExtraAnchors.horizontalFill: parent;
    }
}
