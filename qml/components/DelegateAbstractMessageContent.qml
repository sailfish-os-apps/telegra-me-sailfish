import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;
import QtQml.Models 2.2;

ColumnContainer {
    id: self;

    property int optimalWidth : 0;

    property TD_Chat    chatItem    : null;
    property TD_Message messageItem : null;

    property ObjectModel additionalContextMenuItems : null;
}
