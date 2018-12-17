
#include "QtTdLibGlobal.h"

QtTdLibGlobal::QtTdLibGlobal (QObject * parent)
    : QObject { parent }
    , m_chatsList { new QQmlObjectListModel<QtTdLibChat> { this } }
    , m_contactsList { new QQmlObjectListModel<QtTdLibUser> { this } }
    , m_stickerSetsList { new QQmlObjectListModel<QtTdLibStickerSetInfo> { this } }
    , m_savedAnimationsList { new QQmlObjectListModel<QtTdLibAnimation> { this } }
    , m_recordingDuration { 0 }
    , m_unreadMessagesCount { 0 }
    , m_unreadMessagesCountWithMuted { 0 }
    , m_selectedPhotosCount { 0 }
    , m_selectedVideosCount { 0 }
    , m_currentChat { Q_NULLPTR }
    , m_currentMessageContent { Q_NULLPTR }
    , m_sortedChatsList { new QSortFilterProxyModel { this } }
    , m_sortedContactsList { new QSortFilterProxyModel { this } }
    , m_sendTextOnEnterKey { false }
    , SVG_ICON_FOR_MIMETYPE {
{ "image/png", "image" },
{ "image/jpeg", "image" },
{ "image/gif", "image" },
{ "image/svg", "drawing" },
{ "image/svg+xml", "drawing" },
{ "application/vnd.oasis.opendocument.graphics", "drawing" },
{ "audio/mpeg", "sound" },
{ "audio/x-wav", "sound" },
{ "audio/midi", "sound" },
{ "video/mp4", "video" },
{ "text/x-csrc", "code" },
{ "text/x-chdr", "code" },
{ "text/x-c++src", "code" },
{ "text/x-c++hdr", "code" },
{ "text/x-qml", "code" },
{ "text/x-java", "code" },
{ "text/css", "code" },
{ "application/javascript", "code" },
{ "application/xml", "xml" },
{ "application/x-shellscript", "script" },
{ "application/x-perl", "script" },
{ "application/x-object", "binary" },
{ "application/octet-stream", "binary" },
{ "application/x-cd-image", "disk-image" },
{ "application/zip", "archive" },
{ "application/x-xz-compressed-tar", "archive" },
{ "application/x-compressed-tar", "archive" },
{ "application/x-rar", "archive" },
{ "application/x-rpm", "archive" },
{ "application/gzip", "archive" },
{ "application/vnd.debian.binary-package", "archive" },
{ "application/vnd.android.package-archive", "archive" },
{ "application/x-7z-compressed", "archive" },
{ "application/x-bzip-compressed-tar", "archive" },
{ "text/x-makefile", "text" },
{ "text/x-log", "text" },
{ "text/x-theme", "text" },
{ "text/csv", "text" },
{ "text/plain", "text" },
{ "text/vcard", "text" },
{ "text/markdown", "text" },
{ "application/json", "text" },
{ "application/pdf", "pdf" },
{ "application/vnd.oasis.opendocument.text", "document" },
{ "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "document" },
{ "application/msword", "document" },
{ "application/vnd.oasis.opendocument.spreadsheet", "spreadsheet" },
{ "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "spreadsheet" },
{ "application/vnd.ms-excel", "spreadsheet" },
{ "application/ms-excel", "spreadsheet" },
{ "application/vnd.oasis.opendocument.presentation", "slideshow" },
{ "application/vnd.openxmlformats-officedocument.presentationml.presentation", "slideshow" },
{ "application/vnd.ms-powerpoint", "slideshow" },
{ "text/html", "webpage" },
{ "application/sql", "database" },
{ "application/x-sqlite3", "database" },
{ "application/x-executable", "executable" },
{ "application/x-ms-dos-executable", "executable" },
          }
    , m_tdLibJsonWrapper { new QtTdLibJsonWrapper { this } }
    , m_audioRecorder { new QAudioRecorder { this } }
{
    m_sortedChatsList->setSourceModel (m_chatsList);
    m_sortedChatsList->setSortRole (m_chatsList->roleForName ("order"));
    m_sortedChatsList->setDynamicSortFilter (true);
    m_sortedChatsList->sort (0, Qt::DescendingOrder);
    m_sortedContactsList->setSourceModel (m_contactsList);
    m_sortedContactsList->setSortRole (m_contactsList->roleForName ("firstName"));
    m_sortedContactsList->setDynamicSortFilter (true);
    m_sortedContactsList->sort (0, Qt::AscendingOrder);
    QAudioEncoderSettings audioEncoderSettings { };
    audioEncoderSettings.setCodec        ("audio/PCM"); // "audio/speex"
    audioEncoderSettings.setEncodingMode (QMultimedia::TwoPassEncoding);
    audioEncoderSettings.setQuality      (QMultimedia::HighQuality);
    audioEncoderSettings.setSampleRate   (22050);
    m_audioRecorder->setEncodingSettings (audioEncoderSettings);
    m_audioRecorder->setContainerFormat  ("wav"); // "ogg"
    qWarning () << "VOLUME" << m_audioRecorder->volume () << m_audioRecorder->audioInput () << m_audioRecorder->audioInputDescription (m_audioRecorder->audioInput ());
    connect (m_audioRecorder, &QAudioRecorder::durationChanged, [this] (void) {
        if (m_audioRecorder->status () == QMediaRecorder::RecordingStatus || m_audioRecorder->status () == QMediaRecorder::FinalizingStatus) {
            set_recordingDuration (int (m_audioRecorder->duration ()));
        }
    });
    //m_autoPreFetcher->setSingleShot (true);
    //connect (m_autoPreFetcher, &QTimer::timeout, this, &QtTdLibGlobal::onPrefetcherTick);
    connect (m_tdLibJsonWrapper, &QtTdLibJsonWrapper::recv, this, &QtTdLibGlobal::onFrame);
    m_tdLibJsonWrapper->start ();
}

QtTdLibGlobal::~QtTdLibGlobal (void) {
    m_tdLibJsonWrapper->send (QJsonObject {
                                  { "@type", "close" }
                              });
    m_tdLibJsonWrapper->quit ();
    m_tdLibJsonWrapper->wait (10000);
}

QObject * QtTdLibGlobal::qmlSingletonFactory (QQmlEngine * qmlEngine, QJSEngine * scriptEngine) {
    Q_UNUSED (qmlEngine)
    Q_UNUSED (scriptEngine)
    return new QtTdLibGlobal { };
}

void QtTdLibGlobal::send (const QJsonObject & json) const {
    QMetaObject::invokeMethod (m_tdLibJsonWrapper, "send", Qt::QueuedConnection, Q_ARG (QJsonObject, json));
}

QJsonObject QtTdLibGlobal::exec (const QJsonObject & json) const {
    return m_tdLibJsonWrapper->exec (json);
}

QString QtTdLibGlobal::formatSize (const int bytes) const {
    static constexpr int KIB  { 1024 };
    static constexpr int MIB  { 1024 * 1024 };
    static constexpr int GIB  { 1024 * 1024 * 1024 };
    static const QString SIZE { "%1 %2" };
    static const QChar   ZERO { '0' };
    if (bytes > GIB) {
        return SIZE.arg ((qreal (bytes) / qreal (GIB)), 0, 'f', 3, ZERO).arg (tr ("GiB"));
    }
    else if (bytes > MIB) {
        return SIZE.arg ((qreal (bytes) / qreal (MIB)), 0, 'f', 2, ZERO).arg (tr ("MiB"));
    }
    else if (bytes > KIB) {
        return SIZE.arg ((qreal (bytes) / qreal (KIB)), 0, 'f', 1, ZERO).arg (tr ("KiB"));
    }
    else {
        return SIZE.arg (bytes).arg (tr ("B"));
    }
}

QString QtTdLibGlobal::formatTime (const int msecs, const bool showHours) const {
    static const QString FULL { "%1:%2:%3" };
    static const QString MINI { "%1:%2" };
    static const QChar   ZERO { '0' };
    int seconds { msecs / 1000 }, hours { 0 }, minutes { 0 };
    if (showHours) {
        hours = (seconds / 3600);
        seconds -= (hours * 3600);
    }
    minutes = (seconds / 60);
    seconds -= (minutes * 60);
    return (showHours
            ? FULL.arg (hours, 2, 10, ZERO).arg (minutes, 2, 10, ZERO).arg (seconds, 2, 10, ZERO)
            : MINI.arg (minutes, 2, 10, ZERO).arg (seconds, 2, 10, ZERO));
}

QVariantList QtTdLibGlobal::parseWaveform (const QString & bytes) const {
    QVariantList ret { };
    ret.reserve (100);
    const QByteArray tmp = QByteArray::fromBase64 (bytes.toLatin1 ());
    if ((tmp.count () * 8 / 5) >= 100) {
        for (int pos = 0; pos < 100; ++pos) {
            int value = 0;
            for (int bit = 0; bit < 5; ++bit) {
                const int offset = (bit + pos * 5);
                if ((tmp.at (offset / 8) >> (offset % 8)) & 0x1) {
                    value |= (0x1 << bit);
                }
                else {
                    value &= ~(0x1 << bit);
                }
            }
            ret.append (value);
        }
    }
    return ret;
}

QString QtTdLibGlobal::urlFromLocalPath (const QString & path) const {
    return QUrl::fromLocalFile (path).toString ();
}

QString QtTdLibGlobal::localPathFromUrl (const QString & url) const {
    return QUrl (url).toLocalFile ();
}

QString QtTdLibGlobal::getMimeTypeForPath (const QString & path) const {
    return m_mimeDb.mimeTypeForFile (path).name ();
}

QString QtTdLibGlobal::getSvgIconForMimeType (const QString & type) const {
    return SVG_ICON_FOR_MIMETYPE.value (type, "file");
}

QtTdLibFile * QtTdLibGlobal::getFileItemById (const qint32 id) const {
    return QtTdLibCollection::allFiles.value (id, Q_NULLPTR);
}

QtTdLibUser * QtTdLibGlobal::getUserItemById (const qint32 id) const {
    return QtTdLibCollection::allUsers.value (id, Q_NULLPTR);
}

QtTdLibBasicGroup * QtTdLibGlobal::getBasicGroupItemById (const qint32 id) const {
    return QtTdLibCollection::allBasicGroups.value (id, Q_NULLPTR);
}

QtTdLibSupergroup * QtTdLibGlobal::getSupergroupItemById (const qint32 id) const {
    return QtTdLibCollection::allSupergroups.value (id, Q_NULLPTR);
}

QtTdLibChat * QtTdLibGlobal::getChatItemById (const QString & id) const {
    return getChatItemById (id.toLongLong ());
}

QtTdLibChat * QtTdLibGlobal::getChatItemById (const qint64 id) const {
    return QtTdLibCollection::allChats.value (id, Q_NULLPTR);
}

void QtTdLibGlobal::selectPhoto (const QString & path, const int width, const int height) {
    if (!isPhotoSelected (path)) {
        m_selectedPhotosList.append (new SelectionPhoto {
                                         path,
                                         width,
                                         height,
                                     });
        set_selectedPhotosCount (m_selectedPhotosCount +1);
    }
}

void QtTdLibGlobal::deselectPhoto (const QString & path) {
    for (SelectionPhoto * selection : m_selectedPhotosList) {
        if (selection->path == path) {
            m_selectedPhotosList.removeOne (selection);
            set_selectedPhotosCount (m_selectedPhotosCount -1);
            break;
        }
    }
}

bool QtTdLibGlobal::isPhotoSelected (const QString & path) const {
    for (SelectionPhoto * selection : m_selectedPhotosList) {
        if (selection->path == path) {
            return true;
        }
    }
    return false;
}

void QtTdLibGlobal::unselectAllPhotos (void) {
    qDeleteAll (m_selectedPhotosList);
    m_selectedPhotosList.clear ();
    set_selectedPhotosCount (0);
}

void QtTdLibGlobal::selectVideo (const QString & path, const int width, const int height, const int duration) {
    if (!isVideoSelected (path)) {
        m_selectedVideosList.append (new SelectionVideo {
                                         path,
                                         width,
                                         height,
                                         duration,
                                     });
        set_selectedVideosCount (m_selectedVideosCount +1);
    }
}

void QtTdLibGlobal::deselectVideo (const QString & path) {
    for (SelectionVideo * selection : m_selectedVideosList) {
        if (selection->path == path) {
            m_selectedVideosList.removeOne (selection);
            set_selectedVideosCount (m_selectedVideosCount -1);
            break;
        }
    }
}

bool QtTdLibGlobal::isVideoSelected (const QString & path) const {
    for (SelectionVideo * selection : m_selectedVideosList) {
        if (selection->path == path) {
            return true;
        }
    }
    return false;
}

void QtTdLibGlobal::unselectAllVideos (void) {
    qDeleteAll (m_selectedVideosList);
    m_selectedVideosList.clear ();
    set_selectedVideosCount (0);
}

void QtTdLibGlobal::setUserOnlineState (const bool online) {
    send (QJsonObject {
              { "@type", "setOption" },
              { "name", "online" },
              { "value", QJsonObject {
                    { "@type", "optionValueBoolean" },
                    { "value", online },
                }
              },
          });
}

void QtTdLibGlobal::createPrivateChat (QtTdLibUser * userItem) {
    if (userItem != Q_NULLPTR) {
        send (QJsonObject {
                  { "@type", "createPrivateChat" },
                  { "user_id", userItem->get_id_asJSON () },
                  { "@extra", QJsonObject {
                        { "show_chat", true },
                    }
                  }
              });
    }
}

void QtTdLibGlobal::showChat (QtTdLibChat * chatItem) {
    if (chatItem != Q_NULLPTR) {
        qWarning () << "SHOW CHAT" << chatItem->get_id () << chatItem->get_title ();
        emit showChatRequested (chatItem);
    }
}

void QtTdLibGlobal::openChat (QtTdLibChat * chatItem) {
    closeChat (m_currentChat);
    if (chatItem != Q_NULLPTR) {
        chatItem->set_isCurrentChat (true);
        set_currentChat (chatItem);
        send (QJsonObject {
                  { "@type", "openChat" },
                  { "chat_id", chatItem->get_id () },
              });
        loadInitialMessage (chatItem, qMin (chatItem->get_lastReadInboxMessageId (), chatItem->get_lastReceivedMessageId ()));
    }
}

void QtTdLibGlobal::closeChat (QtTdLibChat * chatItem) {
    set_replyingToMessageId ("");
    set_currentMessageContent (Q_NULLPTR);
    if (chatItem != Q_NULLPTR) {
        chatItem->messagesModel.clear ();
        chatItem->set_oldestFetchedMessageId (0); // NOTE : reset lower boundary
        chatItem->set_newestFetchedMessageId (0); // NOTE : reset upper boundary
        chatItem->set_hasReachedFirst (false); // NOTE : reset start flag
        chatItem->set_hasReachedLast  (false); // NOTE : reset end flag
        chatItem->set_isCurrentChat   (false);
        set_currentChat (Q_NULLPTR);
        send (QJsonObject {
                  { "@type", "closeChat" },
                  { "chat_id", chatItem->get_id () },
              });
    }
}

void QtTdLibGlobal::markAllMessagesAsRead (QtTdLibChat * chatItem) {
    if (chatItem != Q_NULLPTR) {
        QJsonArray messageIdsJson { };
        for (QtTdLibMessage * messageItem : chatItem->messagesModel) {
            if (messageItem->get_id () > chatItem->get_lastReadInboxMessageId ()) {
                messageIdsJson.append (messageItem->get_id_asJSON ());
            }
        }
        if (!messageIdsJson.isEmpty ()) {
            send (QJsonObject {
                      { "@type", "viewMessages" },
                      { "chat_id", chatItem->get_id_asJSON () },
                      { "message_ids", messageIdsJson },
                      { "force_read", true },
                  });
        }
    }
}

void QtTdLibGlobal::togglePinChat (QtTdLibChat * chatItem) {
    if (chatItem != Q_NULLPTR) {
        QJsonArray chatIdsJson { };
        for (QtTdLibChat * otherChatItem : (* m_chatsList)) {
            if (otherChatItem != chatItem && otherChatItem->get_isPinned ()) {
                chatIdsJson.append (otherChatItem->get_id_asJSON ());
            }
        }
        if (!chatItem->get_isPinned ()) {
            chatIdsJson.append (chatItem->get_id_asJSON ());
        }
        send (QJsonObject {
                  { "@type", "setPinnedChats" },
                  { "chat_ids", chatIdsJson },
              });
    }
}

void QtTdLibGlobal::loadSingleMessageRef (QtTdLibChat * chatItem, const qint64 messageId) {
    if (chatItem != Q_NULLPTR) {
        if (messageId != 0) {
            qWarning () << "LOAD SINGLE MESSAGE..." << messageId;
            send (QJsonObject {
                      { "@type", "getMessage" },
                      { "chat_id", chatItem->get_id_asJSON () },
                      { "message_id", QtTdLibId53Helper::fromCppToJson (messageId) },
                  });
        }
    }
}

void QtTdLibGlobal::loadInitialMessage (QtTdLibChat * chatItem, const qint64 messageId) {
    if (chatItem != Q_NULLPTR) {
        if (messageId != 0) {
            qWarning () << "LOAD INITIAL MESSAGE..." << messageId;
            if (messageId < chatItem->get_oldestFetchedMessageId () || messageId > chatItem->get_newestFetchedMessageId ()) {
                chatItem->messagesModel.clear (); // NOTE : need to clean current model
                chatItem->set_oldestFetchedMessageId (0); // NOTE : reset lower boundary
                chatItem->set_newestFetchedMessageId (0); // NOTE : reset upper boundary
                chatItem->set_hasReachedFirst (false); // NOTE : reset start flag
                chatItem->set_hasReachedLast  (false); // NOTE : reset end flag
                if (QtTdLibMessage * messageItem = { chatItem->getMessageItemById (messageId) }) {
                    chatItem->addMessageItem (messageItem); // NOTE : add message from collection
                    chatItem->set_oldestFetchedMessageId (messageItem->get_id ()); // NOTE : set lower boundary
                    chatItem->set_newestFetchedMessageId (messageItem->get_id ()); // NOTE : set upper boundary
                    loadOlderMessages (chatItem); // NOTE : load older messages
                    loadNewerMessages (chatItem); // NOTE : load newer messages
                }
                else {
                    send (QJsonObject { // NOTE : need to get message from TDLIB call
                                        { "@type", "getChatHistory" },
                                        { "chat_id",  chatItem->get_id_asJSON () },
                                        { "from_message_id", QtTdLibId53Helper::fromCppToJson (messageId) },
                                        { "offset", -1 }, // must be negative to fetch newer messages
                                        { "limit", 2 }, //  must be higher than -offset
                                        { "only_local", false }, // allow to request on network not only database
                                        { "@extra", QJsonObject {
                                              { "chat_id",  chatItem->get_id_asJSON () },
                                              { "load_mode", LOAD_INIT },
                                          }
                                        }
                          });
                }
            }
        }
    }
}

void QtTdLibGlobal::loadOlderMessages (QtTdLibChat * chatItem, const int count) {
    if (chatItem != Q_NULLPTR && chatItem->get_oldestFetchedMessageId () != 0 && count > 0) {
        qWarning () << "LOAD" << count << "OLDER MESSAGES...";
        send (QJsonObject {
                  { "@type", "getChatHistory" },
                  { "chat_id",  chatItem->get_id_asJSON () },
                  { "from_message_id", chatItem->get_oldestFetchedMessageId_asJSON () }, // starting from the oldest fetched message
                  { "offset", 0 }, // must equal 0 to start exactly at position
                  { "limit", count }, // must be equal to offset+count
                  { "only_local", false }, // allow to request on network not only database
                  { "@extra", QJsonObject {
                        { "chat_id",  chatItem->get_id_asJSON () },
                        { "load_mode", LOAD_OLDER },
                    }
                  }
              });
    }
}

void QtTdLibGlobal::loadNewerMessages (QtTdLibChat * chatItem, const int count) {
    if (chatItem != Q_NULLPTR && chatItem->get_newestFetchedMessageId () != 0 && count > 0) {
        qWarning () << "LOAD" << count << "NEWER MESSAGES...";
        send (QJsonObject {
                  { "@type", "getChatHistory" },
                  { "chat_id",  chatItem->get_id_asJSON () },
                  { "from_message_id", chatItem->get_newestFetchedMessageId_asJSON () }, // starting from the newest fetched message
                  { "offset", -count }, // must be negative to fetch newer messages
                  { "limit", count +1 }, //  must be higher than -offset
                  { "only_local", false }, // allow to request on network not only database
                  { "@extra", QJsonObject {
                        { "chat_id",  chatItem->get_id_asJSON () },
                        { "load_mode", LOAD_NEWER },
                    }
                  }
              });
    }
}

void QtTdLibGlobal::removeMessage (QtTdLibChat * chatItem, QtTdLibMessage * messageItem, const bool forAll) {
    if (chatItem != Q_NULLPTR && messageItem != Q_NULLPTR) {
        send (QJsonObject {
                  { "@type", "deleteMessages" },
                  { "chat_id",  chatItem->get_id_asJSON () },
                  { "message_ids",  QJsonArray {
                        messageItem->get_id_asJSON ()
                    }
                  },
                  { "revoke", !forAll },
              });
    }
}

void QtTdLibGlobal::refreshBasicGroupFullInfo (QtTdLibBasicGroup * basicGroupItem) {
    if (basicGroupItem != Q_NULLPTR) {
        send (QJsonObject {
                  { "@type", "getBasicGroupFullInfo" },
                  { "basic_group_id", basicGroupItem->get_id_asJSON () },
              });
    }
}

void QtTdLibGlobal::refreshSupergroupFullInfo (QtTdLibSupergroup * supergroupItem) {
    if (supergroupItem != Q_NULLPTR) {
        send (QJsonObject {
                  { "@type", "getSupergroupFullInfo" },
                  { "supergroup_id", supergroupItem->get_id_asJSON () },
              });
    }
}

void QtTdLibGlobal::refreshSupergroupMembers (QtTdLibSupergroup * supergroupItem, const int count, const int offset) {
    if (supergroupItem != Q_NULLPTR) {
        send (QJsonObject {
                  { "@type", "getSupergroupMembers" },
                  { "supergroup_id", supergroupItem->get_id_asJSON () },
                  { "offset", offset },
                  { "limit", count },
                  { "@extra", QJsonObject {
                        { "supergroup_id", supergroupItem->get_id_asJSON () },
                    }
                  }
              });
    }
}

void QtTdLibGlobal::sendMessageText (QtTdLibChat * chatItem, const QString & text) {
    if (chatItem != Q_NULLPTR && !text.isEmpty ()) {
        send (QJsonObject {
                  { "@type", "sendMessage" },
                  { "chat_id" , chatItem->get_id_asJSON () },
                  { "reply_to_message_id", QtTdLibId53Helper::fromQmlToJson (m_replyingToMessageId) },
                  { "disable_notification", false },
                  { "from_background", false },
                  { "reply_markup", QJsonValue::Null },
                  { "input_message_content", QJsonObject {
                        { "@type", "inputMessageText" },
                        { "disable_web_page_preview", false },
                        { "clear_draft", false },
                        { "text", exec ({
                              { "@type", "parseTextEntities" },
                              { "text", text },
                              { "parse_mode", QJsonObject {
                                    { "@type", "textParseModeMarkdown" },
                                }
                              }
                          })
                        }
                    }
                  }
              });
    }
    set_replyingToMessageId ("");
}

void QtTdLibGlobal::sendMessagePhoto (QtTdLibChat * chatItem, const bool groupInAlbum) {
    if (chatItem != Q_NULLPTR && !m_selectedPhotosList.isEmpty ()) {
        if (groupInAlbum) {
            QJsonArray contents { };
            for (SelectionPhoto * selection : m_selectedPhotosList) {
                contents.append (QJsonObject {
                                     { "@type", "inputMessagePhoto" },
                                     { "width", selection->width },
                                     { "height", selection->height },
                                     { "photo", QJsonObject {
                                           { "@type", "inputFileLocal" },
                                           { "path", selection->path },
                                       }
                                     }
                                 });
            }
            if (!contents.isEmpty ()) {
                send (QJsonObject {
                          { "@type", "sendMessageAlbum" },
                          { "chat_id", chatItem->get_id () },
                          { "reply_to_message_id", QtTdLibId53Helper::fromQmlToJson (m_replyingToMessageId) },
                          { "disable_notification", false },
                          { "from_background", false },
                          { "input_message_contents", contents }
                      });
            }
        }
        else {
            for (SelectionPhoto * selection : m_selectedPhotosList) {
                send (QJsonObject {
                          { "@type", "sendMessage" },
                          { "chat_id", chatItem->get_id () },
                          { "reply_to_message_id", QtTdLibId53Helper::fromQmlToJson (m_replyingToMessageId) },
                          { "disable_notification", false },
                          { "from_background", false },
                          { "input_message_content", QJsonObject {
                                { "@type", "inputMessagePhoto" },
                                { "width", selection->width },
                                { "height", selection->height },
                                { "photo", QJsonObject {
                                      { "@type", "inputFileLocal" },
                                      { "path", selection->path },
                                  }
                                }
                            }
                          }
                      });
            }
        }
    }
    set_replyingToMessageId ("");
}

void QtTdLibGlobal::sendMessageVideo (QtTdLibChat * chatItem, const bool groupInAlbum) {
    if (chatItem != Q_NULLPTR && !m_selectedVideosList.isEmpty ()) {
        if (groupInAlbum) {
            QJsonArray contents { };
            for (SelectionVideo * selection : m_selectedVideosList) {
                contents.append (QJsonObject {
                                     { "@type", "inputMessageVideo" },
                                     { "width", selection->width },
                                     { "height", selection->height },
                                     { "duration", selection->duration },
                                     { "video", QJsonObject {
                                           { "@type", "inputFileLocal" },
                                           { "path", selection->path },
                                       }
                                     }
                                 });
            }
            if (!contents.isEmpty ()) {
                send (QJsonObject {
                          { "@type", "sendMessageAlbum" },
                          { "chat_id", chatItem->get_id_asJSON () },
                          { "reply_to_message_id", QtTdLibId53Helper::fromQmlToJson (m_replyingToMessageId) },
                          { "disable_notification", false },
                          { "from_background", false },
                          { "input_message_contents", contents }
                      });
            }
        }
        else {
            for (SelectionVideo * selection : m_selectedVideosList) {
                send (QJsonObject {
                          { "@type", "sendMessage" },
                          { "chat_id", chatItem->get_id_asJSON () },
                          { "reply_to_message_id", QtTdLibId53Helper::fromQmlToJson (m_replyingToMessageId) },
                          { "disable_notification", false },
                          { "from_background", false },
                          { "input_message_content", QJsonObject {
                                { "@type", "inputMessageVideo" },
                                { "width", selection->width },
                                { "height", selection->height },
                                { "duration", selection->duration },
                                { "video", QJsonObject {
                                      { "@type", "inputFileLocal" },
                                      { "path", selection->path },
                                  }
                                }
                            }
                          }
                      });
            }
        }
    }
    set_replyingToMessageId ("");
}

void QtTdLibGlobal::sendMessageVoiceNote (QtTdLibChat * chatItem, const QString & recording) {
    if (chatItem != Q_NULLPTR && QFile::exists (recording)) {
        QByteArray waveform { };
        waveform.reserve (100);
        for (quint8 byte { 0 }; byte < 100; ++byte) {
            waveform.append (qrand () % 0xFF);
        }
        send (QJsonObject {
                  { "@type", "sendMessage" },
                  { "chat_id", chatItem->get_id () },
                  { "reply_to_message_id", QtTdLibId53Helper::fromQmlToJson (m_replyingToMessageId) },
                  { "disable_notification", false },
                  { "from_background", false },
                  { "input_message_content", QJsonObject {
                        { "@type", "inputMessageVoiceNote" },
                        { "duration", qCeil (m_recordingDuration / 1000.0) },
                        { "waveform", QString::fromLatin1 (waveform.toBase64 ()) },  // TODO
                        { "voice_note", QJsonObject {
                              { "@type", "inputFileLocal" },
                              { "path", recording },
                          }
                        }
                    }
                  }
              });
    }
    set_replyingToMessageId ("");
}

void QtTdLibGlobal::sendMessageSticker (QtTdLibChat * chatItem, QtTdLibSticker * stickerItem) {
    if (chatItem != Q_NULLPTR) {
        send (QJsonObject {
                  { "@type", "sendMessage" },
                  { "chat_id", chatItem->get_id () },
                  { "reply_to_message_id", QtTdLibId53Helper::fromQmlToJson (m_replyingToMessageId) },
                  { "disable_notification", false },
                  { "from_background", false },
                  { "reply_markup", QJsonValue::Null },
                  { "input_message_content", QJsonObject {
                        { "@type", "inputMessageSticker" },
                        { "width", stickerItem->get_width () },
                        { "height", stickerItem->get_height () },
                        { "sticker", QJsonObject {
                              { "@type", "inputFileRemote" },
                              { "id", stickerItem->get_sticker ()->get_remote ()->get_id () },
                          }
                        }
                    }
                  }
              });
    }
    set_replyingToMessageId ("");
}

void QtTdLibGlobal::sendMessageDocument (QtTdLibChat * chatItem, const QString & path) {
    if (chatItem != Q_NULLPTR && QFile::exists (path)) {
        send (QJsonObject {
                  { "@type", "sendMessage" },
                  { "chat_id", chatItem->get_id () },
                  { "reply_to_message_id", QtTdLibId53Helper::fromQmlToJson (m_replyingToMessageId) },
                  { "disable_notification", false },
                  { "from_background", false },
                  { "reply_markup", QJsonValue::Null },
                  { "input_message_content", QJsonObject {
                        { "@type", "inputMessageDocument" },
                        { "document", QJsonObject {
                              { "@type", "inputFileLocal" },
                              { "path", path },
                          }
                        }
                    }
                  }
              });
    }
    set_replyingToMessageId ("");
}

bool QtTdLibGlobal::startRecordingAudio (void) {
    if (m_audioRecorder->status () == QMediaRecorder::LoadedStatus) {
        QDir ().mkpath ("/home/nemo/.telegrame/recordings");
        m_audioRecorder->setOutputLocation (QUrl ("file:///home/nemo/.telegrame/recordings/rec_" % QDateTime::currentDateTimeUtc ().toString ("yyyy-MM-dd_hh-mm-ss-zzz") % ".wav"));
        m_audioRecorder->record ();
        return true;
    }
    else {
        return false;
    }
}

QString QtTdLibGlobal::stopRecordingAudio (void) {
    if (m_audioRecorder->status () == QMediaRecorder::RecordingStatus) {
        m_audioRecorder->stop ();
        return m_audioRecorder->outputLocation ().toLocalFile ();
    }
    else {
        return "";
    }
}

void QtTdLibGlobal::removeRecording (const QString & path) {
    QFile::remove (path);
}

void QtTdLibGlobal::onFrame (const QJsonObject & json) {
    switch (QtTdLibEnums::objectTypeEnumFromJson (json)) {
        case QtTdLibObjectType::UPDATE_AUTHORIZATION_STATE: {
            set_authorizationState_withJSON (json ["authorization_state"], &QtTdLibAuthorizationState::createAbstract);
            if (m_authorizationState) {
                switch (m_authorizationState->get_typeOf ()) {
                    case QtTdLibObjectType::AUTHORIZATION_STATE_WAIT_TDLIB_PARAMETERS: {
                        send (QJsonObject {
                                  { "@type", "setTdlibParameters" },
                                  { "parameters", QJsonObject {
                                        { "api_id", 27687 },
                                        { "api_hash", "dfc01707ab3b6aefe4a7fcfb83ea275c" },
                                        { "use_test_dc", false },
                                        { "use_file_database", true },
                                        { "use_chat_info_database", true },
                                        { "use_message_database", true },
                                        { "use_secret_chats", true },
                                        { "system_language_code", "en" },
                                        { "device_model", "Jolla Sailfish OS" },
                                        { "system_version", "3.x" },
                                        { "application_version", "0.9" },
                                        { "enable_storage_optimizer", true },
                                        { "database_directory", QString (QDir::homePath () % "/.telegrame") },
                                        { "files_directory", QString (QDir::homePath () % "/.telegrame") },
                                        //{ "ignore_file_names", false },
                                    }
                                  }
                              });
                        break;
                    }
                    case QtTdLibObjectType::AUTHORIZATION_STATE_WAIT_ENCRYPTION_KEY: {
                        send (QJsonObject {
                                  { "@type", "setDatabaseEncryptionKey" },
                                  { "new_encryption_key",            "" },
                              });
                        break;
                    }
                    case QtTdLibObjectType::AUTHORIZATION_STATE_READY: {
                        send (QJsonObject {
                                  { "@type",       "getChats" },
                                  { "offset_order", "1000000" },
                                  { "offset_chat_id", 1000000 },
                                  { "limit",          1000000 },
                              });
                        send (QJsonObject {
                                  { "@type", "getInstalledStickerSets" },
                                  { "is_masks",                  false },
                              });
                        send (QJsonObject {
                                  { "@type", "getSavedAnimations" },
                              });
                        send (QJsonObject {
                                  { "@type", "searchContacts" },
                                  { "query", "" },
                                  { "limit", 1000 },
                              });
                        break;
                    }
                    default: break;
                }
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_CONNECTION_STATE: {
            set_connectionState_withJSON (json ["state"], &QtTdLibConnectionState::createAbstract);
            break;
        }
        case QtTdLibObjectType::UPDATE_UNREAD_MESSAGE_COUNT: {
            set_unreadMessagesCount          (json ["unread_unmuted_count"].toInt ());
            set_unreadMessagesCountWithMuted (json ["unread_count"].toInt ());
            break;
        }
        case QtTdLibObjectType::UPDATE_FILE: {
            const QJsonObject fileJson { json ["file"].toObject () };
            const qint32 fileId { QtTdLibId32Helper::fromJsonToCpp (fileJson ["id"]) };
            if (QtTdLibFile * fileItem = { getFileItemById (fileId) }) {
                fileItem->updateFromJson (fileJson);
            }
        }
        case QtTdLibObjectType::UPDATE_USER: {
            const QJsonObject userJson { json ["user"].toObject () };
            const qint32 userId { QtTdLibId32Helper::fromJsonToCpp (userJson ["id"]) };
            if (QtTdLibUser * userItem = { getUserItemById (userId) }) {
                userItem->updateFromJson (userJson);
            }
            else {
                QtTdLibUser::create (userJson, this);
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_SUPERGROUP: {
            const QJsonObject supergroupJson { json ["supergroup"].toObject () };
            const qint32 supergroupId { QtTdLibId32Helper::fromJsonToCpp (supergroupJson ["id"]) };
            if (QtTdLibSupergroup * supergroupItem = { getSupergroupItemById (supergroupId) }) {
                supergroupItem->updateFromJson (supergroupJson);
            }
            else {
                QtTdLibSupergroup::create (supergroupJson, this);
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_SUPERGROUP_FULL_INFO: {
            const qint32 supergroupId { QtTdLibId32Helper::fromJsonToCpp (json ["supergroup_id"]) };
            if (QtTdLibSupergroup * supergroupItem = { getSupergroupItemById (supergroupId) }) {
                supergroupItem->updateFromJson (json ["supergroup_full_info"].toObject ());
            }
            break;
        }
        case QtTdLibObjectType::CHAT_MEMBERS: {
            const qint32 supergroupId { QtTdLibId32Helper::fromJsonToCpp (json ["@extra"].toObject () ["supergroup_id"]) };
            if (QtTdLibSupergroup * supergroupItem = { getSupergroupItemById (supergroupId) }) {
                const QJsonArray membersJson = json ["members"].toArray ();
                QList<QtTdLibChatMember *> members { };
                members.reserve (membersJson.count ());
                for (const QJsonValue & memberVar : membersJson) {
                    members.append (QtTdLibChatMember::create (memberVar.toObject ()));
                }
                supergroupItem->get_members ()->clear ();
                supergroupItem->get_members ()->append (members);
            }
        }
        case QtTdLibObjectType::UPDATE_BASIC_GROUP: {
            const QJsonObject basicGroupJson { json ["basic_group"].toObject () };
            const qint32 basicGroupId { QtTdLibId32Helper::fromJsonToCpp (basicGroupJson ["id"]) };
            if (QtTdLibBasicGroup * basicGroupItem = { getBasicGroupItemById (basicGroupId) }) {
                basicGroupItem->updateFromJson (basicGroupJson);
            }
            else {
                QtTdLibBasicGroup::create (basicGroupJson, this);
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_BASIC_GROUP_FULL_INFO: {
            const qint32 basicGroupId { QtTdLibId32Helper::fromJsonToCpp (json ["basic_group_id"]) };
            if (QtTdLibBasicGroup * basicGroupItem = { getBasicGroupItemById (basicGroupId) }) {
                basicGroupItem->updateFromJson (json ["basic_group_full_info"].toObject ());
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_USER_STATUS: {
            const QJsonObject statusJson { json ["status"].toObject () };
            const qint32 userId { QtTdLibId32Helper::fromJsonToCpp (json ["user_id"]) };
            if (QtTdLibUser * userItem = { getUserItemById (userId) }) {
                userItem->set_status_withJSON (statusJson, &QtTdLibUserStatus::createAbstract);
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_NEW_CHAT: {
            const QJsonObject chatJson { json ["chat"].toObject () };
            const qint64 chatId { QtTdLibId53Helper::fromJsonToCpp (chatJson ["id"]) };
            if (QtTdLibChat * chatItem = { getChatItemById (chatId) }) {
                chatItem->updateFromJson (chatJson);
            }
            else {
                m_chatsList->append (QtTdLibChat::create (chatJson, this));
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_CHAT_READ_INBOX: {
            const qint64 chatId { QtTdLibId53Helper::fromJsonToCpp (json ["chat_id"]) };
            if (QtTdLibChat * chatItem = { getChatItemById (chatId) }) {
                chatItem->set_lastReadInboxMessageId_withJSON (json ["last_read_inbox_message_id"]);
                chatItem->set_unreadCount_withJSON (json ["unread_count"]);
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_CHAT_READ_OUTBOX: {
            const qint64 chatId { QtTdLibId53Helper::fromJsonToCpp (json ["chat_id"]) };
            if (QtTdLibChat * chatItem = { getChatItemById (chatId) }) {
                chatItem->set_lastReadOutboxMessageId_withJSON (json ["last_read_outbox_message_id"]);
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_CHAT_NOTIFICATION_SETTINGS: {
            const qint64 chatId { QtTdLibId53Helper::fromJsonToCpp (json ["chat_id"]) };
            if (QtTdLibChat * chatItem = { getChatItemById (chatId) }) {
                chatItem->set_notificationSettings_withJSON (json ["notification_settings"], &QtTdLibChatNotificationSettings::create);
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_NOTIFICATION_SETTINGS: {
            if (json ["scope"].toObject () ["@type"].toString () == "notificationSettingsScopeChat") {
                const qint64 chatId { QtTdLibId53Helper::fromJsonToCpp (json ["scope"].toObject () ["chat_id"]) };
                if (QtTdLibChat * chatItem = { getChatItemById (chatId) }) {
                    chatItem->get_notificationSettings ()->set_muteFor_withJSON (json ["notification_settings"].toObject () ["mute_for"]);
                }
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_CHAT_IS_PINNED: {
            const qint64 chatId { QtTdLibId53Helper::fromJsonToCpp (json ["chat_id"]) };
            if (QtTdLibChat * chatItem = { getChatItemById (chatId) }) {
                chatItem->set_order_withJSON    (json ["order"]);
                chatItem->set_isPinned_withJSON (json ["is_pinned"]);
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_CHAT_DRAFT_MESSAGE: {
            const qint64 chatId { QtTdLibId53Helper::fromJsonToCpp (json ["chat_id"]) };
            if (QtTdLibChat * chatItem = { getChatItemById (chatId) }) {
                chatItem->set_order_withJSON    (json ["order"]);
                // TODO : draft_message subobject
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_NEW_MESSAGE: {
            const QJsonObject messageJson { json ["message"].toObject () };
            const qint64 chatId { QtTdLibId53Helper::fromJsonToCpp (messageJson ["chat_id"]) };
            if (QtTdLibChat * chatItem = { getChatItemById (chatId) }) {
                const qint64 messageId { QtTdLibId53Helper::fromJsonToCpp (messageJson ["id"]) };
                if (QtTdLibMessage * messageItem = { chatItem->getMessageItemById (messageId) }) {
                    messageItem->updateFromJson (messageJson);
                }
                else {
                    messageItem = QtTdLibMessage::create (messageJson, chatItem);
                    if (chatItem->get_hasReachedLast ()) {
                        chatItem->addMessageItem (messageItem);
                    }
                }
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_CHAT_LAST_MESSAGE: {
            const qint64 chatId { QtTdLibId53Helper::fromJsonToCpp (json ["chat_id"]) };
            if (QtTdLibChat * chatItem = { getChatItemById (chatId) }) {
                chatItem->set_order_withJSON (json ["order"]);
                const QJsonObject messageJson { json ["last_message"].toObject () };
                const qint64 messageId { QtTdLibId53Helper::fromJsonToCpp (messageJson ["id"]) };
                if (QtTdLibMessage * messageItem = { chatItem->getMessageItemById (messageId) }) {
                    messageItem->updateFromJson (messageJson);
                }
                else {
                    messageItem = QtTdLibMessage::create (messageJson, chatItem);
                    if (chatItem->get_hasReachedLast ()) {
                        chatItem->addMessageItem (messageItem);
                    }
                }
                chatItem->set_lastReceivedMessageId (messageId);
            }
            break;
        }
        case QtTdLibObjectType::USERS: {
            m_contactsList->clear ();
            const QJsonArray usersIdsJson = json ["user_ids"].toArray ();
            for (const QJsonValue & tmpJson : usersIdsJson) {
                const qint32 userId { QtTdLibId32Helper::fromJsonToCpp (tmpJson) };
                if (QtTdLibUser * userItem = { getUserItemById (userId) }) {
                    m_contactsList->append (userItem);
                    qWarning () << "CONTACT" << userItem->get_firstName () << userItem->get_lastName ();
                }
            }
            break;
        }
        case QtTdLibObjectType::CHAT: {
            const qint64 chatId { QtTdLibId53Helper::fromJsonToCpp (json ["id"]) };
            if (QtTdLibChat * chatItem = { getChatItemById (chatId) }) {
                chatItem->updateFromJson (json);
                if (json ["@extra"].toObject () ["show_chat"].toBool ()) {
                    showChat (chatItem);
                }
            }
            else {
                m_chatsList->append (QtTdLibChat::create (json, this));
                if (json ["@extra"].toObject () ["show_chat"].toBool ()) {
                    showChat (m_chatsList->last ());
                }
            }
            break;
        }
        case QtTdLibObjectType::MESSAGE: {
            const qint64 chatId { QtTdLibId53Helper::fromJsonToCpp (json ["chat_id"]) };
            if (QtTdLibChat * chatItem = { getChatItemById (chatId) }) {
                const qint64 messageId { QtTdLibId53Helper::fromJsonToCpp (json ["id"]) };
                if (QtTdLibMessage * messageItem = { chatItem->getMessageItemById (messageId) }) {
                    messageItem->updateFromJson (json);
                }
                else {
                    QtTdLibMessage::create (json, chatItem);
                }
            }
            break;
        }
        case QtTdLibObjectType::MESSAGES: {
            const LoadMode mode { LoadMode (json ["@extra"].toObject () ["load_mode"].toInt (LOAD_NONE)) };
            const qint64 chatId { QtTdLibId53Helper::fromJsonToCpp (json ["@extra"].toObject () ["chat_id"]) };
            if (QtTdLibChat * chatItem = { getChatItemById (chatId) }) {
                const QJsonArray messagesListJson = json ["messages"].toArray ();
                QMap<qint64, QtTdLibMessage *> messageItemsList  { };
                for (const QJsonValue & tmp : messagesListJson) {
                    const QJsonObject messageJson { tmp.toObject () };
                    const qint64 messageId { QtTdLibId53Helper::fromJsonToCpp (messageJson ["id"]) };
                    if (QtTdLibMessage * messageItem = { chatItem->getMessageItemById (messageId) }) {
                        messageItem->updateFromJson (messageJson);
                        messageItemsList.insert (messageId, messageItem);
                    }
                    else {
                        messageItemsList.insert (messageId, QtTdLibMessage::create (messageJson, chatItem));
                    }
                }
                switch (mode) {
                    case LOAD_INIT:
                    case LOAD_NEWER:
                    case LOAD_OLDER: {
                        qint64 oldestMsgId { 0 };
                        qint64 newestMsgId { 0 };
                        int newMessagesCounter { 0 };
                        for (QMap<qint64, QtTdLibMessage *>::const_iterator it { messageItemsList.constBegin () }, end { messageItemsList.constEnd () }; it != end; ++it) {
                            if (!chatItem->messagesModel.contains (it.value ())) {
                                chatItem->addMessageItem (it.value ());
                                if ((oldestMsgId == 0) || (it.key () < oldestMsgId)) {
                                    oldestMsgId = it.key ();
                                }
                                if ((newestMsgId == 0) || (it.key () > newestMsgId)) {
                                    newestMsgId = it.key ();
                                }
                                ++newMessagesCounter;
                            }
                        }
                        if (newMessagesCounter > 0) {
                            if ((chatItem->get_oldestFetchedMessageId () > oldestMsgId) ||
                                (chatItem->get_oldestFetchedMessageId () == 0)) {
                                chatItem->set_oldestFetchedMessageId (oldestMsgId);
                            }
                            if ((chatItem->get_newestFetchedMessageId () < newestMsgId) ||
                                (chatItem->get_newestFetchedMessageId () == 0)) {
                                chatItem->set_newestFetchedMessageId (newestMsgId);
                            }
                            qWarning () << "GOT" << newMessagesCounter << "MESSAGES" << mode << chatItem->get_oldestFetchedMessageId () << chatItem->get_newestFetchedMessageId ();
                        }
                        else {
                            if (mode == LOAD_OLDER) {
                                chatItem->set_hasReachedFirst (true);
                            }
                            else if (mode == LOAD_NEWER) {
                                chatItem->set_hasReachedLast (true);
                            }
                            else { }
                            qWarning () << "GOT NO MESSAGES" << mode << chatItem->get_hasReachedFirst () << chatItem->get_hasReachedLast ();
                        }
                        if ((chatItem->get_oldestFetchedMessageId () <= chatItem->get_lastReceivedMessageId ()) &&
                            (chatItem->get_newestFetchedMessageId () >= chatItem->get_lastReceivedMessageId ())) {
                            chatItem->set_hasReachedLast (true); // NOTE : special case
                        }
                        if (mode == LOAD_INIT) {
                            loadNewerMessages (chatItem);
                            loadOlderMessages (chatItem);
                        }
                        break;
                    }
                    default: break;
                }
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_DELETE_MESSAGES: {
            if (json ["is_permanent"].toBool ()) {
                const qint64 chatId { QtTdLibId53Helper::fromJsonToCpp (json ["chat_id"]) };
                if (QtTdLibChat * chatItem = { getChatItemById (chatId) }) {
                    const QJsonArray messagesListJson = json ["message_ids"].toArray ();
                    for (const QJsonValue & tmp : messagesListJson) {
                        const qint64 messageId { QtTdLibId53Helper::fromJsonToCpp (tmp) };
                        if (QtTdLibMessage * messageItem = { chatItem->getMessageItemById (messageId) }) {
                            chatItem->removeMessageItem (messageItem);
                            messageItem->deleteLater ();
                        }
                    }
                }
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_MESSAGE_SEND_SUCCEEDED: {
            const QJsonObject messageJson { json ["message"].toObject () };
            const qint64 chatId { QtTdLibId53Helper::fromJsonToCpp (messageJson ["chat_id"]) };
            if (QtTdLibChat * chatItem = { getChatItemById (chatId) }) {
                const qint64 messageId { QtTdLibId53Helper::fromJsonToCpp (messageJson ["id"]) };
                if (QtTdLibMessage * messageItem = { chatItem->getMessageItemById (messageId) }) {
                    messageItem->updateFromJson (messageJson);
                }
                else {
                    if (chatItem->get_hasReachedLast ()) {
                        chatItem->addMessageItem (QtTdLibMessage::create (messageJson, chatItem)); // FIXME : what if !hasReachedLast ???
                    }
                }
                const qint64 oldMessageId { QtTdLibId53Helper::fromJsonToCpp (json ["old_message_id"]) };
                if (QtTdLibMessage * oldMessageItem = { chatItem->getMessageItemById (oldMessageId) }) {
                    chatItem->removeMessageItem (oldMessageItem);
                    oldMessageItem->deleteLater ();
                }
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_MESSAGE_CONTENT: {
            const qint64 chatId { QtTdLibId53Helper::fromJsonToCpp (json ["chat_id"]) };
            if (QtTdLibChat * chatItem = { getChatItemById (chatId) }) {
                const qint64 messageId { QtTdLibId53Helper::fromJsonToCpp (json ["message_id"]) };
                if (QtTdLibMessage * messageItem = { chatItem->getMessageItemById (messageId) }) {
                    messageItem->set_content_withJSON (json ["new_content"].toObject (), &QtTdLibMessageContent::createAbstract);
                }
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_MESSAGE_EDITED: {
            const qint64 chatId { QtTdLibId53Helper::fromJsonToCpp (json ["chat_id"]) };
            if (QtTdLibChat * chatItem = { getChatItemById (chatId) }) {
                const qint64 messageId { QtTdLibId53Helper::fromJsonToCpp (json ["message_id"]) };
                if (QtTdLibMessage * messageItem = { chatItem->getMessageItemById (messageId) }) {
                    messageItem->set_editDate_withJSON (json ["edit_date"]);
                }
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_CHAT_TITLE: {
            const qint64 chatId { QtTdLibId53Helper::fromJsonToCpp (json ["chat_id"]) };
            if (QtTdLibChat * chatItem = { getChatItemById (chatId) }) {
                chatItem->set_title_withJSON (json ["title"]);
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_CHAT_PHOTO: {
            const qint64 chatId { QtTdLibId53Helper::fromJsonToCpp (json ["chat_id"]) };
            if (QtTdLibChat * chatItem = { getChatItemById (chatId) }) {
                chatItem->set_photo_withJSON (json ["photo"], &QtTdLibChatPhoto::create);
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_CHAT_ORDER: {
            const qint64 chatId { QtTdLibId53Helper::fromJsonToCpp (json ["chat_id"]) };
            if (QtTdLibChat * chatItem = { getChatItemById (chatId) }) {
                chatItem->set_order_withJSON (json ["order"]);
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_CHAT_UNREAD_MENTION_COUNT: {
            const qint64 chatId { QtTdLibId53Helper::fromJsonToCpp (json ["chat_id"]) };
            if (QtTdLibChat * chatItem = { getChatItemById (chatId) }) {
                chatItem->set_unreadMentionCount_withJSON (json ["unread_mention_count"]);
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_MESSAGE_MENTION_READ: {
            const qint64 chatId { QtTdLibId53Helper::fromJsonToCpp (json ["chat_id"]) };
            if (QtTdLibChat * chatItem = { getChatItemById (chatId) }) {
                chatItem->set_unreadMentionCount_withJSON (json ["unread_mention_count"]);
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_INSTALLED_STICKER_SETS: {
            const QJsonArray stickerSetIds = json ["sticker_set_ids"].toArray ();
            for (const QJsonValue & tmp : stickerSetIds) {
                const QString setId { tmp.toString () };
                Q_UNUSED (setId)
            }
            break;
        }
        case QtTdLibObjectType::STICKER_SETS: {
            const QJsonArray setsJson = json ["sets"].toArray ();
            for (const QJsonValue & tmp : setsJson) {
                const QJsonObject stickerSetJson { tmp.toObject () };
                const qint64 stickerSetId { QtTdLibId64Helper::fromJsonToCpp (stickerSetJson ["id"]) };
                if (QtTdLibStickerSetInfo * stickerSetItem = { QtTdLibCollection::allStickersSets.value (stickerSetId, Q_NULLPTR) }) {
                    stickerSetItem->updateFromJson (stickerSetJson);
                }
                else {
                    m_stickerSetsList->append (QtTdLibStickerSetInfo::create (stickerSetJson, this));
                    send (QJsonObject {
                              { "@type", "getStickerSet" },
                              { "set_id", QtTdLibId64Helper::fromCppToJson (stickerSetId) },
                          });
                }
            }
            break;
        }
        case QtTdLibObjectType::STICKER_SET: {
            const qint64 stickerSetId { QtTdLibId64Helper::fromJsonToCpp (json ["id"]) };
            if (QtTdLibStickerSetInfo * stickerSetItem = { QtTdLibCollection::allStickersSets.value (stickerSetId, Q_NULLPTR) }) {
                const QJsonArray stickerSetJson = json ["stickers"].toArray ();
                QList<QtTdLibSticker *> stickersList { };
                stickersList.reserve (stickerSetJson.count ());
                for (const QJsonValue & tmp : stickerSetJson) {
                    stickersList.append (QtTdLibSticker::create (tmp.toObject ()));
                }
                stickerSetItem->get_stickers ()->clear ();
                stickerSetItem->get_stickers ()->append (stickersList);
            }
            break;
        }
        case QtTdLibObjectType::ANIMATIONS: {
            const QJsonArray animationsJson = json ["animations"].toArray ();
            QList<QtTdLibAnimation *> animationsList { };
            animationsList.reserve (animationsJson.count ());
            for (const QJsonValue & tmp : animationsJson) {
                animationsList.append (QtTdLibAnimation::create (tmp.toObject ()));
            }
            m_savedAnimationsList->clear ();
            m_savedAnimationsList->append (animationsList);
            break;
        }
        default: {
            qWarning () << "UNHANDLED";
            break;
        }
    }
}
