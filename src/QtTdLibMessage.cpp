
#include "QtTdLibChat.h"
#include "QtTdLibMessage.h"
#include "QtTdLibUser.h"

QtTdLibMessageContent::QtTdLibMessageContent (const QtTdLibObjectType::Type typeOf, QObject * parent)
    : QtTdLibAbstractObject { typeOf, parent }
{ }

QtTdLibMessageContent * QtTdLibMessageContent::createAbstract (const QJsonObject & json, QObject * parent) {
    switch (QtTdLibEnums::objectTypeEnumFromJson (json)) {
        case QtTdLibObjectType::MESSAGE_ANIMATION:               return QtTdLibMessageAnimation::create            (json, parent);
        case QtTdLibObjectType::MESSAGE_AUDIO:                   return QtTdLibMessageAudio::create                (json, parent);
        case QtTdLibObjectType::MESSAGE_DOCUMENT:                return QtTdLibMessageDocument::create             (json, parent);
        case QtTdLibObjectType::MESSAGE_PHOTO:                   return QtTdLibMessagePhoto::create                (json, parent);
        case QtTdLibObjectType::MESSAGE_STICKER:                 return QtTdLibMessageSticker::create              (json, parent);
        case QtTdLibObjectType::MESSAGE_TEXT:                    return QtTdLibMessageText::create                 (json, parent);
        case QtTdLibObjectType::MESSAGE_VIDEO:                   return QtTdLibMessageVideo::create                (json, parent);
        case QtTdLibObjectType::MESSAGE_VIDEO_NOTE:              return QtTdLibMessageVideoNote::create            (json, parent);
        case QtTdLibObjectType::MESSAGE_VOICE_NOTE:              return QtTdLibMessageVoiceNote::create            (json, parent);
        case QtTdLibObjectType::MESSAGE_BASIC_GROUP_CHAT_CREATE: return QtTdLibMessageBasicGroupChatCreate::create (json, parent);
        case QtTdLibObjectType::MESSAGE_SUPERGROUP_CHAT_CREATE:  return QtTdLibMessageSupergroupChatCreate::create (json, parent);
        case QtTdLibObjectType::MESSAGE_CHAT_CHANGE_TITLE:       return QtTdLibMessageChatChangeTitle::create      (json, parent);
        case QtTdLibObjectType::MESSAGE_CHAT_CHANGE_PHOTO:       return QtTdLibMessageChatChangePhoto::create      (json, parent);
        case QtTdLibObjectType::MESSAGE_CHAT_DELETE_PHOTO:       return QtTdLibMessageChatDeletePhoto::create      (json, parent);
        case QtTdLibObjectType::MESSAGE_CHAT_ADD_MEMBERS:        return QtTdLibMessageChatAddMembers::create       (json, parent);
        case QtTdLibObjectType::MESSAGE_CHAT_DELETE_MEMBER:      return QtTdLibMessageChatDeleteMember::create     (json, parent);
        case QtTdLibObjectType::MESSAGE_CHAT_JOIN_BY_LINK:       return QtTdLibMessageChatJoinByLink::create       (json, parent);
        case QtTdLibObjectType::MESSAGE_CHAT_UPGRADE_TO:         return QtTdLibMessageChatUpgradeTo::create        (json, parent);
        case QtTdLibObjectType::MESSAGE_CHAT_UPGRADE_FROM:       return QtTdLibMessageChatUpgradeFrom::create      (json, parent);
        case QtTdLibObjectType::MESSAGE_CONTACT_REGISTERED:      return QtTdLibMessageContactRegistered::create    (json, parent);
        case QtTdLibObjectType::MESSAGE_CALL:                    return QtTdLibMessageCall::create                 (json, parent);
        default: return Q_NULLPTR;
    }
}

QString QtTdLibMessageContent::asString (void) const {
    return tr ("<Unsupported>");
}

QtTdLibMessageText::QtTdLibMessageText (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_TEXT, parent }
{ }

void QtTdLibMessageText::updateFromJson (const QJsonObject & json) {
    set_text_withJSON    (json ["text"],     &QtTdLibFormattedText::create);
    set_webPage_withJSON (json ["web_page"], &QtTdLibWebPage::create);
}

