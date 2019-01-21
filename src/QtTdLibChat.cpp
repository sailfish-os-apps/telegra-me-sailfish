
#include "QtTdLibChat.h"
#include "QtTdLibGlobal.h"

QtTdLibChat::QtTdLibChat (const qint64 id, QObject * parent)
    : QtTdLibAbstractInt53IdObject { QtTdLibObjectType::CHAT, id, parent }
    , m_isCurrentChat { false }
    , m_firstUnreadMessageItem { Q_NULLPTR }
    , m_chatActions { new QQmlObjectListModel<QtTdLibChatAction> { this, { }, "userId" } }
{
    QtTdLibCollection::allChats.insert (id, this);
    static const QString ICON { "/usr/share/icons/hicolor/128x128/apps/harbour-telegrame.png" };
    m_notif.setAppName ("Telegra'me");
    m_notif.setCategory ("x-telegrame.im");
    m_notif.setIcon    (ICON);
    m_notif.setAppIcon (ICON);
    m_notif.setMaxContentLines (3);
    m_notif.setRemoteAction (Notification::remoteAction ("default",
                                                         "Show chat",
                                                         "org.uniqueconception.telegrame",
                                                         "/org/uniqueconception/telegrame",
                                                         "org.uniqueconception.telegrame",
                                                         "showChat",
                                                         QVariantList { get_id () }));
    connect (this, &QtTdLibChat::titleChanged,                 this, &QtTdLibChat::refreshNotification);
    connect (this, &QtTdLibChat::unreadCountChanged,           this, &QtTdLibChat::refreshNotification);
    connect (this, &QtTdLibChat::isCurrentChatChanged,         this, &QtTdLibChat::refreshNotification);
    connect (this, &QtTdLibChat::lastReceivedMessageIdChanged, this, &QtTdLibChat::refreshNotification);
    connect (this, &QtTdLibChat::notificationSettingsChanged,  this, [this] (void) {
        if (m_notificationSettings != Q_NULLPTR) {
            connect (m_notificationSettings, &QtTdLibChatNotificationSettings::muteForChanged, this, &QtTdLibChat::refreshNotification);
        }
        refreshNotification ();
    });
    connect (&m_timer, &QTimer::timeout, this, [this] (void) {
        QtTdLibMessage * lastMsg = { getMessageItemById (m_lastReceivedMessageId) };
        if (!m_isCurrentChat &&
            (m_unreadCount > 0) &&
            (m_notificationSettings != Q_NULLPTR) &&
            (m_notificationSettings->get_muteFor () == 0) &&
            (lastMsg != Q_NULLPTR) &&
            (lastMsg->get_id () > m_lastNotifiedMessageId)) {
            m_lastNotifiedMessageId = lastMsg->get_id ();
            m_notif.setItemCount      (m_unreadCount);
            m_notif.setSummary        (m_title);
            m_notif.setTimestamp      (lastMsg->get_date ());
            m_notif.setBody           (lastMsg->preview (QtTdLibMessage::SHOW_TITLE));
            m_notif.setPreviewBody    (lastMsg->preview (QtTdLibMessage::SHOW_TITLE));
            m_notif.setPreviewSummary (m_title);
            m_notif.publish ();
        }
        else {
            m_notif.close ();
        }
    });
    connect (&m_notif, &Notification::clicked, this, [this] (void) {
        qWarning () << "CLICKED" << this << get_id ();
        emit displayRequested ();
    });
    connect (this,           &QtTdLibChat::lastReadInboxMessageIdChanged,  this, &QtTdLibChat::findFirstNewMessage);
    connect (this,           &QtTdLibChat::lastReadOutboxMessageIdChanged, this, &QtTdLibChat::findFirstNewMessage);
    connect (&messagesModel, &QQmlFastObjectListModelBase::itemInserted,   this, &QtTdLibChat::findFirstNewMessage);
    connect (&messagesModel, &QQmlFastObjectListModelBase::itemRemoved,    this, &QtTdLibChat::findFirstNewMessage);
    connect (&messagesModel, &QQmlFastObjectListModelBase::itemsCleared,   this, &QtTdLibChat::findFirstNewMessage);
    m_timer.setTimerType  (Qt::CoarseTimer);
    m_timer.setSingleShot (true);
    m_timer.setInterval   (350);
}

