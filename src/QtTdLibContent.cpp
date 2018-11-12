
#include "QtTdLibContent.h"

QtTdLibFormattedText::QtTdLibFormattedText (QObject * parent)
    : QtTdLibAbstractObject { QtTdLibObjectType::FORMATTED_TEXT, parent }
    , m_entities         { new QQmlObjectListModel<QtTdLibTextEntity> { this } }
{ }

void QtTdLibFormattedText::updateFromJson (const QJsonObject & json) {
    set_text_withJSON (json ["text"]);
    const QJsonArray entitiesList = json ["entities"].toArray ();
    QList<QtTdLibTextEntity *> list { };
    list.reserve (entitiesList.size ());
    for (const QJsonValue & tmp : entitiesList) {
        QtTdLibTextEntity * entity = new QtTdLibTextEntity;
        entity->updateFromJson (tmp.toObject ());
        list.append (entity);
    }
    m_entities->clear ();
    m_entities->append (list);
}

QtTdLibPhotoSize::QtTdLibPhotoSize (QObject * parent)
    : QtTdLibAbstractObject { QtTdLibObjectType::PHOTO_SIZE, parent }
{ }

void QtTdLibPhotoSize::updateFromJson (const QJsonObject & json) {
    set_type_withJSON   (json ["type"]);
    set_width_withJSON  (json ["width"]);
    set_height_withJSON (json ["height"]);
    set_photo_withJSON  (json ["photo"], &QtTdLibAbstractInt32IdObject::create<QtTdLibFile>);
}

QtTdLibPhoto::QtTdLibPhoto (const qint64 id, QObject * parent)
    : QtTdLibAbstractInt64IdObject { QtTdLibObjectType::PHOTO, id, parent }
    , m_sizes { new QQmlObjectListModel<QtTdLibPhotoSize> { this, "", "type" } }
{ }

void QtTdLibPhoto::updateFromJson (const QJsonObject & json) {
    set_hasStickers_withJSON (json ["has_stickers"]);
    const QJsonArray sizesList = json ["sizes"].toArray ();
    QList<QtTdLibPhotoSize *> list { };
    list.reserve (sizesList.size ());
    for (const QJsonValue & tmp : sizesList) {
        QtTdLibPhotoSize * photoSize = new QtTdLibPhotoSize { };
        photoSize->updateFromJson (tmp.toObject ());
        list.append (photoSize);
    }
    m_sizes->clear ();
    m_sizes->append (list);
}

QtTdLibDocument::QtTdLibDocument (QObject * parent)
    : QtTdLibAbstractObject { QtTdLibObjectType::DOCUMENT, parent }
{ }

void QtTdLibDocument::updateFromJson (const QJsonObject & json) {
    set_fileName_withJSON  (json ["file_name"]);
    set_mimeType_withJSON  (json ["mime_type"]);
    set_thumbnail_withJSON (json ["thumbnail"], &QtTdLibAbstractObject::create<QtTdLibPhotoSize>);
    set_document_withJSON  (json ["document"],  &QtTdLibAbstractInt32IdObject::create<QtTdLibFile>);
}

QtTdLibSticker::QtTdLibSticker (QObject * parent)
    : QtTdLibAbstractObject { QtTdLibObjectType::STICKER, parent }
{ }

void QtTdLibSticker::updateFromJson (const QJsonObject & json) {
    set_setId_withJSON     (json ["set_id"]);
    set_width_withJSON     (json ["width"]);
    set_height_withJSON    (json ["height"]);
    set_isMask_withJSON    (json ["is_mask"]);
    set_emoji_withJSON     (json ["emoji"]);
    set_thumbnail_withJSON (json ["thumbnail"], &QtTdLibAbstractObject::create<QtTdLibPhotoSize>);
    set_sticker_withJSON   (json ["sticker"],   &QtTdLibAbstractInt32IdObject::create<QtTdLibFile>);
}

