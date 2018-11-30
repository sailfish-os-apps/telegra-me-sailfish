#ifndef QTTDLIBGLOBAL_H
#define QTTDLIBGLOBAL_H

#include <QAudioEncoderSettings>
#include <QAudioRecorder>
#include <QDBusAbstractAdaptor>
#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDir>
#include <QMimeDatabase>
#include <QObject>
#include <QQmlEngine>
#include <QSortFilterProxyModel>
#include <QStringBuilder>
#include <QTimer>
#include <QtMath>
#include <QUrl>

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

class DBusAdaptor: public QDBusAbstractAdaptor {
    Q_OBJECT
    Q_CLASSINFO ("D-Bus Interface", "org.uniqueconception.telegrame")
    Q_CLASSINFO ("D-Bus Introspection", ""
                "  <interface name=\"org.blacksailer.depecher\">\n"
                "    <method name=\"showChat\">\n"
                "      <arg direction=\"in\" type=\"x\" name=\"chatId\"/>\n"
                "      <annotation value=\"true\" name=\"org.freedesktop.DBus.Method.NoReply\"/>\n"
                "    </method>\n"
                "  </interface>\n"
                "")
public:
    explicit DBusAdaptor (QObject * parent);
    virtual ~DBusAdaptor (void);

public slots:
    Q_NOREPLY void showChat (qlonglong chatId);
};

class QtTdLibGlobal : public QObject {
    Q_OBJECT
    Q_TDLIB_PROPERTY_SUBOBJECT (connectionState,       QtTdLibConnectionState)
    Q_TDLIB_PROPERTY_SUBOBJECT (authorizationState, QtTdLibAuthorizationState)
    QML_OBJMODEL_PROPERTY      (chatsList,                        QtTdLibChat)
    QML_OBJMODEL_PROPERTY      (stickerSetsList,        QtTdLibStickerSetInfo)
    QML_OBJMODEL_PROPERTY      (savedAnimationsList,         QtTdLibAnimation)
    QML_READONLY_VAR_PROPERTY  (recordingDuration,                        int)
    QML_READONLY_VAR_PROPERTY  (unreadMessagesCount,                      int)
    QML_READONLY_VAR_PROPERTY  (selectedPhotosCount,                      int)
    QML_READONLY_VAR_PROPERTY  (selectedVideosCount,                      int)
    QML_READONLY_PTR_PROPERTY  (currentChat,                      QtTdLibChat)
    QML_WRITABLE_PTR_PROPERTY  (currentMessageContent,  QtTdLibMessageContent)
    QML_CONSTANT_PTR_PROPERTY  (sortedChatsList,        QSortFilterProxyModel)
    QML_CONSTANT_PTR_PROPERTY  (dbusAdaptor,                      DBusAdaptor)

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

    Q_INVOKABLE void openChat              (QtTdLibChat * chatItem);
    Q_INVOKABLE void closeChat             (QtTdLibChat * chatItem);
    Q_INVOKABLE void markAllMessagesAsRead (QtTdLibChat * chatItem);

    Q_INVOKABLE void loadMoreMessages (QtTdLibChat * chatItem, const int count);

    Q_INVOKABLE void removeMessage (QtTdLibChat * chatItem, QtTdLibMessage * messageItem, const bool forAll = false);

    Q_INVOKABLE void refreshBasicGroupFullInfo (QtTdLibBasicGroup * basicGroupItem);
    Q_INVOKABLE void refreshSupergroupFullInfo (QtTdLibSupergroup * supergroupItem);
    Q_INVOKABLE void refreshSupergroupMembers  (QtTdLibSupergroup * supergroupItem, const int count, const int offset = 0);

    Q_INVOKABLE void sendMessageText      (QtTdLibChat * chatItem, const QString & text);
    Q_INVOKABLE void sendMessagePhoto     (QtTdLibChat * chatItem, const bool groupInAlbum = true);
    Q_INVOKABLE void sendMessageVideo     (QtTdLibChat * chatItem, const bool groupInAlbum = true);
    Q_INVOKABLE void sendMessageVoiceNote (QtTdLibChat * chatItem, const QString & recording);
    Q_INVOKABLE void sendMessageSticker   (QtTdLibChat * chatItem, QtTdLibSticker * stickerItem);
    Q_INVOKABLE void sendMessageDocument  (QtTdLibChat * chatItem, const QString & path);

    Q_INVOKABLE bool    startRecordingAudio  (void);
    Q_INVOKABLE QString stopRecordingAudio   (void);

signals:
    void showChatRequested (const QString & chatId);
    void autoScrollDownRequested (const bool active);

protected:
    void onFrame (const QJsonObject & json);
    void onPrefetcherTick (void);

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
    QTimer * m_autoPreFetcher;
    QMimeDatabase m_mimeDb;
};

#endif // QTTDLIBGLOBAL_H