QtTdLibChat::~QtTdLibChat (void) {
    m_timer.stop ();
    m_notif.close ();
}

void QtTdLibChat::refreshNotification (void) {
    if (!m_timer.isActive ()) {
        m_timer.start ();
    }
}

void QtTdLibChat::findFirstNewMessage (void) {
    QtTdLibMessage * firstUnreadMessageItem { Q_NULLPTR };
    for (int idx { 0 }; idx < messagesModel.count (); ++idx) {
        if (QtTdLibMessage * messageItem = { messagesModel.getAt (idx) }) {
            if (messageItem->get_id () > m_lastReadInboxMessageId && (idx == 0 || messagesModel.getAt (idx -1)->get_id () <= m_lastReadInboxMessageId)) {
                firstUnreadMessageItem = messageItem;
                break;
            }
        }
    }
    set_firstUnreadMessageItem (firstUnreadMessageItem);
}

QtTdLibMessage * QtTdLibChat::getMessageItemById (const QString & id) const {
    return getMessageItemById (id.toLongLong ());
}

QtTdLibMessage * QtTdLibChat::getMessageItemById (const qint64 id) const {
    return allMessages.value (id, Q_NULLPTR);
}

void QtTdLibChat::addMessageItem (QtTdLibMessage * messageItem) {
    if (messageItem != Q_NULLPTR) {
        if (messagesModel.isEmpty () || messageItem->get_id () > messagesModel.getLast ()->get_id ()) {
            messagesModel.append (messageItem);
        }
        else if (messageItem->get_id () < messagesModel.getFirst ()->get_id ()) {
            messagesModel.prepend (messageItem);
        }
        else {
            int idx { 0 };
            while (idx < messagesModel.count ()) {
                if (messagesModel.getAt (idx)->get_id () > messageItem->get_id ()) {
                    messagesModel.insert (messageItem, idx);
                    break;
                }
                ++idx;
            }
        }
    }
}

