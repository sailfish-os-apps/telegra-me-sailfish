#ifndef QTTDLIBGLOBAL_H
#define QTTDLIBGLOBAL_H

#include <QAudioEncoderSettings>
#include <QAudioRecorder>
#include <QDir>
#include <QMimeDatabase>
#include <QObject>
#include <QQmlEngine>
#include <QSortFilterProxyModel>
#include <QStringBuilder>
#include <QTimer>
#include <QtMath>
#include <QUrl>
#include <QSettings>

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
    Q_TDLIB_PROPERTY_SUBOBJECT   (connectionState,       QtTdLibConnectionState)
    Q_TDLIB_PROPERTY_SUBOBJECT   (authorizationState, QtTdLibAuthorizationState)
    QML_OBJMODEL_PROPERTY        (chatsList,                        QtTdLibChat)
    QML_OBJMODEL_PROPERTY        (contactsList,                     QtTdLibUser)
    QML_OBJMODEL_PROPERTY        (stickerSetsList,        QtTdLibStickerSetInfo)
    QML_OBJMODEL_PROPERTY        (savedAnimationsList,         QtTdLibAnimation)
    QML_READONLY_VAR_PROPERTY    (recordingDuration,                        int)
    QML_READONLY_VAR_PROPERTY    (unreadMessagesCount,                      int)
    QML_READONLY_VAR_PROPERTY    (unreadMessagesCountWithMuted,             int)
    QML_READONLY_VAR_PROPERTY    (selectedPhotosCount,                      int)
    QML_READONLY_VAR_PROPERTY    (selectedVideosCount,                      int)
    QML_READONLY_PTR_PROPERTY    (currentChat,                      QtTdLibChat)
    QML_WRITABLE_PTR_PROPERTY    (currentMessageContent,  QtTdLibMessageContent)
    QML_CONSTANT_PTR_PROPERTY    (sortedChatsList,        QSortFilterProxyModel)
    QML_CONSTANT_PTR_PROPERTY    (sortedContactsList,     QSortFilterProxyModel)
    QML_WRITABLE_VAR_PROPERTY    (sendTextOnEnterKey,                      bool)
    QML_WRITABLE_CSTREF_PROPERTY (replyingToMessageId,                  QString)

public:
    explicit QtTdLibGlobal (QObject * parent = Q_NULLPTR);
    virtual ~QtTdLibGlobal (void);

    static QObject * qmlSingletonFactory (QQmlEngine * qmlEngine, QJSEngine * scriptEngine);

    enum LoadMode {
        LOAD_NONE = 0,
        LOAD_INIT,
        LOAD_NEWER,
        LOAD_OLDER,
    };
    Q_ENUM (LoadMode)

    Q_INVOKABLE void        send (const QJsonObject & json) const;
    Q_INVOKABLE QJsonObject exec (const QJsonObject & json) const;

    Q_INVOKABLE QString formatSize (const int bytes) const;
    Q_INVOKABLE QString formatTime (const int msecs, const bool showHours = true) const;

    Q_INVOKABLE QVariantList parseWaveform (const QString & bytes) const;

    Q_INVOKABLE QString urlFromLocalPath (const QString & path) const;
    Q_INVOKABLE QString localPathFromUrl (const QString & url) const;

    Q_INVOKABLE QString getMimeTypeForPath    (const QString & path) const;
    Q_INVOKABLE QString getSvgIconForMimeType (const QString & type) const;

    Q_INVOKABLE QtTdLibFile       * getFileItemById       (const qint32    id) const;
    Q_INVOKABLE QtTdLibUser       * getUserItemById       (const qint32    id) const;
    Q_INVOKABLE QtTdLibBasicGroup * getBasicGroupItemById (const qint32    id) const;
    Q_INVOKABLE QtTdLibSupergroup * getSupergroupItemById (const qint32    id) const;
    Q_INVOKABLE QtTdLibChat       * getChatItemById       (const QString & id) const;

    QtTdLibChat * getChatItemById (const qint64 id) const;

    Q_INVOKABLE void selectPhoto       (const QString & path, const int width, const int height);
    Q_INVOKABLE void deselectPhoto     (const QString & path);
    Q_INVOKABLE bool isPhotoSelected   (const QString & path) const;
    Q_INVOKABLE void unselectAllPhotos (void);

    Q_INVOKABLE void selectVideo       (const QString & path, const int width, const int height, const int duration);
    Q_INVOKABLE void deselectVideo     (const QString & path);
    Q_INVOKABLE bool isVideoSelected   (const QString & path) const;
    Q_INVOKABLE void unselectAllVideos (void);

    Q_INVOKABLE void setUserOnlineState (const bool online);

    Q_INVOKABLE void createPrivateChat     (QtTdLibUser * userItem);

    Q_INVOKABLE void showChat              (QtTdLibChat * chatItem);
    Q_INVOKABLE void openChat              (QtTdLibChat * chatItem);
    Q_INVOKABLE void closeChat             (QtTdLibChat * chatItem);
    Q_INVOKABLE void markAllMessagesAsRead (QtTdLibChat * chatItem);
    Q_INVOKABLE void togglePinChat         (QtTdLibChat * chatItem);

    Q_INVOKABLE void loadSingleMessageRef (QtTdLibChat * chatItem, const qint64 messageId);
    Q_INVOKABLE void loadInitialMessage   (QtTdLibChat * chatItem, const qint64 messageId);
    Q_INVOKABLE void loadOlderMessages    (QtTdLibChat * chatItem, const int count = 15);
    Q_INVOKABLE void loadNewerMessages    (QtTdLibChat * chatItem, const int count = 15);

    Q_INVOKABLE void removeMessage (QtTdLibChat * chatItem, QtTdLibMessage * messageItem, const bool forAll = false);

    Q_INVOKABLE void refreshBasicGroupFullInfo (QtTdLibBasicGroup * basicGroupItem);
    Q_INVOKABLE void refreshSupergroupFullInfo (QtTdLibSupergroup * supergroupItem);
    Q_INVOKABLE void refreshSupergroupMembers  (QtTdLibSupergroup * supergroupItem, const int count, const int offset = 0);

    Q_INVOKABLE void sendMessageText      (QtTdLibChat * chatItem, const QString & text);
    Q_INVOKABLE void sendMessagePhoto     (QtTdLibChat * chatItem, const bool groupInAlbum = true, const QString & caption = "");
    Q_INVOKABLE void sendMessageVideo     (QtTdLibChat * chatItem, const bool groupInAlbum = true, const QString & caption = "");
    Q_INVOKABLE void sendMessageDocument  (QtTdLibChat * chatItem, const QString & path, const QString & caption = "");
    Q_INVOKABLE void sendMessageVoiceNote (QtTdLibChat * chatItem, const QString & recording);
    Q_INVOKABLE void sendMessageSticker   (QtTdLibChat * chatItem, QtTdLibSticker * stickerItem);

    Q_INVOKABLE bool    startRecordingAudio  (void);
    Q_INVOKABLE QString stopRecordingAudio   (void);
    Q_INVOKABLE void    removeRecording      (const QString & path);

signals:
    void showChatRequested (QtTdLibChat * chatItem);

protected slots:
    void onFrame (const QJsonObject & json);

protected:
    QJsonValue createFormattedTextJson (const QString & text);

private:
    const QString DBUS_SERVICE_NAME;
    const QString DBUS_OBJECT_PATH;
    const QString DBUS_INTERFACE;
    const QHash<QString, QString> SVG_ICON_FOR_MIMETYPE;

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
    QMimeDatabase m_mimeDb;
};

#endif // QTTDLIBGLOBAL_H
