#ifndef QtTdLibFile_H
#define QtTdLibFile_H

#include "QtTdLibCommon.h"

class QtTdLibLocalFile : public QtTdLibAbstractObject {
    Q_OBJECT
    Q_TDLIB_PROPERTY_STRING (path)
    Q_TDLIB_PROPERTY_BOOL   (canBeDownloaded)
    Q_TDLIB_PROPERTY_BOOL   (canBeDeleted)
    Q_TDLIB_PROPERTY_BOOL   (isDownloadingActive)
    Q_TDLIB_PROPERTY_BOOL   (isDownloadingCompleted)
    Q_TDLIB_PROPERTY_INT32  (downloadedPrefixSize)
    Q_TDLIB_PROPERTY_INT32  (downloadedSize)

public:
    explicit QtTdLibLocalFile (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibRemoteFile : public QtTdLibAbstractObject {
    Q_OBJECT
    Q_TDLIB_PROPERTY_STRING (id)
    Q_TDLIB_PROPERTY_BOOL   (isUploadingActive)
    Q_TDLIB_PROPERTY_BOOL   (isUploadingCompleted)
    Q_TDLIB_PROPERTY_INT32  (uploadedSize)

public:
    explicit QtTdLibRemoteFile (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibFile : public QtTdLibAbstractInt32IdObject {
    Q_OBJECT
    Q_TDLIB_PROPERTY_INT32     (size)
    Q_TDLIB_PROPERTY_INT32     (expectedSize)
    Q_TDLIB_PROPERTY_SUBOBJECT (local,    QtTdLibLocalFile)
    Q_TDLIB_PROPERTY_SUBOBJECT (remote,  QtTdLibRemoteFile)

public:
    explicit QtTdLibFile (const qint32 id = 0, QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

#endif // QtTdLibFile_H
