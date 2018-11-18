import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import "../components";

CoverBackground {
    id: cover;

    property alias label : lbl.text;
    property alias count : cnt.text;

    Image {
        source: "qrc:///images/Telegram_logo.svg";
        height: width;
        opacity: 0.15;
        anchors {
            topMargin: (cover.height * +0.05);
            leftMargin: (cover.width * -0.05);
            rightMargin: (cover.width * +0.05);
        }
        ExtraAnchors.topDock: parent;
    }
    Column {
        spacing: Theme.paddingLarge;
        anchors.centerIn: parent;

        LabelFixed {
            text: "Telegra'me";
            font.pixelSize: Theme.fontSizeLarge;
            anchors.horizontalCenter: parent.horizontalCenter;
        }
        LabelFixed {
            id: cnt;
            color: Theme.highlightColor;
            font.pixelSize: Theme.fontSizeHuge;
            anchors.horizontalCenter: parent.horizontalCenter;
        }
        LabelFixed {
            text: qsTr ("unread\nmessages");
            font.pixelSize: Theme.fontSizeLarge;
            horizontalAlignment: Text.AlignHCenter;
            anchors.horizontalCenter: parent.horizontalCenter;
        }
        Rectangle {
            color: Theme.secondaryColor;
            implicitWidth: (cover.width * 0.65);
            implicitHeight: 1;
            anchors.horizontalCenter: parent.horizontalCenter;
        }
        LabelFixed {
            id: lbl;
            anchors.horizontalCenter: parent.horizontalCenter;
        }
    }
}