QtTdLibWebPage::QtTdLibWebPage (QObject * parent)
    : QtTdLibAbstractObject { QtTdLibObjectType::WEB_PAGE, parent }
{ }

void QtTdLibWebPage::updateFromJson (const QJsonObject & json) {
    set_url_withJSON            (json ["url"]);
    set_displayUrl_withJSON     (json ["display_url"]);
    set_type_withJSON           (json ["type"]);
    set_siteName_withJSON       (json ["site_name"]);
    set_title_withJSON          (json ["title"]);
    set_description_withJSON    (json ["description"]);
    set_author_withJSON         (json ["author"]);
    set_embedUrl_withJSON       (json ["embed_url"]);
    set_embedType_withJSON      (json ["embed_type"]);
    set_embedWidth_withJSON     (json ["embed_width"]);
    set_embedHeight_withJSON    (json ["embed_height"]);
    set_duration_withJSON       (json ["duration"]);
    set_hasInstantView_withJSON (json ["has_instant_view"]);
    set_photo_withJSON          (json ["photo"],      &QtTdLibAbstractInt64IdObject::create<QtTdLibPhoto>);
    set_document_withJSON       (json ["document"],   &QtTdLibAbstractObject::create<QtTdLibDocument>);
    set_sticker_withJSON        (json ["sticker"],    &QtTdLibAbstractObject::create<QtTdLibSticker>);
    set_animation_withJSON      (json ["animation"],  &QtTdLibAbstractObject::create<QtTdLibAnimation>);
    set_voiceNote_withJSON      (json ["voice_note"], &QtTdLibAbstractObject::create<QtTdLibVoiceNote>);
    set_videoNote_withJSON      (json ["video_note"], &QtTdLibAbstractObject::create<QtTdLibVideoNote>);
    set_audio_withJSON          (json ["audio"],      &QtTdLibAbstractObject::create<QtTdLibAudio>);
    set_video_withJSON          (json ["video"],      &QtTdLibAbstractObject::create<QtTdLibVideo>);
}

QtTdLibAnimation::QtTdLibAnimation (QObject * parent)
    : QtTdLibAbstractObject { QtTdLibObjectType::ANIMATION, parent }
{ }

void QtTdLibAnimation::updateFromJson (const QJsonObject & json) {
    set_duration_withJSON  (json ["duration"]);
    set_width_withJSON     (json ["width"]);
    set_height_withJSON    (json ["height"]);
    set_fileName_withJSON  (json ["file_name"]);
    set_mimeType_withJSON  (json ["mime_type"]);
    set_thumbnail_withJSON (json ["thumbnail"], &QtTdLibAbstractObject::create<QtTdLibPhotoSize>);
    set_animation_withJSON (json ["animation"], &QtTdLibAbstractInt32IdObject::create<QtTdLibFile>);
}

QtTdLibVoiceNote::QtTdLibVoiceNote (QObject * parent)
    : QtTdLibAbstractObject { QtTdLibObjectType::VOICE_NOTE, parent }
{ }

void QtTdLibVoiceNote::updateFromJson (const QJsonObject & json) {
    set_duration_withJSON (json ["duration"]);
    set_mimeType_withJSON (json ["mime_type"]);
    set_waveform_withJSON (json ["waveform"]);
    set_voice_withJSON    (json ["voice"], &QtTdLibAbstractInt32IdObject::create<QtTdLibFile>);
}

QtTdLibVideoNote::QtTdLibVideoNote (QObject * parent)
    : QtTdLibAbstractObject { QtTdLibObjectType::VIDEO_NOTE, parent }
{ }

void QtTdLibVideoNote::updateFromJson (const QJsonObject & json) {
    set_duration_withJSON  (json ["duration"]);
    set_length_withJSON    (json ["length"]);
    set_thumbnail_withJSON (json ["thumbnail"], &QtTdLibAbstractObject::create<QtTdLibPhotoSize>);
    set_video_withJSON     (json ["video"],     &QtTdLibAbstractInt32IdObject::create<QtTdLibFile>);
}