QString QtTdLibMessageText::asString (void) const {
    QString ret { };
    if (m_text) {
        ret += m_text->get_text ();
    }
    return ret;
}

QtTdLibMessage::QtTdLibMessage (const qint64 id, QObject * parent)
    : QtTdLibAbstractInt53IdObject { QtTdLibObjectType::MESSAGE, id, parent }
{
    if (QtTdLibChat * chatItem = { qobject_cast<QtTdLibChat *> (parent) }) {
        chatItem->allMessages.insert (id, this);
        QMetaObject::invokeMethod (chatItem, "messageItemAdded", Qt::QueuedConnection, Q_ARG (QtTdLibMessage *, this));
    }
}

QtTdLibMessage::~QtTdLibMessage (void) {
    if (QtTdLibChat * chatItem = { qobject_cast<QtTdLibChat *> (parent ()) }) {
        chatItem->allMessages.remove (get_id ());
    }
}

void QtTdLibMessage::updateFromJson (const QJsonObject & json) {
    set_date_withJSON                    (json ["date"]);
    set_senderUserId_withJSON            (json ["sender_user_id"]);
    set_chatId_withJSON                  (json ["chat_id"]);
    set_isOutgoing_withJSON              (json ["is_outgoing"]);
    set_editDate_withJSON                (json ["edit_date"]);
    set_views_withJSON                   (json ["views"]);
    set_replyToMessageId_withJSON        (json ["reply_to_message_id"]);
    set_mediaAlbumId_withJSON            (json ["media_album_id"]);
    set_canBeEdited_withJSON             (json ["can_be_edited"]);
    set_canBeForwarded_withJSON          (json ["can_be_forwarded"]);
    set_canBeDeletedOnlyForSelf_withJSON (json ["can_be_deleted_only_for_self"]);
    set_canBeDeletedForAllUsers_withJSON (json ["can_be_deleted_for_all_users"]);
    set_isChannelPost_withJSON           (json ["is_channel_post"]);
    set_containsUnreadMention_withJSON   (json ["contains_unread_mention"]);
    set_content_withJSON                 (json ["content"], &QtTdLibMessageContent::createAbstract);
}

QString QtTdLibMessage::preview (const bool multiline) const {
    QString ret { };
    if (QtTdLibUser * userItem = { QtTdLibCollection::allUsers.value (m_senderUserId, Q_NULLPTR) }) {
        ret += userItem->get_firstName ();
        ret += ' ';
        ret += userItem->get_lastName ();
        ret += " : ";
    }
    else if (QtTdLibChat * chatItem = { QtTdLibCollection::allChats.value (m_chatId, Q_NULLPTR) }) {
        ret += chatItem->get_title ();
        ret += " : ";
    }
    else { }
    if (multiline) {
        ret += "\n";
    }
    if (m_content) {
        ret += m_content->asString ();
    }
    return ret;
}

QtTdLibMessagePhoto::QtTdLibMessagePhoto (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_PHOTO, parent }
{ }

void QtTdLibMessagePhoto::updateFromJson (const QJsonObject & json) {
    set_caption_withJSON (json ["caption"], &QtTdLibFormattedText::create);
    set_photo_withJSON   (json ["photo"],   &QtTdLibPhoto::create);
}

QString QtTdLibMessagePhoto::asString (void) const {
    return tr ("Photo");
}

QtTdLibMessageDocument::QtTdLibMessageDocument (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_DOCUMENT, parent }
{ }

void QtTdLibMessageDocument::updateFromJson (const QJsonObject & json) {
    set_caption_withJSON  (json ["caption"],  &QtTdLibFormattedText::create);
    set_document_withJSON (json ["document"], &QtTdLibDocument::create);
}

QString QtTdLibMessageDocument::asString (void) const {
    QString ret { };
    ret += tr ("Document");
    if (m_document) {
        ret += " - ";
        ret += m_document->get_fileName ();
    }
    return ret;
}

QtTdLibMessageSticker::QtTdLibMessageSticker (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_STICKER, parent }
{ }

