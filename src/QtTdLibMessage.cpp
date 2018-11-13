
#include "QtTdLibChat.h"
#include "QtTdLibMessage.h"

QtTdLibMessageContent::QtTdLibMessageContent (const QtTdLibObjectType::Type typeOf, QObject * parent)
    : QtTdLibAbstractObject { typeOf, parent }
{ }

QtTdLibMessageContent * QtTdLibMessageContent::createXXX (const QJsonObject & json, QObject * parent) {
    switch (QtTdLibEnums::objectTypeEnumFromJson (json)) {
        case QtTdLibObjectType::MESSAGE_ANIMATION:  return QtTdLibMessageAnimation::create (json, parent);
        case QtTdLibObjectType::MESSAGE_AUDIO:      return QtTdLibMessageAudio::create     (json, parent);
        case QtTdLibObjectType::MESSAGE_DOCUMENT:   return QtTdLibMessageDocument::create  (json, parent);
        case QtTdLibObjectType::MESSAGE_PHOTO:      return QtTdLibMessagePhoto::create     (json, parent);
        case QtTdLibObjectType::MESSAGE_STICKER:    return QtTdLibMessageSticker::create   (json, parent);
        case QtTdLibObjectType::MESSAGE_TEXT:       return QtTdLibMessageText::create      (json, parent);
        case QtTdLibObjectType::MESSAGE_VIDEO:      return QtTdLibMessageVideo::create     (json, parent);
        case QtTdLibObjectType::MESSAGE_VIDEO_NOTE: return QtTdLibMessageVideoNote::create (json, parent);
        case QtTdLibObjectType::MESSAGE_VOICE_NOTE: return QtTdLibMessageVoiceNote::create (json, parent);
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

void QtTdLibMessage::updateFromJson (const QJsonObject & json) {
    set_date_withJSON             (json ["date"]);
    set_senderUserId_withJSON     (json ["sender_user_id"]);
    set_chatId_withJSON           (json ["chat_id"]);
    set_isOutgoing_withJSON       (json ["is_outgoing"]);
    set_editDate_withJSON         (json ["edit_date"]);
    set_views_withJSON            (json ["views"]);
    set_replyToMessageId_withJSON (json ["reply_to_message_id"]);
    set_mediaAlbumId_withJSON     (json ["media_album_id"]);
    set_content_withJSON          (json ["content"], &QtTdLibMessageContent::createXXX);
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
