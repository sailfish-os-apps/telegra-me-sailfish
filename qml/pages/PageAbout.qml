import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;
import "../components";

Page {
    id: page;
    allowedOrientations: Orientation.All;

    Flickable {
        id: flickerAbout;
        contentWidth: width;
        contentHeight: (layout.height + layout.anchors.margins * 2);
        anchors.fill: parent;

        ColumnContainer {
            id: layout;
            spacing: Theme.paddingLarge;
            anchors.margins: Theme.paddingLarge;
            ExtraAnchors.topDock: parent;

            Item {
                Container.forcedHeight: Theme.paddingMedium;
            }
            Image {
                source: "qrc:///icons/scalable/harbour-telegrame.svg";
                sourceSize: Qt.size (Theme.iconSizeExtraLarge, Theme.iconSizeExtraLarge);
                anchors.horizontalCenter: parent.horizontalCenter;
            }
            LabelFixed {
                text: "Telegra'me v21";
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                font.family: Theme.fontFamilyHeading;
                font.pixelSize: Theme.fontSizeExtraLarge;
                horizontalAlignment: Text.AlignHCenter;
                ExtraAnchors.horizontalFill: parent;
            }
            LabelFixed {
                text: "using TDLIB v1.4";
                opacity: 0.65;
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                font.family: Theme.fontFamilyHeading;
                font.pixelSize: Theme.fontSizeLarge;
                horizontalAlignment: Text.AlignHCenter;
                ExtraAnchors.horizontalFill: parent;
            }
            LabelFixed {
                text: qsTr ("An unofficial client for Telegram messaging, using TDLIB API. It aims to provide all the main features of the official apps on other platforms, while integrating nicely into Sailfish UI that we all love.");
                color: Theme.rgba (Theme.primaryColor, 0.65);
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                horizontalAlignment: Text.AlignJustify;
                font.family: Theme.fontFamilyHeading;
                font.pixelSize: Theme.fontSizeSmall;
                ExtraAnchors.horizontalFill: parent;
            }
            Item {
                Container.forcedHeight: Theme.paddingMedium;
            }
            LabelFixed {
                text: qsTr ("Designed and developed by Thomas BOUTROUE");
                color: Theme.rgba (Theme.secondaryHighlightColor, 0.65);
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                horizontalAlignment: Text.AlignHCenter;
                font.family: Theme.fontFamilyHeading;
                font.pixelSize: Theme.fontSizeMedium;
                ExtraAnchors.horizontalFill: parent;
            }
            LabelFixed {
                text: "thebootroo@gmail.com";
                color: Theme.rgba (Theme.highlightColor, 0.65);
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                horizontalAlignment: Text.AlignHCenter;
                font.family: Theme.fontFamilyHeading;
                font.underline: true;
                font.pixelSize: Theme.fontSizeSmall;
                ExtraAnchors.horizontalFill: parent;

                MouseArea {
                    anchors.fill: parent;
                    anchors.margins: -Theme.paddingMedium;
                    onClicked: {
                        Qt.openUrlExternally ("mailto:" + parent.text);
                    }
                }
            }
            Rectangle {
                color: Theme.secondaryColor;
                implicitHeight: 1;
                ExtraAnchors.horizontalFill: parent;
            }
            LabelFixed {
                text: qsTr ("The app is open-source and the code is hosted on my Gitlab instance :");
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                horizontalAlignment: Text.AlignHCenter;
                font.family: Theme.fontFamilyHeading;
                font.pixelSize: Theme.fontSizeMedium;
                ExtraAnchors.horizontalFill: parent;
            }
            LabelFixed {
                text: "http://gitlab.unique-conception.org/sailfish-app/telegra-me";
                color: Theme.rgba (Theme.highlightColor, 0.65);
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                horizontalAlignment: Text.AlignHCenter;
                font.family: Theme.fontFamilyHeading;
                font.underline: true;
                font.pixelSize: Theme.fontSizeSmall;
                ExtraAnchors.horizontalFill: parent;

                MouseArea {
                    anchors.fill: parent;
                    anchors.margins: -Theme.paddingMedium;
                    onClicked: {
                        Qt.openUrlExternally (parent.text);
                    }
                }
            }
            LabelFixed {
                text: qsTr ("(no account required to get sources, but you can request an account if you want to contribute)");
                opacity: 0.65;
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                horizontalAlignment: Text.AlignHCenter;
                font.family: Theme.fontFamilyHeading;
                font.pixelSize: Theme.fontSizeSmall;
                ExtraAnchors.horizontalFill: parent;
            }
            Rectangle {
                color: Theme.secondaryColor;
                implicitHeight: 1;
                ExtraAnchors.horizontalFill: parent;
            }
            LabelFixed {
                text: qsTr ("Donations are gladly accepted ;-)");
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
                horizontalAlignment: Text.AlignHCenter;
                font.bold: true;
                font.family: Theme.fontFamilyHeading;
                font.pixelSize: Theme.fontSizeMedium;
                ExtraAnchors.horizontalFill: parent;
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
                    Qt.openUrlExternally ("https://paypal.me/ThomasBOUTROUE");
                }

                Rectangle {
                    color: Theme.rgba ((parent.pressed ? Theme.highlightColor : Theme.primaryColor), 0.15);
                    radius: Theme.paddingSmall;
                    antialiasing: true;
                    anchors.fill: parent;
                }
                LabelFixed {
                    id: lbl;
                    text: qsTr ("Donate with Paypal");
                    anchors.centerIn: parent;
                }
            }
            Item {
                Container.forcedHeight: Theme.paddingLarge;
            }
        }
    }
    VerticalScrollDecorator {
        flickable: flickerAbout;
    }
}
