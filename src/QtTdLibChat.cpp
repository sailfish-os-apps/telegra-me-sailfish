
#include "QtTdLibChat.h"

QtTdLibChatPhoto::QtTdLibChatPhoto (QObject * parent)
    : QtTdLibAbstractObject { QtTdLibObjectType::CHAT_PHOTO, parent }
{ }

void QtTdLibChatPhoto::updateFromJson (const QJsonObject & json) {
    set_big_withJSON   (json ["big"].toObject (),   &QtTdLibFile::create);
    set_small_withJSON (json ["small"].toObject (), &QtTdLibFile::create);
}

QtTdLibChat::QtTdLibChat (const qint64 id, QObject * parent)
    : QtTdLibAbstractInt53IdObject { QtTdLibObjectType::CHAT, id, parent }
    , m_messagesModel              { new QQmlObjectListModel<QtTdLibMessage> { this } }
{
    QtTdLibCollection::allChats.insert (id, this);
}

QtTdLibMessage * QtTdLibChat::getMessageItemById (const QString & id) const {
    return getMessageItemById (id.toLongLong ());
}

QtTdLibMessage * QtTdLibChat::getMessageItemById (const qint64 id) const {
    return allMessages.value (id, Q_NULLPTR);
}

void QtTdLibChat::addMessageItem (QtTdLibMessage * messageItem) {
    if (messageItem != Q_NULLPTR) {
        if (m_messagesModel->isEmpty () || messageItem->get_id () > m_messagesModel->last ()->get_id ()) {
            m_messagesModel->append (messageItem);
        }
        else if (messageItem->get_id () < m_messagesModel->first ()->get_id ()) {
            m_messagesModel->prepend (messageItem);
        }
        else {
            int idx { 0 };
            while (idx < m_messagesModel->count ()) {
                if (m_messagesModel->at (idx)->get_id () > messageItem->get_id ()) {
                    m_messagesModel->insert (idx, messageItem);
                    break;
                }
                ++idx;
            }
        }
    }
}

void QtTdLibChat::removeMessageItem (QtTdLibMessage * messageItem) {
    if (messageItem != Q_NULLPTR) {
        m_messagesModel->remove (messageItem);
    }
}

void QtTdLibChat::updateFromJson (const QJsonObject & json) {
    set_unreadCount_withJSON             (json ["unread_count"]);
    set_unreadMentionCount_withJSON      (json ["unread_mention_count"]);
    set_lastReadInboxMessageId_withJSON  (json ["last_read_inbox_message_id"]);
    set_lastReadOutboxMessageId_withJSON (json ["last_read_outbox_message_id"]);
    set_replyMarkupMessageId_withJSON    (json ["reply_markup_message_id"]);
    set_isPinned_withJSON                (json ["is_pinned"]);
    set_title_withJSON                   (json ["title"]);
    set_clientData_withJSON              (json ["client_data"]);
    set_order_withJSON                   (json ["order"]);
    set_type_withJSON                    (json ["type"].toObject (),                  &QtTdLibChatType::createAbstract);
    set_photo_withJSON                   (json ["photo"].toObject (),                 &QtTdLibChatPhoto::create);
    set_notificationSettings_withJSON    (json ["notification_settings"].toObject (), &QtTdLibChatNotificationSettings::create);
}

QtTdLibChatType::QtTdLibChatType (const QtTdLibObjectType::Type typeOf, QObject * parent)
    : QtTdLibAbstractObject { typeOf, parent }
{ }

QtTdLibChatType * QtTdLibChatType::createAbstract (const QJsonObject & json, QObject * parent) {
    switch (QtTdLibEnums::objectTypeEnumFromJson (json)) {
        case QtTdLibObjectType::CHAT_TYPE_PRIVATE:     return QtTdLibChatTypePrivate::create    (json, parent);
        case QtTdLibObjectType::CHAT_TYPE_BASIC_GROUP: return QtTdLibChatTypeBasicGroup::create (json, parent);
        case QtTdLibObjectType::CHAT_TYPE_SUPERGROUP:  return QtTdLibChatTypeSupergroup::create (json, parent);
        case QtTdLibObjectType::CHAT_TYPE_SECRET:      return QtTdLibChatTypeSecret::create     (json, parent);
        default: return Q_NULLPTR;
    }
}

QtTdLibChatTypePrivate::QtTdLibChatTypePrivate (QObject * parent)
    : QtTdLibChatType { QtTdLibObjectType::CHAT_TYPE_PRIVATE, parent }
{ }

void QtTdLibChatTypePrivate::updateFromJson (const QJsonObject & json) {
    set_userId_withJSON (json ["user_id"]);
}

QtTdLibChatTypeBasicGroup::QtTdLibChatTypeBasicGroup (QObject * parent)
    : QtTdLibChatType { QtTdLibObjectType::CHAT_TYPE_BASIC_GROUP, parent }
{ }

void QtTdLibChatTypeBasicGroup::updateFromJson (const QJsonObject & json) {
    set_basicGroupId_withJSON (json ["basic_group_id"]);
}

QtTdLibChatTypeSupergroup::QtTdLibChatTypeSupergroup (QObject * parent)
    : QtTdLibChatType { QtTdLibObjectType::CHAT_TYPE_SUPERGROUP, parent }
{ }

void QtTdLibChatTypeSupergroup::updateFromJson (const QJsonObject & json) {
    set_supergroupId_withJSON (json ["supergroup_id"]);
}

QtTdLibChatTypeSecret::QtTdLibChatTypeSecret (QObject * parent)
    : QtTdLibChatType { QtTdLibObjectType::CHAT_TYPE_SECRET, parent }
{ }

void QtTdLibChatTypeSecret::updateFromJson (const QJsonObject & json) {
    set_secretChatId_withJSON (json ["secret_chat_id"]);
    set_userId_withJSON       (json ["user_id"]);
}

QtTdLibChatNotificationSettings::QtTdLibChatNotificationSettings(QObject * parent)
    : QtTdLibAbstractObject { QtTdLibObjectType::CHAT_NOTIFICATION_SETTINGS, parent }
{ }

void QtTdLibChatNotificationSettings::updateFromJson (const QJsonObject & json) {
    set_useDefaultMuteFor_withJSON (json ["use_default_mute_for"]);
    set_muteFor_withJSON           (json ["mute_for"]);
}
