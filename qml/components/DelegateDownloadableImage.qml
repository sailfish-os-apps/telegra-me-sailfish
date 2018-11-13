import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;

Item {
    implicitWidth: Theme.iconSizeMedium;
    implicitHeight: Theme.iconSizeMedium;
    Component.onCompleted: { download (); }
    onDownloadableChanged: { download (); }
    onDownloadingChanged:  { download (); }
    onDownloadedChanged:   { download (); }

    property int size : Theme.iconSizeMedium;

    property bool background : true;
    property bool autoDownload : true;

    property TD_File fileItem : null;

    readonly property TD_LocalFile  local  : (fileItem ? fileItem.local : null);
    readonly property TD_RemoteFile remote : (fileItem ? fileItem.remote : null);

    readonly property bool downloadable : (local && local.canBeDownloaded);
    readonly property bool downloading  : (local && local.isDownloadingActive);
    readonly property bool downloaded   : (local && local.isDownloadingCompleted);

    readonly property bool uploading : (remote && remote.isUploadingActive);
    readonly property bool uploaded  : (remote && remote.isUploadingCompleted);

    readonly property bool valid : (img.status === Image.Ready);

    function download (force) {
        if ((autoDownload || force) && downloadable && !downloading && !downloaded ) {
            TD_Global.send ({
                                "@type" : "downloadFile",
                                "file_id" : fileItem.id,
                                "priority" : 1,
                            });
        }
    }

    Rectangle {
        color: "gray";
        opacity: 0.35;
        visible: background;
        anchors.fill: parent;
    }
    Image {
        id: img;
        cache: true;
        source: (downloaded && local.path !== "" ? TD_Global.urlFromLocalPath (local.path) : "");
        fillMode: Image.PreserveAspectFit;
        sourceSize: Qt.size (width, height);
        asynchronous: true;
        verticalAlignment: Image.AlignVCenter;
        horizontalAlignment: Image.AlignHCenter;
        anchors.fill: parent;
    }
    ProgressCircle {
        value: (downloading
                ? (local && fileItem ? local.downloadedSize / Math.max (fileItem.size, 1) : 0)
                : (uploading
                   ? (remote && fileItem ? remote.uploadedSize / Math.max (fileItem.size, 1) : 0)
                   : 0));
        visible: (downloading || uploading);
        implicitWidth: BusyIndicatorSize.Medium;
        implicitHeight: BusyIndicatorSize.Medium;
        anchors.centerIn: parent;
    }
}
