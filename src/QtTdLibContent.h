#ifndef QTTDCONTENT_H
#define QTTDCONTENT_H

#include "QtTdLibCommon.h"
#include "QtTdLibFile.h"

class QtTdLibTextEntityType : public QtTdLibAbstractObject {
    Q_OBJECT

public:
    explicit QtTdLibTextEntityType (const QtTdLibObjectType::Type typeOf = QtTdLibObjectType::INVALID, QObject * parent = Q_NULLPTR);

    static QtTdLibTextEntityType * createAbstract (const QJsonObject & json, QObject * parent = Q_NULLPTR);
};

class QtTdLibTextEntityTypeMention : public QtTdLibTextEntityType, public FactoryNoId<QtTdLibTextEntityTypeMention> {
    Q_OBJECT

public:
    explicit QtTdLibTextEntityTypeMention (QObject * parent = Q_NULLPTR);
};

class QtTdLibTextEntityTypeHashtag : public QtTdLibTextEntityType, public FactoryNoId<QtTdLibTextEntityTypeHashtag> {
    Q_OBJECT

public:
    explicit QtTdLibTextEntityTypeHashtag (QObject * parent = Q_NULLPTR);
};

class QtTdLibTextEntityTypeBotCommand : public QtTdLibTextEntityType, public FactoryNoId<QtTdLibTextEntityTypeBotCommand> {
    Q_OBJECT

public:
    explicit QtTdLibTextEntityTypeBotCommand (QObject * parent = Q_NULLPTR);
};

class QtTdLibTextEntityTypeUrl : public QtTdLibTextEntityType, public FactoryNoId<QtTdLibTextEntityTypeUrl> {
    Q_OBJECT

public:
    explicit QtTdLibTextEntityTypeUrl (QObject * parent = Q_NULLPTR);
};

class QtTdLibTextEntityTypeEmailAddress : public QtTdLibTextEntityType, public FactoryNoId<QtTdLibTextEntityTypeEmailAddress> {
    Q_OBJECT

public:
    explicit QtTdLibTextEntityTypeEmailAddress (QObject * parent = Q_NULLPTR);
};

class QtTdLibTextEntityTypeBold : public QtTdLibTextEntityType, public FactoryNoId<QtTdLibTextEntityTypeBold> {
    Q_OBJECT

public:
    explicit QtTdLibTextEntityTypeBold (QObject * parent = Q_NULLPTR);
};

class QtTdLibTextEntityTypeItalic : public QtTdLibTextEntityType, public FactoryNoId<QtTdLibTextEntityTypeItalic> {
    Q_OBJECT

public:
    explicit QtTdLibTextEntityTypeItalic (QObject * parent = Q_NULLPTR);
};

class QtTdLibTextEntityTypeCode : public QtTdLibTextEntityType, public FactoryNoId<QtTdLibTextEntityTypeCode> {
    Q_OBJECT

public:
    explicit QtTdLibTextEntityTypeCode (QObject * parent = Q_NULLPTR);
};

class QtTdLibTextEntityTypePre : public QtTdLibTextEntityType, public FactoryNoId<QtTdLibTextEntityTypePre> {
    Q_OBJECT

public:
    explicit QtTdLibTextEntityTypePre (QObject * parent = Q_NULLPTR);
};

class QtTdLibTextEntityTypePreCode : public QtTdLibTextEntityType, public FactoryNoId<QtTdLibTextEntityTypePreCode> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_STRING (language)

