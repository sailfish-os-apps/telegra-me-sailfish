import QtQuick 2.6;
import Sailfish.Silica 1.0;

CoverBackground {
    id: cover;

    property alias label : lbl.text;

    Label {
        id: lbl;
        anchors.centerIn: parent;
    }
}
