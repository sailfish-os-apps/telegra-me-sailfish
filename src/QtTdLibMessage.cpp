
#include "QtTdLibMessage.h"

QtTdLibMessageContent::QtTdLibMessageContent (const QtTdLibObjectType::Type typeOf, QObject * parent)
    : QtTdLibAbstractObject { typeOf, parent }
{ }

QtTdLibMessageContent * QtTdLibMessageContent::create (const QJsonObject & json, QObject * parent) {
    switch (QtTdLibEnums::objectTypeEnumFromJson (json)) {
        case QtTdLibObjectType::MESSAGE_ANIMATION:  return new QtTdLibMessageAnimation { parent };
        case QtTdLibObjectType::MESSAGE_AUDIO:      return new QtTdLibMessageAudio     { parent };
        case QtTdLibObjectType::MESSAGE_DOCUMENT:   return new QtTdLibMessageDocument  { parent };
        case QtTdLibObjectType::MESSAGE_PHOTO:      return new QtTdLibMessagePhoto     { parent };
        case QtTdLibObjectType::MESSAGE_STICKER:    return new QtTdLibMessageSticker   { parent };
        case QtTdLibObjectType::MESSAGE_TEXT:       return new QtTdLibMessageText      { parent };
        case QtTdLibObjectType::MESSAGE_VIDEO:      return new QtTdLibMessageVideo     { parent };
        case QtTdLibObjectType::MESSAGE_VIDEO_NOTE: return new QtTdLibMessageVideoNote { parent };
        case QtTdLibObjectType::MESSAGE_VOICE_NOTE: return new QtTdLibMessageVoiceNote { parent };
        default: return Q_NULLPTR;
    }
}

QtTdLibMessageText::QtTdLibMessageText (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_TEXT, parent }
{ }

void QtTdLibMessageText::updateFromJson (const QJsonObject & json) {
    set_text_withJSON    (json ["text"],     &QtTdLibAbstractObject::create<QtTdLibFormattedText>);
    set_webPage_withJSON (json ["web_page"], &QtTdLibAbstractObject::create<QtTdLibWebPage>);
}

QtTdLibMessage::QtTdLibMessage (const qint64 id, QObject * parent)
    : QtTdLibAbstractInt53IdObject { QtTdLibObjectType::MESSAGE, id, parent }
{
    QtTdLibCollection::allMessages.insert (id, this);
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
    set_content_withJSON          (json ["content"], &QtTdLibMessageContent::create);
}

QtTdLibMessagePhoto::QtTdLibMessagePhoto (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_PHOTO, parent }
{ }

void QtTdLibMessagePhoto::updateFromJson (const QJsonObject & json) {
    set_caption_withJSON (json ["caption"], &QtTdLibAbstractObject::create<QtTdLibFormattedText>);
    set_photo_withJSON   (json ["photo"],   &QtTdLibAbstractInt64IdObject::create<QtTdLibPhoto>);
}

QtTdLibMessageDocument::QtTdLibMessageDocument (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_DOCUMENT, parent }
{ }

void QtTdLibMessageDocument::updateFromJson (const QJsonObject & json) {
    set_caption_withJSON  (json ["caption"],  &QtTdLibAbstractObject::create<QtTdLibFormattedText>);
    set_document_withJSON (json ["document"], &QtTdLibAbstractObject::create<QtTdLibDocument>);
}

QtTdLibMessageSticker::QtTdLibMessageSticker (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_STICKER, parent }
{ }

void QtTdLibMessageSticker::updateFromJson (const QJsonObject & json) {
    set_sticker_withJSON (json ["sticker"], &QtTdLibAbstractObject::create<QtTdLibSticker>);
}

QtTdLibMessageAnimation::QtTdLibMessageAnimation (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_ANIMATION, parent }
{ }

void QtTdLibMessageAnimation::updateFromJson (const QJsonObject & json) {
    set_caption_withJSON   (json ["caption"],   &QtTdLibAbstractObject::create<QtTdLibFormattedText>);
    set_animation_withJSON (json ["animation"], &QtTdLibAbstractObject::create<QtTdLibAnimation>);
}

QtTdLibMessageVideoNote::QtTdLibMessageVideoNote (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_VIDEO_NOTE, parent }
{ }

void QtTdLibMessageVideoNote::updateFromJson (const QJsonObject & json) {
    set_isViewed_withJSON  (json ["is_viewed"]);
    set_videoNote_withJSON (json ["video_note"], &QtTdLibAbstractObject::create<QtTdLibVideoNote>);
}

QtTdLibMessageVoiceNote::QtTdLibMessageVoiceNote (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_VOICE_NOTE, parent }
{ }

void QtTdLibMessageVoiceNote::updateFromJson (const QJsonObject & json) {
    set_isListened_withJSON (json ["is_listened"]);
    set_caption_withJSON    (json ["caption"],    &QtTdLibAbstractObject::create<QtTdLibFormattedText>);
    set_voiceNote_withJSON  (json ["voice_note"], &QtTdLibAbstractObject::create<QtTdLibVoiceNote>);
}

QtTdLibMessageVideo::QtTdLibMessageVideo (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_VIDEO, parent }
{ }

void QtTdLibMessageVideo::updateFromJson (const QJsonObject & json) {
    set_caption_withJSON (json ["caption"], &QtTdLibAbstractObject::create<QtTdLibFormattedText>);
    set_video_withJSON   (json ["video"],   &QtTdLibAbstractObject::create<QtTdLibVideo>);
}

QtTdLibMessageAudio::QtTdLibMessageAudio (QObject * parent)
    : QtTdLibMessageContent { QtTdLibObjectType::MESSAGE_AUDIO, parent }
{ }

void QtTdLibMessageAudio::updateFromJson (const QJsonObject & json) {
    set_caption_withJSON (json ["caption"], &QtTdLibAbstractObject::create<QtTdLibFormattedText>);
    set_audio_withJSON   (json ["audio"],   &QtTdLibAbstractObject::create<QtTdLibAudio>);
}
