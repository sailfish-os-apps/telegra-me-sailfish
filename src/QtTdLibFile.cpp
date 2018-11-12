
#include "QtTdLibFile.h"

QtTdLibLocalFile::QtTdLibLocalFile (QObject * parent)
    : QtTdLibAbstractObject { QtTdLibObjectType::LOCAL_FILE, parent }
{ }

void QtTdLibLocalFile::updateFromJson (const QJsonObject & json) {
    set_canBeDeleted_withJSON           (json ["can_be_deleted"]);
    set_canBeDownloaded_withJSON        (json ["can_be_downloaded"]);
    set_downloadedPrefixSize_withJSON   (json ["downloaded_prefix_size"]);
    set_downloadedSize_withJSON         (json ["downloaded_size"]);
    set_isDownloadingActive_withJSON    (json ["is_downloading_active"]);
    set_isDownloadingCompleted_withJSON (json ["is_downloading_completed"]);
    set_path_withJSON                   (json ["path"]);
}

QtTdLibRemoteFile::QtTdLibRemoteFile (QObject * parent)
    : QtTdLibAbstractObject { QtTdLibObjectType::REMOTE_FILE, parent }
{ }

void QtTdLibRemoteFile::updateFromJson (const QJsonObject & json) {
    set_id_withJSON                   (json ["id"]);
    set_isUploadingActive_withJSON    (json ["is_uploading_active"]);
    set_isUploadingCompleted_withJSON (json ["is_uploading_completed"]);
    set_uploadedSize_withJSON         (json ["uploaded_size"]);
}

QtTdLibFile::QtTdLibFile (const qint32 id, QObject * parent)
    : QtTdLibAbstractInt32IdObject { QtTdLibObjectType::FILE, id, parent }
{
    QtTdLibCollection::allFiles.insert (id, this);
}

void QtTdLibFile::updateFromJson (const QJsonObject & json) {
    set_size_withJSON          (json ["size"]);
    set_expectedSize_withJSON  (json ["expected_size"]);
    set_local_withJSON         (json ["local"],  &QtTdLibAbstractObject::create<QtTdLibLocalFile>);
    set_remote_withJSON        (json ["remote"], &QtTdLibAbstractObject::create<QtTdLibRemoteFile>);
}
