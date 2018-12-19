import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;

TextEdit {
    id: self;
    text: (formattedTextItem ? formattedTextItem.text : "");
    color: Theme.primaryColor;
    visible: (text !== "");
    readOnly: true;
    wrapMode: TextEdit.Wrap;
    selectByMouse: false;
    selectByKeyboard: false;
    font.family: Theme.fontFamily;
    font.pixelSize: Theme.fontSizeMedium;
    onLinkActivated: {
        console.log ("LINK", link);
        if (link.indexOf ("td:") === 0) {
            // TODO : parse and activate
        }
        else {
            Qt.openUrlExternally (link);
        }
    }

    property TD_FormattedText formattedTextItem : null;

    TextFormatter {
        id: formatter;
        entities: (formattedTextItem ? formattedTextItem.entities : null);
        textDocument: self.textDocument;
        primaryColor: Theme.primaryColor;
        secondaryColor: Theme.secondaryColor;
        highlightColor: Theme.highlightColor;
    }
}