void QtTdLibMessageSticker::updateFromJson (const QJsonObject & json) {
    set_sticker_withJSON (json ["sticker"], &QtTdLibSticker::create);
}

QString QtTdLibMessageSticker::asString (void) const {
    QString ret { };
    ret += tr ("Sticker");
    if (m_sticker) {
        ret += " - ";
        ret += m_sticker->get_emoji ();
    }
    return ret;
}

QtTdLibMessageAnimation::QtTdLibMessageAnimation (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_ANIMATION, parent }
{ }

void QtTdLibMessageAnimation::updateFromJson (const QJsonObject & json) {
    set_caption_withJSON   (json ["caption"],   &QtTdLibFormattedText::create);
    set_animation_withJSON (json ["animation"], &QtTdLibAnimation::create);
}

QString QtTdLibMessageAnimation::asString (void) const {
    return tr ("Animation");
}

QtTdLibMessageVideoNote::QtTdLibMessageVideoNote (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_VIDEO_NOTE, parent }
{ }

void QtTdLibMessageVideoNote::updateFromJson (const QJsonObject & json) {
    set_isViewed_withJSON  (json ["is_viewed"]);
    set_videoNote_withJSON (json ["video_note"], &QtTdLibVideoNote::create);
}

QString QtTdLibMessageVideoNote::asString (void) const {
    QString ret { };
    ret += tr ("Video note");
    //if (m_videoNote) {
    //    ret += " - ";
    //    ret += m_videoNote->get_duration ();
    //}
    return ret;
}

QtTdLibMessageVoiceNote::QtTdLibMessageVoiceNote (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_VOICE_NOTE, parent }
{ }

void QtTdLibMessageVoiceNote::updateFromJson (const QJsonObject & json) {
    set_isListened_withJSON (json ["is_listened"]);
    set_caption_withJSON    (json ["caption"],    &QtTdLibFormattedText::create);
    set_voiceNote_withJSON  (json ["voice_note"], &QtTdLibVoiceNote::create);
}

QString QtTdLibMessageVoiceNote::asString (void) const {
    QString ret { };
    ret += tr ("Voice note");
    //if (m_voiceNote) {
    //    ret += " - ";
    //    ret += m_voiceNote->get_duration ();
    //}
    return ret;
}

QtTdLibMessageVideo::QtTdLibMessageVideo (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_VIDEO, parent }
{ }

void QtTdLibMessageVideo::updateFromJson (const QJsonObject & json) {
    set_caption_withJSON (json ["caption"], &QtTdLibFormattedText::create);
    set_video_withJSON   (json ["video"],   &QtTdLibVideo::create);
}

QString QtTdLibMessageVideo::asString (void) const {
    QString ret { };
    ret += tr ("Video");
    if (m_video) {
        ret += " - ";
        ret += m_video->get_fileName ();
    }
    return ret;
}

QtTdLibMessageAudio::QtTdLibMessageAudio (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_AUDIO, parent }
{ }

void QtTdLibMessageAudio::updateFromJson (const QJsonObject & json) {
    set_caption_withJSON (json ["caption"], &QtTdLibFormattedText::create);
    set_audio_withJSON   (json ["audio"],   &QtTdLibAudio::create);
}

QString QtTdLibMessageAudio::asString (void) const {
    QString ret { };
    ret += tr ("Music");
    if (m_audio) {
        ret += " - ";
        if (m_audio->get_title ().isEmpty () && m_audio->get_performer ().isEmpty ()) {
            ret += m_audio->get_fileName ();
        }
        else {
            ret += m_audio->get_title ();
            ret += " (";
            ret += m_audio->get_performer ();
            ret += ")";
        }
    }
    return ret;
}

QtTdLibMessageBasicGroupChatCreate::QtTdLibMessageBasicGroupChatCreate (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_BASIC_GROUP_CHAT_CREATE, parent }
{ }

void QtTdLibMessageBasicGroupChatCreate::updateFromJson (const QJsonObject & json) {
    set_title_withJSON (json ["title"]);
    QVariantList memberUserIds { };
    const QJsonArray listJson = json ["member_user_ids"].toArray ();
    memberUserIds.reserve (listJson.count ());
    for (const QJsonValue & tmpJson : listJson) {
        memberUserIds.append (tmpJson.toInt ());
    }
    set_memberUserIds (memberUserIds);
}