QtTdLibVideo::QtTdLibVideo (QObject * parent)
    : QtTdLibAbstractObject { QtTdLibObjectType::VIDEO, parent }
{ }

void QtTdLibVideo::updateFromJson (const QJsonObject & json) {
    set_duration_withJSON      (json ["duration"]);
    set_width_withJSON         (json ["width"]);
    set_height_withJSON        (json ["height"]);
    set_fileName_withJSON      (json ["file_name"]);
    set_mimeType_withJSON      (json ["mime_type"]);
    set_hasStickers_withJSON   (json ["has_stickers"]);
    set_thumbnail_withJSON     (json ["thumbnail"], &QtTdLibAbstractObject::create<QtTdLibPhotoSize>);
    set_video_withJSON         (json ["video"],     &QtTdLibAbstractInt32IdObject::create<QtTdLibFile>);
}

QtTdLibAudio::QtTdLibAudio (QObject * parent)
    : QtTdLibAbstractObject { QtTdLibObjectType::AUDIO, parent }
{ }

void QtTdLibAudio::updateFromJson (const QJsonObject & json) {
    set_duration_withJSON            (json ["duration"]);
    set_title_withJSON               (json ["title"]);
    set_performer_withJSON           (json ["performer"]);
    set_fileName_withJSON            (json ["file_name"]);
    set_mimeType_withJSON            (json ["mime_type"]);
    set_albumCoverThumbnail_withJSON (json ["album_cover_thumbnail"], &QtTdLibAbstractObject::create<QtTdLibPhotoSize>);
    set_audio_withJSON               (json ["audio"],                 &QtTdLibAbstractInt32IdObject::create<QtTdLibFile>);
}

QtTdLibTextEntity::QtTdLibTextEntity (QObject * parent)
    : QtTdLibAbstractObject { QtTdLibObjectType::TEXT_ENTITY, parent }
{ }

void QtTdLibTextEntity::updateFromJson (const QJsonObject & json) {
    set_offset_withJSON (json ["offset"]);
    set_length_withJSON (json ["length"]);
    set_type_withJSON   (json ["type"], &QtTdLibTextEntityType::create);
}

QtTdLibTextEntityType::QtTdLibTextEntityType (const QtTdLibObjectType::Type typeOf, QObject * parent)
    : QtTdLibAbstractObject { typeOf, parent }
{ }

QtTdLibTextEntityType * QtTdLibTextEntityType::create (const QJsonObject & json, QObject * parent) {
    switch (QtTdLibEnums::objectTypeEnumFromJson (json)) {
        case QtTdLibObjectType::TEXT_ENTITY_TYPE_MENTION:       return new QtTdLibTextEntityTypeMention      { parent };
        case QtTdLibObjectType::TEXT_ENTITY_TYPE_HASHTAG:       return new QtTdLibTextEntityTypeHashtag      { parent };
        case QtTdLibObjectType::TEXT_ENTITY_TYPE_BOT_COMMAND:   return new QtTdLibTextEntityTypeBotCommand   { parent };
        case QtTdLibObjectType::TEXT_ENTITY_TYPE_URL:           return new QtTdLibTextEntityTypeUrl          { parent };
        case QtTdLibObjectType::TEXT_ENTITY_TYPE_EMAIL_ADDRESS: return new QtTdLibTextEntityTypeEmailAddress { parent };
        case QtTdLibObjectType::TEXT_ENTITY_TYPE_BOLD:          return new QtTdLibTextEntityTypeBold         { parent };
        case QtTdLibObjectType::TEXT_ENTITY_TYPE_ITALIC:        return new QtTdLibTextEntityTypeItalic       { parent };
        case QtTdLibObjectType::TEXT_ENTITY_TYPE_CODE:          return new QtTdLibTextEntityTypeCode         { parent };
        case QtTdLibObjectType::TEXT_ENTITY_TYPE_PRE:           return new QtTdLibTextEntityTypePre          { parent };
        case QtTdLibObjectType::TEXT_ENTITY_TYPE_PRE_CODE:      return new QtTdLibTextEntityTypePreCode      { parent };
        case QtTdLibObjectType::TEXT_ENTITY_TYPE_TEXT_URL:      return new QtTdLibTextEntityTypeTextUrl      { parent };
        case QtTdLibObjectType::TEXT_ENTITY_TYPE_MENTION_NAME:  return new QtTdLibTextEntityTypeMentionName  { parent };
        default: return Q_NULLPTR;
    }
}

