import QtQuick 2.6;
import harbour.Telegrame 1.0;

QtObject {
    id: helper;
    onDownloadableChanged: { tryDownload (); }
    onDownloadingChanged:  { tryDownload (); }
    onDownloadedChanged:   { tryDownload (); }
    Component.onCompleted: { tryDownload (); }

    property TD_File fileItem : null;

    property bool autoDownload : false;

    readonly property TD_LocalFile  localFileItem  : (fileItem ? fileItem.local  : null);
    readonly property TD_RemoteFile remoteFileItem : (fileItem ? fileItem.remote : null);

    readonly property bool downloadable : (localFileItem && localFileItem.canBeDownloaded);
    readonly property bool downloading  : (localFileItem && localFileItem.isDownloadingActive);
    readonly property bool downloaded   : (localFileItem && localFileItem.isDownloadingCompleted);

    readonly property bool uploading : (remoteFileItem && remoteFileItem.isUploadingActive);
    readonly property bool uploaded  : (remoteFileItem && remoteFileItem.isUploadingCompleted);

    readonly property real progress : ((downloading && localFileItem && fileItem)
                                       ? (localFileItem.downloadedSize / Math.max (fileItem.size, localFileItem.downloadedSize))
                                       : ((uploading && remoteFileItem && fileItem)
                                          ? (remoteFileItem.uploadedSize / Math.max (fileItem.size, remoteFileItem.uploadedSize))
                                          : 0.0));

    readonly property string url : ((localFileItem && localFileItem.path !== "")
                                    ? TD_Global.urlFromLocalPath (localFileItem.path)
                                    : "");

    function tryDownload (force) {
        if ((autoDownload || force) && fileItem && localFileItem && downloadable && !downloading && !downloaded) {
            TD_Global.send ({
                                "@type" : "downloadFile",
                                "file_id" : fileItem.id,
                                "priority" : 1,
                            });
        }
    }

    function cancelDownload () {
        if (fileItem && localFileItem && downloadable && downloading && !downloaded) {
            TD_Global.send ({
                                "@type" : "cancelDownloadFile",
                                "file_id" : fileItem.id,
                                "only_if_pending" : false,
                            });
        }
    }
}