void QtTdLibChat::removeMessageItem (QtTdLibMessage * messageItem) {
    if (messageItem != Q_NULLPTR) {
        messagesModel.remove (messageItem);
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
    set_lastReceivedMessageId_withJSON   (json ["last_message"].toObject () ["id"]);
}

QtTdLibMessageRefWatcher * QtTdLibChat::getMessageRefById (const QString & id) {
    return (id != "0" ? new QtTdLibMessageRefWatcher { id.toLongLong (), this } : Q_NULLPTR);
}

QtTdLibChatPhoto::QtTdLibChatPhoto (QObject * parent)
    : QtTdLibAbstractObject { QtTdLibObjectType::CHAT_PHOTO, parent }
{ }

void QtTdLibChatPhoto::updateFromJson (const QJsonObject & json) {
    set_big_withJSON   (json ["big"].toObject (),   &QtTdLibFile::create);
    set_small_withJSON (json ["small"].toObject (), &QtTdLibFile::create);
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

QtTdLibSupergroup::QtTdLibSupergroup (const qint32 id, QObject * parent)
    : QtTdLibAbstractInt32IdObject { QtTdLibObjectType::SUPERGROUP, id, parent }
    , m_members { new QQmlObjectListModel<QtTdLibChatMember> { this } }
{
    QtTdLibCollection::allSupergroups.insert (id, this);
}

void QtTdLibSupergroup::updateFromJson (const QJsonObject & json) {
    set_username_withJSON                 (json ["username"]);
    set_date_withJSON                     (json ["date"]);
    set_memberCount_withJSON              (json ["member_count"]);
    set_anyoneCanInvite_withJSON          (json ["anyone_can_invite"]);
    set_signMessages_withJSON             (json ["sign_messages"]);
    set_isChannel_withJSON                (json ["is_channel"]);
    set_isVerified_withJSON               (json ["is_verified"]);
    set_restrictionReason_withJSON        (json ["string restriction_reason"]);
    set_description_withJSON              (json ["description"]);
    set_memberCount_withJSON              (json ["member_count"]);
    set_administratorCount_withJSON       (json ["administrator_count"]);
    set_restrictedCount_withJSON          (json ["restricted_count"]);
    set_bannedCount_withJSON              (json ["banned_count"]);
    set_canGetMembers_withJSON            (json ["can_get_members"]);
    set_canSetUsername_withJSON           (json ["can_set_username"]);
    set_canSetStickerSet_withJSON         (json ["can_set_sticker_set"]);
    set_isAllHistoryAvailable_withJSON    (json ["is_all_history_available"]);
    set_stickerSetId_withJSON             (json ["sticker_set_id"]);
    set_inviteLink_withJSON               (json ["invite_link"]);
    set_pinnedMessageId_withJSON          (json ["pinned_message_id"]);
    set_upgradedFromBasicGroupId_withJSON (json ["upgraded_from_basic_group_id"]);
    set_upgradedFromMaxMessageId_withJSON (json ["upgraded_from_max_message_id"]);
    set_status_withJSON                   (json ["status"], &QtTdLibChatMemberStatus::createAbstract);
}

QtTdLibBasicGroup::QtTdLibBasicGroup (const qint32 id, QObject * parent)
    : QtTdLibAbstractInt32IdObject { QtTdLibObjectType::BASIC_GROUP, id, parent }
    , m_members { new QQmlObjectListModel<QtTdLibChatMember> { this } }
{
    QtTdLibCollection::allBasicGroups.insert (id, this);
}

void QtTdLibBasicGroup::updateFromJson (const QJsonObject & json) {
    set_memberCount_withJSON             (json ["member_count"]);
    set_isActive_withJSON                (json ["is_active"]);
    set_everyoneIsAdministrator_withJSON (json ["everyone_is_administrator"]);
    set_upgradedToSupergroupId_withJSON  (json ["upgraded_to_supergroup_id"]);
    set_creatorUserId_withJSON           (json ["creator_user_id"]);
    set_inviteLink_withJSON              (json ["invite_link"]);
    set_status_withJSON                  (json ["status"], &QtTdLibChatMemberStatus::createAbstract);
    const QJsonArray membersJson = json ["members"].toArray ();
    QList<QtTdLibChatMember *> members { };
    members.reserve (membersJson.count ());
    for (const QJsonValue & memberTmp : membersJson) {
        members.append (QtTdLibChatMember::create (memberTmp.toObject ()));
    }
    m_members->clear ();
    m_members->append (members);
}

QtTdLibChatMemberStatus::QtTdLibChatMemberStatus (const QtTdLibObjectType::Type typeOf, QObject * parent)
    : QtTdLibAbstractObject { typeOf, parent }
{ }

QtTdLibChatMemberStatus * QtTdLibChatMemberStatus::createAbstract (const QJsonObject & json, QObject * parent) {
    switch (QtTdLibEnums::objectTypeEnumFromJson (json)) {
        case QtTdLibObjectType::CHAT_MEMBER_STATUS_ADMINISTRATOR: return QtTdLibChatMemberStatusAdministrator::create (json, parent);
        case QtTdLibObjectType::CHAT_MEMBER_STATUS_BANNED:        return QtTdLibChatMemberStatusBanned::create        (json, parent);
        case QtTdLibObjectType::CHAT_MEMBER_STATUS_CREATOR:       return QtTdLibChatMemberStatusCreator::create       (json, parent);
        case QtTdLibObjectType::CHAT_MEMBER_STATUS_LEFT:          return QtTdLibChatMemberStatusLeft::create          (json, parent);
        case QtTdLibObjectType::CHAT_MEMBER_STATUS_MEMBER:        return QtTdLibChatMemberStatusMember::create        (json, parent);
        case QtTdLibObjectType::CHAT_MEMBER_STATUS_RESTRICTED:    return QtTdLibChatMemberStatusRestricted::create    (json, parent);
        default: return Q_NULLPTR;
    }
}

QtTdLibChatMemberStatusAdministrator::QtTdLibChatMemberStatusAdministrator (QObject * parent)
    : QtTdLibChatMemberStatus { QtTdLibObjectType::CHAT_MEMBER_STATUS_ADMINISTRATOR, parent }
{ }

void QtTdLibChatMemberStatusAdministrator::updateFromJson (const QJsonObject & json) {
    set_canBeEdited_withJSON         (json ["can_be_edited"]);
    set_canChangeInfo_withJSON       (json ["can_change_info"]);
    set_canPostMessages_withJSON     (json ["can_post_messages"]);
    set_canEditMessages_withJSON     (json ["can_edit_messages"]);
    set_canDeleteMessages_withJSON   (json ["can_delete_messages"]);
    set_canInviteUsers_withJSON      (json ["can_invite_users"]);
    set_canRestrictMembers_withJSON  (json ["can_restrict_members"]);
    set_canPinMessages_withJSON      (json ["can_pin_messages"]);
    set_canPromoteMembers_withJSON   (json ["can_promote_members"]);
}

QtTdLibChatMemberStatusBanned::QtTdLibChatMemberStatusBanned (QObject * parent)
    : QtTdLibChatMemberStatus { QtTdLibObjectType::CHAT_MEMBER_STATUS_BANNED, parent }
{ }

void QtTdLibChatMemberStatusBanned::updateFromJson (const QJsonObject & json) {
    set_bannedUntilDate_withJSON (json ["banned_until_date"]);
}

QtTdLibChatMemberStatusCreator::QtTdLibChatMemberStatusCreator (QObject * parent)
    : QtTdLibChatMemberStatus { QtTdLibObjectType::CHAT_MEMBER_STATUS_CREATOR, parent }
{ }

void QtTdLibChatMemberStatusCreator::updateFromJson (const QJsonObject & json) {
    set_isMember_withJSON (json ["is_member"]);
}

QtTdLibChatMemberStatusLeft::QtTdLibChatMemberStatusLeft (QObject * parent)
    : QtTdLibChatMemberStatus { QtTdLibObjectType::CHAT_MEMBER_STATUS_LEFT, parent }
{ }

QtTdLibChatMemberStatusMember::QtTdLibChatMemberStatusMember (QObject * parent)
    : QtTdLibChatMemberStatus { QtTdLibObjectType::CHAT_MEMBER_STATUS_MEMBER, parent }
{ }

QtTdLibChatMemberStatusRestricted::QtTdLibChatMemberStatusRestricted (QObject * parent)
    : QtTdLibChatMemberStatus { QtTdLibObjectType::CHAT_MEMBER_STATUS_RESTRICTED, parent }
{ }

void QtTdLibChatMemberStatusRestricted::updateFromJson (const QJsonObject & json) {
    set_isMember_withJSON              (json ["is_member"]);
    set_canSendMessages_withJSON       (json ["restricted_until_date"]);
    set_canSendMediaMessages_withJSON  (json ["can_send_messages"]);
    set_canSendOtherMessages_withJSON  (json ["can_send_media_messages"]);
    set_canAddWebPagePreviews_withJSON (json ["can_send_other_messages"]);
    set_restrictedUntilDate_withJSON   (json ["can_add_web_page_previews"]);
}

QtTdLibChatMember::QtTdLibChatMember (QObject * parent)
    : QtTdLibAbstractObject { QtTdLibObjectType::CHAT_MEMBER, parent }
{ }

void QtTdLibChatMember::updateFromJson (const QJsonObject & json) {
    set_userId_withJSON         (json ["user_id"]);
    set_inviterUserId_withJSON  (json ["inviter_user_id"]);
    set_joinedChatDate_withJSON (json ["joined_chat_date"]);
    set_status_withJSON         (json ["status"], &QtTdLibChatMemberStatus::createAbstract);
}

QtTdLibMessageRefWatcher::QtTdLibMessageRefWatcher (const qint64 messageId, QtTdLibChat * parent)
    : QObject       { parent }
    , m_messageItem { (parent ? parent->getMessageItemById (messageId) : Q_NULLPTR) }
    , m_messageId   { messageId }
{
    if (m_messageItem == Q_NULLPTR) {
        if (parent != Q_NULLPTR) {
            connect (parent, &QtTdLibChat::messageItemAdded, this, &QtTdLibMessageRefWatcher::onMessageItemAdded);
            if (QtTdLibGlobal * global = { qobject_cast<QtTdLibGlobal *> (parent->parent ()) }) {
                global->loadSingleMessageRef (parent, m_messageId);
            }
        }
    }
}

void QtTdLibMessageRefWatcher::onMessageItemAdded(QtTdLibMessage * messageItem) {
    if (messageItem->get_id () == m_messageId) {
        set_messageItem (messageItem);
        disconnect (qobject_cast<QtTdLibChat *> (parent ()), &QtTdLibChat::messageItemAdded, this, &QtTdLibMessageRefWatcher::onMessageItemAdded);
    }
}
