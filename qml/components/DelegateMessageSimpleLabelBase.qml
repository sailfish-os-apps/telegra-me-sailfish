import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;

DelegateAbstractMessageContent {
    id: self;
    spacing: Theme.paddingSmall;

    property alias label : lbl.text;
    property alias color : lbl.color;

    LabelFixed {
        id: lbl;
        color: Theme.secondaryHighlightColor;
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
        font.italic: true;
        font.pixelSize: Theme.fontSizeSmall;
        ExtraAnchors.horizontalFill: parent;
    }
}
