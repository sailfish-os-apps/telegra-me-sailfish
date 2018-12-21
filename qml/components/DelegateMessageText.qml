import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;
import QtQml.Models 2.2;

DelegateAbstractMessageContent {
    id: self;
    spacing: Theme.paddingSmall;
    optimalWidth: Math.ceil (metrics.implicitWidth * 1.01);
    additionalContextMenuItems: ObjectModel {
        MenuItem {
            text: qsTr ("Copy text");
            onClicked: {
                Clipboard.text = formattedText.text;
            }
        }
    }

    property TD_MessageText messageContentItem : null;

    readonly property TD_WebPage webPage : (messageContentItem ? messageContentItem.webPage : null);

    DelegateFormattedText {
        id: formattedText;
        formattedTextItem: (messageContentItem ? messageContentItem.text : null);
        ExtraAnchors.horizontalFill: parent;

        Text {
            id: metrics;
            z: -1;
            text: formattedText.text;
            font: formattedText.font;
            color: "transparent";
            enabled: false;
            textFormat: Text.PlainText;
        }
    }
    Loader {
        active: self.webPage;
        visible: active;
        sourceComponent: RowContainer {
            spacing: Theme.paddingMedium;

            MouseArea {
                anchors.fill: parent;
                Container.ignored: true;
                onClicked: {
                    Qt.openUrlExternally (self.webPage.url);
                }
            }
            Rectangle {
                color: Theme.secondaryColor;
                implicitWidth: Theme.paddingSmall;
                anchors.margins: Theme.paddingSmall;
                ExtraAnchors.verticalFill: parent;
            }
            ColumnContainer {
                Container.horizontalStretch: 1;

                LabelFixed {
                    text: (self.webPage ? self.webPage.siteName : "");
                    color: Theme.highlightColor;
                    visible: (text !== "");
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                    ExtraAnchors.horizontalFill: parent;
                }
                LabelFixed {
                    text: (self.webPage ? self.webPage.title : "");
                    elide: Text.ElideRight;
                    visible: (text !== "");
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                    maximumLineCount: 3;
                    font.bold: true;
                    ExtraAnchors.horizontalFill: parent;
                }
                LabelFixed {
                    text: (self.webPage ? self.webPage.description : "");
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
