
#include "QtTdLibGlobal.h"

#include <QDir>
#include <QStringBuilder>

QtTdLibGlobal::QtTdLibGlobal (QObject * parent)
    : QObject { parent }
    , m_chatsList { new QQmlObjectListModel<QtTdLibChat> { this } }
    , m_tdLibJsonWrapper { new QtTdLibJsonWrapper { this } }
{
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
    m_tdLibJsonWrapper->send (json);
}

QString QtTdLibGlobal::urlFromLocalPath (const QString & path) const {
    return QUrl::fromLocalFile (path).toString ();
}

QtTdLibFile * QtTdLibGlobal::getFileItemById (const qint32 id) const {
    return QtTdLibCollection::allFiles.value (id, Q_NULLPTR);
}

QtTdLibUser * QtTdLibGlobal::getUserItemById (const qint32 id) const {
    return QtTdLibCollection::allUsers.value (id, Q_NULLPTR);
}

QtTdLibChat * QtTdLibGlobal::getChatItemById (const qint64 id) const {
    return QtTdLibCollection::allChats.value (id, Q_NULLPTR);
}

QtTdLibMessage * QtTdLibGlobal::getMessageItemById (const qint64 id) const {
    return QtTdLibCollection::allMessages.value (id, Q_NULLPTR);
}

void QtTdLibGlobal::onFrame (const QJsonObject & json) {
    switch (QtTdLibEnums::objectTypeEnumFromJson (json)) {
        case QtTdLibObjectType::UPDATE_AUTHORIZATION_STATE: {
            set_authorizationState_withJSON (json ["authorization_state"], &QtTdLibAuthorizationState::create);
            if (m_authorizationState) {
                switch (m_authorizationState->get_typeOf ()) {
                    case QtTdLibObjectType::AUTHORIZATION_STATE_WAIT_TDLIB_PARAMETERS: {
                        m_tdLibJsonWrapper->send (QJsonObject {
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
                        m_tdLibJsonWrapper->send (QJsonObject {
                                                      { "@type", "setDatabaseEncryptionKey" },
                                                      { "new_encryption_key",            "" },
                                                  });
                        break;
                    }
                    case QtTdLibObjectType::AUTHORIZATION_STATE_READY: {
                        m_tdLibJsonWrapper->send (QJsonObject {
                                                      { "@type",       "getChats" },
                                                      { "offset_order", "1000000" },
                                                      { "offset_chat_id", 1000000 },
                                                      { "limit",          1000000 },
                                                  });
                        // m_tdLibJsonWrapper->send (QJsonObject {
                        //                               { "@type", "getInstalledStickerSets" },
                        //                               { "is_masks",                  false },
                        //                           });
                        // m_tdLibJsonWrapper->send (QJsonObject {
                        //                               { "@type", "getSavedAnimations" },
                        //                           });
                        break;
                    }
                    default: break;
                }
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_CONNECTION_STATE: {
            set_connectionState_withJSON (json ["state"], &QtTdLibConnectionState::create);
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
            QtTdLibUser * userItem { getUserItemById (userId) };
            if (!userItem) {
                userItem = new QtTdLibUser { userId, this };
            }
            userItem->updateFromJson (userJson);
            break;
        }
        case QtTdLibObjectType::UPDATE_USER_STATUS: {
            const QJsonObject statusJson { json ["status"].toObject () };
            const qint32 userId { QtTdLibId32Helper::fromJsonToCpp (json ["user_id"]) };
            if (QtTdLibUser * userItem = { getUserItemById (userId) }) {
                userItem->set_status_withJSON (statusJson, &QtTdLibUserStatus::create);
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_NEW_CHAT: {
            const QJsonObject chatJson { json ["chat"].toObject () };
            const qint64 chatId { QtTdLibId53Helper::fromJsonToCpp (chatJson ["id"]) };
            QtTdLibChat * chatItem { getChatItemById (chatId) };
            if (!chatItem) {
                chatItem = new QtTdLibChat { chatId, this };
                m_chatsList->append (chatItem);
            }
            chatItem->updateFromJson (chatJson);
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
        case QtTdLibObjectType::UPDATE_NEW_MESSAGE: {
            const QJsonObject messageJson { json ["message"].toObject () };
            const qint64 chatId { QtTdLibId53Helper::fromJsonToCpp (messageJson ["chat_id"]) };
            if (QtTdLibChat * chatItem = { getChatItemById (chatId) }) {
                const qint64 messageId { QtTdLibId53Helper::fromJsonToCpp (messageJson ["id"]) };
                QtTdLibMessage * messageItem { getMessageItemById (messageId) };
                if (!messageItem) {
                    messageItem = new QtTdLibMessage { messageId, this };
                    chatItem->get_messagesModel ()->append (messageItem);
                }
                messageItem->updateFromJson (messageJson);
            }
            break;
        }
        case QtTdLibObjectType::UPDATE_CHAT_LAST_MESSAGE: {
            const QJsonObject messageJson { json ["last_message"].toObject () };
            const qint64 chatId { QtTdLibId53Helper::fromJsonToCpp (messageJson ["chat_id"]) };
            if (QtTdLibChat * chatItem = { getChatItemById (chatId) }) {
                const qint64 messageId { QtTdLibId53Helper::fromJsonToCpp (messageJson ["id"]) };
                QtTdLibMessage * messageItem { getMessageItemById (messageId) };
                if (!messageItem) {
                    messageItem = new QtTdLibMessage { messageId, this };
                    chatItem->get_messagesModel ()->append (messageItem);
                }
                messageItem->updateFromJson (messageJson);
            }
            break;
        }
        case QtTdLibObjectType::MESSAGES: {
            const QJsonArray messagesListJson = json ["messages"].toArray ();
            for (const QJsonValue & tmp : messagesListJson) {
                const QJsonObject messageJson { tmp.toObject () };
                const qint64 chatId { QtTdLibId53Helper::fromJsonToCpp (messageJson ["chat_id"]) };
                if (QtTdLibChat * chatItem = { getChatItemById (chatId) }) {
                    const qint64 messageId { QtTdLibId53Helper::fromJsonToCpp (messageJson ["id"]) };
                    QtTdLibMessage * messageItem { getMessageItemById (messageId) };
                    if (!messageItem) {
                        messageItem = new QtTdLibMessage { messageId, this };
                        chatItem->get_messagesModel ()->prepend (messageItem);
                    }
                    messageItem->updateFromJson (messageJson);
                }
            }
            break;
        }
        default: break;
    }
}
