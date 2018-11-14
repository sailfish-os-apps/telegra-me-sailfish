import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;

Item {
    implicitWidth: Theme.iconSizeMedium;
    implicitHeight: Theme.iconSizeMedium;

    property int size : Theme.iconSizeMedium;

    property alias cache        : img.cache;
    property alias asynchronous : img.asynchronous;
    property alias fileItem     : helper.fileItem;
    property alias background   : rect.visible;
    property alias autoDownload : helper.autoDownload;

    readonly property bool valid : (img.status === Image.Ready);

    HelperFileState {
        id: helper;
    }
    Rectangle {
        id: rect;
        color: "gray";
        opacity: 0.35;
        anchors.fill: parent;
    }
    Image {
        id: img;
        cache: true;
        source: helper.url;
        fillMode: Image.PreserveAspectFit;
        sourceSize: Qt.size (width, height);
        asynchronous: true;
        verticalAlignment: Image.AlignVCenter;
        horizontalAlignment: Image.AlignHCenter;
        anchors.fill: parent;
        //autoTransform: true;
    }
    Image {
        source: ((helper.downloadable && !helper.downloading && !helper.downloaded)
                 ? "image://theme/icon-m-cloud-download?#808080"
                 : "");
        sourceSize: Qt.size (Theme.iconSizeMedium, Theme.iconSizeMedium);
        anchors.centerIn: parent;
    }
    ProgressCircle {
        value: helper.progress;
        visible: (helper.downloading || helper.uploading);
        implicitWidth: BusyIndicatorSize.Medium;
        implicitHeight: BusyIndicatorSize.Medium;
        anchors.centerIn: parent;
    }
}
