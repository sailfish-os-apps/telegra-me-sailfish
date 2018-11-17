import QtQuick 2.6;
import Sailfish.Silica 1.0;

CoverBackground {
    id: cover;

    property alias label : lbl.text;
    property alias count : cnt.text;

    Column {
        anchors.centerIn: parent;

        Label {
            id: cnt;
            color: Theme.highlightColor;
            font.pixelSize: Theme.fontSizeExtraLarge;
            anchors.horizontalCenter: parent.horizontalCenter;
        }
        Label {
            id: lbl;
            anchors.horizontalCenter: parent.horizontalCenter;
        }
    }
}
