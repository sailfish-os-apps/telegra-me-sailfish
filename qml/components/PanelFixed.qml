import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;

MouseArea {
    id: self;
    onPressed: { }
    onReleased: { }

    Rectangle {
        color: Theme.highlightBackgroundColor;
        opacity: 0.15;
        anchors.fill: parent;
    }
    Rectangle {
        color: Theme.primaryColor;
        opacity: 0.35;
        anchors.fill: parent;
    }
    Rectangle {
        color: Helpers.panelColor;
        opacity: 0.85;
        anchors.fill: parent;
    }
}