QString QtTdLibMessageBasicGroupChatCreate::asString (void) const {
    return tr ("Group chat created");
}

QtTdLibMessageSupergroupChatCreate::QtTdLibMessageSupergroupChatCreate (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_SUPERGROUP_CHAT_CREATE, parent }
{ }

void QtTdLibMessageSupergroupChatCreate::updateFromJson (const QJsonObject & json) {
    set_title_withJSON (json ["title"]);
}

QString QtTdLibMessageSupergroupChatCreate::asString (void) const {
    return tr ("Supergroup chat created");
}

QtTdLibMessageChatChangeTitle::QtTdLibMessageChatChangeTitle (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_CHAT_CHANGE_TITLE, parent }
{ }

void QtTdLibMessageChatChangeTitle::updateFromJson (const QJsonObject & json) {
    set_title_withJSON (json ["title"]);
}

QString QtTdLibMessageChatChangeTitle::asString (void) const {
    return tr ("Changed title to '%1'").arg (m_title);
}

QtTdLibMessageChatChangePhoto::QtTdLibMessageChatChangePhoto (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_CHAT_CHANGE_PHOTO, parent }
{ }

void QtTdLibMessageChatChangePhoto::updateFromJson (const QJsonObject & json) {
    set_photo_withJSON (json ["photo"], &QtTdLibPhoto::create);
}

QString QtTdLibMessageChatChangePhoto::asString (void) const {
    return tr ("Changed photo");
}

QtTdLibMessageChatDeletePhoto::QtTdLibMessageChatDeletePhoto (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_CHAT_DELETE_PHOTO, parent }
{ }

QString QtTdLibMessageChatDeletePhoto::asString (void) const {
    return tr ("Delete photo");
}

QtTdLibMessageChatAddMembers::QtTdLibMessageChatAddMembers (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_CHAT_ADD_MEMBERS, parent }
{ }

void QtTdLibMessageChatAddMembers::updateFromJson (const QJsonObject & json) {
    QVariantList memberUserIds { };
    const QJsonArray listJson = json ["member_user_ids"].toArray ();
    memberUserIds.reserve (listJson.count ());
    for (const QJsonValue & tmpJson : listJson) {
        memberUserIds.append (tmpJson.toInt ());
    }
    set_memberUserIds (memberUserIds);
}

QString QtTdLibMessageChatAddMembers::asString (void) const {
    QString ret { };
    ret += tr ("Added ");
    QStringList tmp { };
    for (const QVariant & userIdVar : m_memberUserIds) {
        if (QtTdLibUser * userItem = { QtTdLibCollection::allUsers.value (userIdVar.toString ().toLongLong (), Q_NULLPTR) }) {
            tmp.append (userItem->get_firstName () % ' ' % userItem->get_lastName ());
        }
    }
    ret += tmp.join (", ");
    return ret;
}

QtTdLibMessageChatJoinByLink::QtTdLibMessageChatJoinByLink (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_CHAT_JOIN_BY_LINK, parent }
{ }

QString QtTdLibMessageChatJoinByLink::asString (void) const {
    return tr ("Joined chat");
}

QtTdLibMessageChatDeleteMember::QtTdLibMessageChatDeleteMember (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_CHAT_DELETE_MEMBER, parent }
{ }

void QtTdLibMessageChatDeleteMember::updateFromJson (const QJsonObject & json) {
    set_userId_withJSON (json ["user_id"]);
}

QString QtTdLibMessageChatDeleteMember::asString (void) const {
    QString ret { };
    ret += tr ("Removed ");
    if (QtTdLibUser * userItem = { QtTdLibCollection::allUsers.value (m_userId, Q_NULLPTR) }) {
        ret += userItem->get_firstName ();
        ret += ' ';
        ret += userItem->get_lastName ();
    }
    return ret;
}

