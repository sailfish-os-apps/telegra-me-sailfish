
#include "QtTdLibChat.h"
#include "QtTdLibMessage.h"

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

QtTdLibMessageText::QtTdLibMessageText (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_TEXT, parent }
{ }

void QtTdLibMessageText::updateFromJson (const QJsonObject & json) {
    set_text_withJSON    (json ["text"],     &QtTdLibFormattedText::create);
    set_webPage_withJSON (json ["web_page"], &QtTdLibWebPage::create);
}

QtTdLibMessage::QtTdLibMessage (const qint64 id, QObject * parent)
    : QtTdLibAbstractInt53IdObject { QtTdLibObjectType::MESSAGE, id, parent }
{
    if (QtTdLibChat * chatItem = { qobject_cast<QtTdLibChat *> (parent) }) {
        chatItem->allMessages.insert (id, this);
    }
}

QtTdLibMessage::~QtTdLibMessage (void) {
    if (QtTdLibChat * chatItem = { qobject_cast<QtTdLibChat *> (parent ()) }) {
        chatItem->allMessages.remove (get_id ());
    }
}

void QtTdLibMessage::updateFromJson (const QJsonObject & json) {
    set_date_withJSON             (json ["date"]);
    set_senderUserId_withJSON     (json ["sender_user_id"]);
    set_chatId_withJSON           (json ["chat_id"]);
    set_isOutgoing_withJSON       (json ["is_outgoing"]);
    set_editDate_withJSON         (json ["edit_date"]);
    set_views_withJSON            (json ["views"]);
    set_replyToMessageId_withJSON (json ["reply_to_message_id"]);
    set_mediaAlbumId_withJSON     (json ["media_album_id"]);
    set_content_withJSON          (json ["content"], &QtTdLibMessageContent::createAbstract);
}

QtTdLibMessagePhoto::QtTdLibMessagePhoto (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_PHOTO, parent }
{ }

void QtTdLibMessagePhoto::updateFromJson (const QJsonObject & json) {
    set_caption_withJSON (json ["caption"], &QtTdLibFormattedText::create);
    set_photo_withJSON   (json ["photo"],   &QtTdLibPhoto::create);
}

QtTdLibMessageDocument::QtTdLibMessageDocument (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_DOCUMENT, parent }
{ }

void QtTdLibMessageDocument::updateFromJson (const QJsonObject & json) {
    set_caption_withJSON  (json ["caption"],  &QtTdLibFormattedText::create);
    set_document_withJSON (json ["document"], &QtTdLibDocument::create);
}

QtTdLibMessageSticker::QtTdLibMessageSticker (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_STICKER, parent }
{ }

void QtTdLibMessageSticker::updateFromJson (const QJsonObject & json) {
    set_sticker_withJSON (json ["sticker"], &QtTdLibSticker::create);
}

QtTdLibMessageAnimation::QtTdLibMessageAnimation (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_ANIMATION, parent }
{ }

void QtTdLibMessageAnimation::updateFromJson (const QJsonObject & json) {
    set_caption_withJSON   (json ["caption"],   &QtTdLibFormattedText::create);
    set_animation_withJSON (json ["animation"], &QtTdLibAnimation::create);
}

QtTdLibMessageVideoNote::QtTdLibMessageVideoNote (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_VIDEO_NOTE, parent }
{ }

void QtTdLibMessageVideoNote::updateFromJson (const QJsonObject & json) {
    set_isViewed_withJSON  (json ["is_viewed"]);
    set_videoNote_withJSON (json ["video_note"], &QtTdLibVideoNote::create);
}

QtTdLibMessageVoiceNote::QtTdLibMessageVoiceNote (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_VOICE_NOTE, parent }
{ }

void QtTdLibMessageVoiceNote::updateFromJson (const QJsonObject & json) {
    set_isListened_withJSON (json ["is_listened"]);
    set_caption_withJSON    (json ["caption"],    &QtTdLibFormattedText::create);
    set_voiceNote_withJSON  (json ["voice_note"], &QtTdLibVoiceNote::create);
}

QtTdLibMessageVideo::QtTdLibMessageVideo (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_VIDEO, parent }
{ }

void QtTdLibMessageVideo::updateFromJson (const QJsonObject & json) {
    set_caption_withJSON (json ["caption"], &QtTdLibFormattedText::create);
    set_video_withJSON   (json ["video"],   &QtTdLibVideo::create);
}

QtTdLibMessageAudio::QtTdLibMessageAudio (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_AUDIO, parent }
{ }

void QtTdLibMessageAudio::updateFromJson (const QJsonObject & json) {
    set_caption_withJSON (json ["caption"], &QtTdLibFormattedText::create);
    set_audio_withJSON   (json ["audio"],   &QtTdLibAudio::create);
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

QtTdLibMessageSupergroupChatCreate::QtTdLibMessageSupergroupChatCreate (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_SUPERGROUP_CHAT_CREATE, parent }
{ }

void QtTdLibMessageSupergroupChatCreate::updateFromJson (const QJsonObject & json) {
    set_title_withJSON (json ["title"]);
}

QtTdLibMessageChatChangeTitle::QtTdLibMessageChatChangeTitle (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_CHAT_CHANGE_TITLE, parent }
{ }

void QtTdLibMessageChatChangeTitle::updateFromJson (const QJsonObject & json) {
    set_title_withJSON (json ["title"]);
}

QtTdLibMessageChatChangePhoto::QtTdLibMessageChatChangePhoto (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_CHAT_CHANGE_PHOTO, parent }
{ }

void QtTdLibMessageChatChangePhoto::updateFromJson (const QJsonObject & json) {
    set_photo_withJSON (json ["photo"], &QtTdLibPhoto::create);
}

QtTdLibMessageChatDeletePhoto::QtTdLibMessageChatDeletePhoto (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_CHAT_DELETE_PHOTO, parent }
{ }

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

QtTdLibMessageChatJoinByLink::QtTdLibMessageChatJoinByLink (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_CHAT_JOIN_BY_LINK, parent }
{ }

QtTdLibMessageChatDeleteMember::QtTdLibMessageChatDeleteMember (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_CHAT_DELETE_MEMBER, parent }
{ }

void QtTdLibMessageChatDeleteMember::updateFromJson (const QJsonObject & json) {
    set_userId_withJSON (json ["user_id"]);
}

QtTdLibMessageChatUpgradeTo::QtTdLibMessageChatUpgradeTo (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_CHAT_UPGRADE_TO, parent }
{ }

void QtTdLibMessageChatUpgradeTo::updateFromJson (const QJsonObject & json) {
    set_supergroupId_withJSON (json ["supergroup_id"]);
}

QtTdLibMessageChatUpgradeFrom::QtTdLibMessageChatUpgradeFrom (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_CHAT_UPGRADE_FROM, parent }
{ }

void QtTdLibMessageChatUpgradeFrom::updateFromJson (const QJsonObject & json) {
    set_basicGroupId_withJSON (json ["basic_group_id"]);
    set_title_withJSON        (json ["title"]);
}

QtTdLibMessageContactRegistered::QtTdLibMessageContactRegistered (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_CONTACT_REGISTERED, parent }
{ }

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
