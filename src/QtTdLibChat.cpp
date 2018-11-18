
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
