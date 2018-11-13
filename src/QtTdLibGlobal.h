#ifndef QTTDLIBGLOBAL_H
#define QTTDLIBGLOBAL_H

#include <QAudioDecoder>
#include <QAudioRecorder>
#include <QObject>
#include <QQmlEngine>

#include "QtTdLibCommon.h"
#include "QtTdLibJsonWrapper.h"
#include "QtTdLibConnection.h"
#include "QtTdLibAuth.h"
#include "QtTdLibUser.h"
#include "QtTdLibFile.h"
#include "QtTdLibChat.h"
#include "QtTdLibMessage.h"

#include "QmlPropertyHelpers.h"
#include "QQmlObjectListModel.h"

class QtTdLibGlobal : public QObject {
    Q_OBJECT
    Q_TDLIB_PROPERTY_SUBOBJECT (connectionState,       QtTdLibConnectionState)
    Q_TDLIB_PROPERTY_SUBOBJECT (authorizationState, QtTdLibAuthorizationState)
    QML_OBJMODEL_PROPERTY      (chatsList,                        QtTdLibChat)
    QML_READONLY_VAR_PROPERTY  (recordingDuration,                        int)
    QML_READONLY_VAR_PROPERTY  (selectedPhotosCount,                      int)
    QML_READONLY_VAR_PROPERTY  (selectedVideosCount,                      int)

public:
    explicit QtTdLibGlobal (QObject * parent = Q_NULLPTR);
    virtual ~QtTdLibGlobal (void);

    static QObject * qmlSingletonFactory (QQmlEngine * qmlEngine, QJSEngine * scriptEngine);

    Q_INVOKABLE void        send (const QJsonObject & json) const;
    Q_INVOKABLE QJsonObject exec (const QJsonObject & json) const;

    Q_INVOKABLE QString formatSize (const int bytes) const;
    Q_INVOKABLE QString formatTime (const int msecs, const bool showHours = true) const;

    Q_INVOKABLE QVariantList parseWaveform (const QString & bytes) const;

    Q_INVOKABLE QString urlFromLocalPath (const QString & path) const;
    Q_INVOKABLE QString localPathFromUrl (const QString & url) const;

    Q_INVOKABLE QString getSvgIconForMimeType (const QString & type) const;

    Q_INVOKABLE QtTdLibFile * getFileItemById (const qint32 id) const;
    Q_INVOKABLE QtTdLibUser * getUserItemById (const qint32 id) const;
    Q_INVOKABLE QtTdLibChat * getChatItemById (const qint64 id) const;

    Q_INVOKABLE void selectPhoto       (const QString & path, const int width, const int height);
    Q_INVOKABLE void deselectPhoto     (const QString & path);
    Q_INVOKABLE bool isPhotoSelected   (const QString & path) const;
    Q_INVOKABLE void unselectAllPhotos (void);

    Q_INVOKABLE void selectVideo       (const QString & path, const int width, const int height, const int duration);
    Q_INVOKABLE void deselectVideo     (const QString & path);
    Q_INVOKABLE bool isVideoSelected   (const QString & path) const;
    Q_INVOKABLE void unselectAllVideos (void);

    Q_INVOKABLE void sendMessageText      (QtTdLibChat * chatItem, const QString & text);
    Q_INVOKABLE void sendMessagePhoto     (QtTdLibChat * chatItem, const bool groupInAlbum = true);
    Q_INVOKABLE void sendMessageVideo     (QtTdLibChat * chatItem, const bool groupInAlbum = true);
    Q_INVOKABLE void sendMessageVoiceNote (QtTdLibChat * chatItem, const QString & recording);

    Q_INVOKABLE bool    startRecordingAudio  (void);
    Q_INVOKABLE QString stopRecordingAudio   (void);

protected:
    void onFrame (const QJsonObject & json);

private:
    const QHash<QString, QString> m_svgIconForMimetype;

    struct SelectionPhoto {
        QString path;
        int width;
        int height;
    };
    QList<SelectionPhoto *> m_selectedPhotosList;

    struct SelectionVideo {
        QString path;
        int width;
        int height;
        int duration;
    };
    QList<SelectionVideo *> m_selectedVideosList;

    QtTdLibJsonWrapper * m_tdLibJsonWrapper;
    QAudioRecorder * m_audioRecorder;
};

#endif // QTTDLIBGLOBAL_H
