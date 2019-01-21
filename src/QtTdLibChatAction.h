#ifndef QTTDLIBCHATACTION_H
#define QTTDLIBCHATACTION_H

#include "QtTdLibCommon.h"

class QtTdLibChatAction : public QtTdLibAbstractObject {
    Q_OBJECT
    /// custom
    Q_TDLIB_PROPERTY_ID32 (userId)

public:
    explicit QtTdLibChatAction (const QtTdLibObjectType::Type typeOf = QtTdLibObjectType::INVALID, QObject * parent = Q_NULLPTR);

    static QtTdLibChatAction * createAbstract (const QJsonObject & json, QObject * parent = Q_NULLPTR);
};

class QtTdLibChatActionCancel : public QtTdLibChatAction, public FactoryNoId<QtTdLibChatActionCancel> {
    Q_OBJECT

public:
    explicit QtTdLibChatActionCancel (QObject * parent = Q_NULLPTR);
};

class QtTdLibChatActionChoosingContact : public QtTdLibChatAction, public FactoryNoId<QtTdLibChatActionChoosingContact> {
    Q_OBJECT

public:
    explicit QtTdLibChatActionChoosingContact (QObject * parent = Q_NULLPTR);
};

class QtTdLibChatActionChoosingLocation : public QtTdLibChatAction, public FactoryNoId<QtTdLibChatActionChoosingLocation> {
    Q_OBJECT

public:
    explicit QtTdLibChatActionChoosingLocation (QObject * parent = Q_NULLPTR);
};

class QtTdLibChatActionRecordingVideo : public QtTdLibChatAction, public FactoryNoId<QtTdLibChatActionRecordingVideo> {
    Q_OBJECT

public:
    explicit QtTdLibChatActionRecordingVideo (QObject * parent = Q_NULLPTR);
};

class QtTdLibChatActionRecordingVideoNote : public QtTdLibChatAction, public FactoryNoId<QtTdLibChatActionRecordingVideoNote> {
    Q_OBJECT

public:
    explicit QtTdLibChatActionRecordingVideoNote (QObject * parent = Q_NULLPTR);
};

class QtTdLibChatActionRecordingVoiceNote : public QtTdLibChatAction, public FactoryNoId<QtTdLibChatActionRecordingVoiceNote> {
    Q_OBJECT

public:
    explicit QtTdLibChatActionRecordingVoiceNote (QObject * parent = Q_NULLPTR);
};

class QtTdLibChatActionStartPlayingGame : public QtTdLibChatAction, public FactoryNoId<QtTdLibChatActionStartPlayingGame> {
    Q_OBJECT

public:
    explicit QtTdLibChatActionStartPlayingGame (QObject * parent = Q_NULLPTR);
};

class QtTdLibChatActionTyping : public QtTdLibChatAction, public FactoryNoId<QtTdLibChatActionTyping> {
    Q_OBJECT

public:
    explicit QtTdLibChatActionTyping (QObject * parent = Q_NULLPTR);
};

class QtTdLibChatActionUploadingDocument : public QtTdLibChatAction, public FactoryNoId<QtTdLibChatActionUploadingDocument> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_INT32 (progress)

public:
    explicit QtTdLibChatActionUploadingDocument (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibChatActionUploadingPhoto : public QtTdLibChatAction, public FactoryNoId<QtTdLibChatActionUploadingPhoto> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_INT32 (progress)

public:
    explicit QtTdLibChatActionUploadingPhoto (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibChatActionUploadingVideo : public QtTdLibChatAction, public FactoryNoId<QtTdLibChatActionUploadingVideo> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_INT32 (progress)

public:
    explicit QtTdLibChatActionUploadingVideo (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibChatActionUploadingVideoNote : public QtTdLibChatAction, public FactoryNoId<QtTdLibChatActionUploadingVideoNote> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_INT32 (progress)

public:
    explicit QtTdLibChatActionUploadingVideoNote (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibChatActionUploadingVoiceNote : public QtTdLibChatAction, public FactoryNoId<QtTdLibChatActionUploadingVoiceNote> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_INT32 (progress)

public:
    explicit QtTdLibChatActionUploadingVoiceNote (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

#endif // QTTDLIBCHATACTION_H
