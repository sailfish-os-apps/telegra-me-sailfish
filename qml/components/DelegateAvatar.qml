import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;
import QtGraphicalEffects 1.0;

Item {
    id: self;
    implicitWidth: size;
    implicitHeight: size;

    property alias size     : img.size;
    property alias fileItem : img.fileItem;

    OpacityMask {
        source: ShaderEffectSource {
            hideSource: true;
            sourceItem: DelegateDownloadableImage {
                id: img;
                anchors.fill: parent;
                autoDownload: true;
            }
        }
        maskSource: maskAvatar;
        anchors.fill: parent;
    }
}
