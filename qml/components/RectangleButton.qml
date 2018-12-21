import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;

MouseArea {
    id: btn;
    opacity: (enabled ? 1.0 : 0.35);
    implicitWidth: Theme.itemSizeSmall;
    implicitHeight: Theme.itemSizeSmall;

    property int    size    : Theme.iconSizeMedium;
    property bool   active  : false;
    property bool   rounded : true;
    property string icon    : "";

    Rectangle {
        color: Theme.rgba ((active || pressed ? Theme.highlightColor : Theme.primaryColor), (active ? 0.35 : 0.15));
        radius: (rounded ? Theme.paddingSmall : 0);
        antialiasing: rounded;
        anchors.fill: parent;
    }
    Image {
        source: "image://theme/%1?%2".arg (icon).arg (active ? Theme.highlightColor : Theme.primaryColor);
        sourceSize: Qt.size (size, size);
        anchors.centerIn: parent;
    }
}