QtTdLibTextEntityTypeMention::QtTdLibTextEntityTypeMention (QObject * parent)
    : QtTdLibTextEntityType { QtTdLibObjectType::TEXT_ENTITY_TYPE_MENTION, parent }
{ }

QtTdLibTextEntityTypeHashtag::QtTdLibTextEntityTypeHashtag (QObject * parent)
    : QtTdLibTextEntityType { QtTdLibObjectType::TEXT_ENTITY_TYPE_HASHTAG, parent }
{ }

QtTdLibTextEntityTypeBotCommand::QtTdLibTextEntityTypeBotCommand (QObject * parent)
    : QtTdLibTextEntityType { QtTdLibObjectType::TEXT_ENTITY_TYPE_BOT_COMMAND, parent }
{ }

QtTdLibTextEntityTypeUrl::QtTdLibTextEntityTypeUrl (QObject * parent)
    : QtTdLibTextEntityType { QtTdLibObjectType::TEXT_ENTITY_TYPE_URL, parent }
{ }

QtTdLibTextEntityTypeEmailAddress::QtTdLibTextEntityTypeEmailAddress (QObject * parent)
    : QtTdLibTextEntityType { QtTdLibObjectType::TEXT_ENTITY_TYPE_EMAIL_ADDRESS, parent }
{ }

QtTdLibTextEntityTypeBold::QtTdLibTextEntityTypeBold (QObject * parent)
    : QtTdLibTextEntityType { QtTdLibObjectType::TEXT_ENTITY_TYPE_BOLD, parent }
{ }

QtTdLibTextEntityTypeItalic::QtTdLibTextEntityTypeItalic (QObject * parent)
    : QtTdLibTextEntityType { QtTdLibObjectType::TEXT_ENTITY_TYPE_ITALIC, parent }
{ }

QtTdLibTextEntityTypeCode::QtTdLibTextEntityTypeCode (QObject * parent)
    : QtTdLibTextEntityType { QtTdLibObjectType::TEXT_ENTITY_TYPE_CODE, parent }
{ }

QtTdLibTextEntityTypePre::QtTdLibTextEntityTypePre (QObject * parent)
    : QtTdLibTextEntityType { QtTdLibObjectType::TEXT_ENTITY_TYPE_PRE, parent }
{ }

QtTdLibTextEntityTypePreCode::QtTdLibTextEntityTypePreCode (QObject * parent)
    : QtTdLibTextEntityType { QtTdLibObjectType::TEXT_ENTITY_TYPE_PRE_CODE, parent }
{ }

void QtTdLibTextEntityTypePreCode::updateFromJson (const QJsonObject & json) {
    set_language_withJSON (json ["language"]);
}

QtTdLibTextEntityTypeTextUrl::QtTdLibTextEntityTypeTextUrl (QObject * parent)
    : QtTdLibTextEntityType { QtTdLibObjectType::TEXT_ENTITY_TYPE_TEXT_URL, parent }
{ }

void QtTdLibTextEntityTypeTextUrl::updateFromJson (const QJsonObject & json) {
    set_url_withJSON (json ["url"]);
}

QtTdLibTextEntityTypeMentionName::QtTdLibTextEntityTypeMentionName (QObject * parent)
    : QtTdLibTextEntityType { QtTdLibObjectType::TEXT_ENTITY_TYPE_MENTION_NAME, parent }
{ }

void QtTdLibTextEntityTypeMentionName::updateFromJson (const QJsonObject & json) {
    set_userId_withJSON (json ["user_id"]);
}