QtTdLibMessageChatUpgradeTo::QtTdLibMessageChatUpgradeTo (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_CHAT_UPGRADE_TO, parent }
{ }

void QtTdLibMessageChatUpgradeTo::updateFromJson (const QJsonObject & json) {
    set_supergroupId_withJSON (json ["supergroup_id"]);
}

QString QtTdLibMessageChatUpgradeTo::asString (void) const {
    return tr ("Upgraded to super-group");
}

QtTdLibMessageChatUpgradeFrom::QtTdLibMessageChatUpgradeFrom (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_CHAT_UPGRADE_FROM, parent }
{ }

void QtTdLibMessageChatUpgradeFrom::updateFromJson (const QJsonObject & json) {
    set_basicGroupId_withJSON (json ["basic_group_id"]);
    set_title_withJSON        (json ["title"]);
}

QString QtTdLibMessageChatUpgradeFrom::asString (void) const {
    return tr ("Upgraded from basic group");
}

QtTdLibMessageContactRegistered::QtTdLibMessageContactRegistered (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_CONTACT_REGISTERED, parent }
{ }

QString QtTdLibMessageContactRegistered::asString (void) const {
    return tr ("Registered in Telegram");
}

QtTdLibMessageCall::QtTdLibMessageCall (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_CALL, parent }
{ }

void QtTdLibMessageCall::updateFromJson (const QJsonObject & json) {
    set_duration_withJSON      (json ["duration"]);
    set_discardReason_withJSON (json ["discard_reason"], &QtTdLibCallDiscardReason::createAbstract);
}

QtTdLibCallDiscardReason::QtTdLibCallDiscardReason (const QtTdLibObjectType::Type typeOf, QObject * parent)
    : QtTdLibAbstractObject { typeOf, parent }
{ }

QtTdLibCallDiscardReason * QtTdLibCallDiscardReason::createAbstract (const QJsonObject & json, QObject * parent) {
    switch (QtTdLibEnums::objectTypeEnumFromJson (json)) {
        case QtTdLibObjectType::CALL_DISCARD_REASON_DECLINED:     return QtTdLibCallDiscardReasonDeclined::create     (json, parent);
        case QtTdLibObjectType::CALL_DISCARD_REASON_DISCONNECTED: return QtTdLibCallDiscardReasonDisconnected::create (json, parent);
        case QtTdLibObjectType::CALL_DISCARD_REASON_EMPTY:        return QtTdLibCallDiscardReasonEmpty::create        (json, parent);
        case QtTdLibObjectType::CALL_DISCARD_REASON_HUNG_UP:      return QtTdLibCallDiscardReasonHungUp::create       (json, parent);
        case QtTdLibObjectType::CALL_DISCARD_REASON_MISSED:       return QtTdLibCallDiscardReasonMissed::create       (json, parent);
        default: return Q_NULLPTR;
    }
}

QtTdLibCallDiscardReasonDeclined::QtTdLibCallDiscardReasonDeclined (QObject * parent)
    : QtTdLibCallDiscardReason { QtTdLibObjectType::CALL_DISCARD_REASON_DECLINED, parent }
{ }

QtTdLibCallDiscardReasonDisconnected::QtTdLibCallDiscardReasonDisconnected (QObject * parent)
    : QtTdLibCallDiscardReason { QtTdLibObjectType::CALL_DISCARD_REASON_DISCONNECTED, parent }
{ }

QtTdLibCallDiscardReasonEmpty::QtTdLibCallDiscardReasonEmpty (QObject * parent)
    : QtTdLibCallDiscardReason { QtTdLibObjectType::CALL_DISCARD_REASON_EMPTY, parent }
{ }

QtTdLibCallDiscardReasonHungUp::QtTdLibCallDiscardReasonHungUp (QObject * parent)
    : QtTdLibCallDiscardReason { QtTdLibObjectType::CALL_DISCARD_REASON_HUNG_UP, parent }
{ }

QtTdLibCallDiscardReasonMissed::QtTdLibCallDiscardReasonMissed (QObject * parent)
    : QtTdLibCallDiscardReason { QtTdLibObjectType::CALL_DISCARD_REASON_MISSED, parent }
{ }