public:
    explicit QtTdLibTextEntityTypePreCode (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibTextEntityTypeTextUrl : public QtTdLibTextEntityType, public FactoryNoId<QtTdLibTextEntityTypeTextUrl> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_STRING (url)

public:
    explicit QtTdLibTextEntityTypeTextUrl (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibTextEntityTypeMentionName : public QtTdLibTextEntityType, public FactoryNoId<QtTdLibTextEntityTypeMentionName> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_ID32 (userId)

public:
    explicit QtTdLibTextEntityTypeMentionName (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibTextEntity : public QtTdLibAbstractObject, public FactoryNoId<QtTdLibTextEntity> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_INT32     (offset)
    Q_TDLIB_PROPERTY_INT32     (length)
    Q_TDLIB_PROPERTY_SUBOBJECT (type, QtTdLibTextEntityType)

public:
    explicit QtTdLibTextEntity (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibFormattedText : public QtTdLibAbstractObject, public FactoryNoId<QtTdLibFormattedText> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_STRING (text)
    QML_OBJMODEL_PROPERTY   (entities, QtTdLibTextEntity)

public:
    explicit QtTdLibFormattedText (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibPhotoSize : public QtTdLibAbstractObject, public FactoryNoId<QtTdLibPhotoSize> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_STRING    (type)
    Q_TDLIB_PROPERTY_INT32     (width)
    Q_TDLIB_PROPERTY_INT32     (height)
    Q_TDLIB_PROPERTY_SUBOBJECT (photo, QtTdLibFile)

public:
    explicit QtTdLibPhotoSize (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibPhoto : public QtTdLibAbstractInt64IdObject, public FactoryInt64Id<QtTdLibPhoto> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_BOOL (hasStickers)
    QML_OBJMODEL_PROPERTY (sizes,  QtTdLibPhotoSize)

public:
    explicit QtTdLibPhoto (const qint64 id = 0, QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibDocument : public QtTdLibAbstractObject, public FactoryNoId<QtTdLibDocument> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_STRING    (fileName)
    Q_TDLIB_PROPERTY_STRING    (mimeType)
    Q_TDLIB_PROPERTY_SUBOBJECT (document,       QtTdLibFile)
    Q_TDLIB_PROPERTY_SUBOBJECT (thumbnail, QtTdLibPhotoSize)

public:
    explicit QtTdLibDocument (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibSticker : public QtTdLibAbstractObject, public FactoryNoId<QtTdLibSticker> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_ID64      (setId)
    Q_TDLIB_PROPERTY_INT32     (width)
    Q_TDLIB_PROPERTY_INT32     (height)
    Q_TDLIB_PROPERTY_STRING    (emoji)
    Q_TDLIB_PROPERTY_BOOL      (isMask)
    //mask_position:maskPosition
    Q_TDLIB_PROPERTY_SUBOBJECT (thumbnail, QtTdLibPhotoSize)
    Q_TDLIB_PROPERTY_SUBOBJECT (sticker,        QtTdLibFile)

public:
    explicit QtTdLibSticker (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibStickerSetInfo : public QtTdLibAbstractInt64IdObject, public FactoryInt64Id<QtTdLibStickerSetInfo> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_STRING (title)
    Q_TDLIB_PROPERTY_STRING (name)
    Q_TDLIB_PROPERTY_BOOL   (isInstalled)
    Q_TDLIB_PROPERTY_BOOL   (isArchived)
    Q_TDLIB_PROPERTY_BOOL   (isOfficial)
    Q_TDLIB_PROPERTY_BOOL   (isMasks)
    Q_TDLIB_PROPERTY_BOOL   (isViewed)
    Q_TDLIB_PROPERTY_INT32  (size)
    QML_OBJMODEL_PROPERTY   (covers,   QtTdLibSticker)
    QML_OBJMODEL_PROPERTY   (stickers, QtTdLibSticker)

public:
    explicit QtTdLibStickerSetInfo (const qint64 id = 0, QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibAnimation : public QtTdLibAbstractObject, public FactoryNoId<QtTdLibAnimation> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_INT32     (duration)
    Q_TDLIB_PROPERTY_INT32     (width)
    Q_TDLIB_PROPERTY_INT32     (height)
    Q_TDLIB_PROPERTY_STRING    (fileName)
    Q_TDLIB_PROPERTY_STRING    (mimeType)
    Q_TDLIB_PROPERTY_SUBOBJECT (thumbnail, QtTdLibPhotoSize)
    Q_TDLIB_PROPERTY_SUBOBJECT (animation,      QtTdLibFile)

public:
    explicit QtTdLibAnimation (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibVoiceNote : public QtTdLibAbstractObject, public FactoryNoId<QtTdLibVoiceNote> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_INT32     (duration)
    Q_TDLIB_PROPERTY_STRING    (mimeType)
    Q_TDLIB_PROPERTY_STRING    (waveform)
    Q_TDLIB_PROPERTY_SUBOBJECT (voice, QtTdLibFile)

public:
    explicit QtTdLibVoiceNote (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};


class QtTdLibVideoNote : public QtTdLibAbstractObject, public FactoryNoId<QtTdLibVideoNote> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_INT32     (duration)
    Q_TDLIB_PROPERTY_INT32     (length)
    Q_TDLIB_PROPERTY_SUBOBJECT (thumbnail, QtTdLibPhotoSize)
    Q_TDLIB_PROPERTY_SUBOBJECT (video,          QtTdLibFile)

public:
    explicit QtTdLibVideoNote (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibVideo : public QtTdLibAbstractObject, public FactoryNoId<QtTdLibVideo> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_INT32     (duration)
    Q_TDLIB_PROPERTY_INT32     (width)
    Q_TDLIB_PROPERTY_INT32     (height)
    Q_TDLIB_PROPERTY_STRING    (fileName)
    Q_TDLIB_PROPERTY_STRING    (mimeType)
    Q_TDLIB_PROPERTY_BOOL      (hasStickers)
    Q_TDLIB_PROPERTY_SUBOBJECT (thumbnail, QtTdLibPhotoSize)
    Q_TDLIB_PROPERTY_SUBOBJECT (video,          QtTdLibFile)

public:
    explicit QtTdLibVideo (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibAudio : public QtTdLibAbstractObject, public FactoryNoId<QtTdLibAudio> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_INT32     (duration)
    Q_TDLIB_PROPERTY_STRING    (title)
    Q_TDLIB_PROPERTY_STRING    (fileName)
    Q_TDLIB_PROPERTY_STRING    (performer)
    Q_TDLIB_PROPERTY_STRING    (mimeType)
    Q_TDLIB_PROPERTY_SUBOBJECT (albumCoverThumbnail, QtTdLibPhotoSize)
    Q_TDLIB_PROPERTY_SUBOBJECT (audio,                    QtTdLibFile)

public:
    explicit QtTdLibAudio (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibWebPage : public QtTdLibAbstractObject, public FactoryNoId<QtTdLibWebPage> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_STRING    (url)
    Q_TDLIB_PROPERTY_STRING    (displayUrl)
    Q_TDLIB_PROPERTY_STRING    (type)
    Q_TDLIB_PROPERTY_STRING    (siteName)
    Q_TDLIB_PROPERTY_STRING    (title)
    Q_TDLIB_PROPERTY_STRING    (description)
    Q_TDLIB_PROPERTY_STRING    (author)
    Q_TDLIB_PROPERTY_STRING    (embedUrl)
    Q_TDLIB_PROPERTY_STRING    (embedType)
    Q_TDLIB_PROPERTY_INT32     (embedWidth)
    Q_TDLIB_PROPERTY_INT32     (embedHeight)
    Q_TDLIB_PROPERTY_INT32     (duration)
    Q_TDLIB_PROPERTY_BOOL      (hasInstantView)
    Q_TDLIB_PROPERTY_SUBOBJECT (photo,         QtTdLibPhoto)
    Q_TDLIB_PROPERTY_SUBOBJECT (document,   QtTdLibDocument)
    Q_TDLIB_PROPERTY_SUBOBJECT (sticker,     QtTdLibSticker)
    Q_TDLIB_PROPERTY_SUBOBJECT (animation, QtTdLibAnimation)
    Q_TDLIB_PROPERTY_SUBOBJECT (videoNote, QtTdLibVideoNote)
    Q_TDLIB_PROPERTY_SUBOBJECT (voiceNote, QtTdLibVoiceNote)
    Q_TDLIB_PROPERTY_SUBOBJECT (audio,         QtTdLibAudio)
    Q_TDLIB_PROPERTY_SUBOBJECT (video,         QtTdLibVideo)

public:
    explicit QtTdLibWebPage (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

#endif // QTTDCONTENT_H
