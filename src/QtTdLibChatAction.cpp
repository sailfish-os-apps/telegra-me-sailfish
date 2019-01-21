
#include "QtTdLibChatAction.h"

QtTdLibChatAction::QtTdLibChatAction (const QtTdLibObjectType::Type typeOf, QObject * parent)
    : QtTdLibAbstractObject { typeOf, parent }
{ }

QtTdLibChatAction * QtTdLibChatAction::createAbstract (const QJsonObject & json, QObject * parent) {
    switch (QtTdLibEnums::objectTypeEnumFromJson (json)) {
        case QtTdLibObjectType::CHAT_ACTION_CANCEL:               return QtTdLibChatActionCancel::create             (json, parent);
        case QtTdLibObjectType::CHAT_ACTION_CHOOSING_CONTACT:     return QtTdLibChatActionChoosingContact::create    (json, parent);
        case QtTdLibObjectType::CHAT_ACTION_CHOOSING_LOCATION:    return QtTdLibChatActionChoosingLocation::create   (json, parent);
        case QtTdLibObjectType::CHAT_ACTION_RECORDING_VIDEO:      return QtTdLibChatActionRecordingVideo::create     (json, parent);
        case QtTdLibObjectType::CHAT_ACTION_RECORDING_VIDEO_NOTE: return QtTdLibChatActionRecordingVideoNote::create (json, parent);
        case QtTdLibObjectType::CHAT_ACTION_RECORDING_VOICE_NOTE: return QtTdLibChatActionRecordingVoiceNote::create (json, parent);
        case QtTdLibObjectType::CHAT_ACTION_START_PLAYING_GAME:   return QtTdLibChatActionStartPlayingGame::create   (json, parent);
        case QtTdLibObjectType::CHAT_ACTION_TYPING:               return QtTdLibChatActionTyping::create             (json, parent);
        case QtTdLibObjectType::CHAT_ACTION_UPLOADING_DOCUMENT:   return QtTdLibChatActionUploadingDocument::create  (json, parent);
        case QtTdLibObjectType::CHAT_ACTION_UPLOADING_PHOTO:      return QtTdLibChatActionUploadingPhoto::create     (json, parent);
        case QtTdLibObjectType::CHAT_ACTION_UPLOADING_VIDEO:      return QtTdLibChatActionUploadingVideo::create     (json, parent);
        case QtTdLibObjectType::CHAT_ACTION_UPLOADING_VIDEO_NOTE: return QtTdLibChatActionUploadingVideoNote::create (json, parent);
        case QtTdLibObjectType::CHAT_ACTION_UPLOADING_VOICE_NOTE: return QtTdLibChatActionUploadingVoiceNote::create (json, parent);
        default: return Q_NULLPTR;
    }
}

QtTdLibChatActionCancel::QtTdLibChatActionCancel (QObject * parent)
    : QtTdLibChatAction { QtTdLibObjectType::CHAT_ACTION_CANCEL, parent }
{ }

QtTdLibChatActionChoosingContact::QtTdLibChatActionChoosingContact (QObject * parent)
    : QtTdLibChatAction { QtTdLibObjectType::CHAT_ACTION_CHOOSING_CONTACT, parent }
{ }

QtTdLibChatActionChoosingLocation::QtTdLibChatActionChoosingLocation (QObject * parent)
    : QtTdLibChatAction { QtTdLibObjectType::CHAT_ACTION_CHOOSING_LOCATION, parent }
{ }

QtTdLibChatActionRecordingVideo::QtTdLibChatActionRecordingVideo (QObject * parent)
    : QtTdLibChatAction { QtTdLibObjectType::CHAT_ACTION_RECORDING_VIDEO, parent }
{ }

QtTdLibChatActionRecordingVideoNote::QtTdLibChatActionRecordingVideoNote (QObject * parent)
    : QtTdLibChatAction { QtTdLibObjectType::CHAT_ACTION_RECORDING_VIDEO_NOTE, parent }
{ }

QtTdLibChatActionRecordingVoiceNote::QtTdLibChatActionRecordingVoiceNote (QObject * parent)
    : QtTdLibChatAction { QtTdLibObjectType::CHAT_ACTION_RECORDING_VOICE_NOTE, parent }
{ }

QtTdLibChatActionStartPlayingGame::QtTdLibChatActionStartPlayingGame (QObject * parent)
    : QtTdLibChatAction { QtTdLibObjectType::CHAT_ACTION_START_PLAYING_GAME, parent }
{ }

QtTdLibChatActionTyping::QtTdLibChatActionTyping (QObject * parent)
    : QtTdLibChatAction { QtTdLibObjectType::CHAT_ACTION_TYPING, parent }
{ }

QtTdLibChatActionUploadingDocument::QtTdLibChatActionUploadingDocument (QObject * parent)
    : QtTdLibChatAction { QtTdLibObjectType::CHAT_ACTION_UPLOADING_DOCUMENT, parent }
{ }

void QtTdLibChatActionUploadingDocument::updateFromJson (const QJsonObject & json) {
    set_progress_withJSON (json ["progress"]);
}

QtTdLibChatActionUploadingPhoto::QtTdLibChatActionUploadingPhoto (QObject * parent)
    : QtTdLibChatAction { QtTdLibObjectType::CHAT_ACTION_UPLOADING_PHOTO, parent }
{ }

void QtTdLibChatActionUploadingPhoto::updateFromJson (const QJsonObject & json) {
    set_progress_withJSON (json ["progress"]);
}

QtTdLibChatActionUploadingVideo::QtTdLibChatActionUploadingVideo (QObject * parent)
    : QtTdLibChatAction { QtTdLibObjectType::CHAT_ACTION_UPLOADING_VIDEO, parent }
{ }

void QtTdLibChatActionUploadingVideo::updateFromJson (const QJsonObject & json) {
    set_progress_withJSON (json ["progress"]);
}

QtTdLibChatActionUploadingVideoNote::QtTdLibChatActionUploadingVideoNote (QObject * parent)
    : QtTdLibChatAction { QtTdLibObjectType::CHAT_ACTION_UPLOADING_VIDEO_NOTE, parent }
{ }

void QtTdLibChatActionUploadingVideoNote::updateFromJson (const QJsonObject & json) {
    set_progress_withJSON (json ["progress"]);
}

QtTdLibChatActionUploadingVoiceNote::QtTdLibChatActionUploadingVoiceNote (QObject * parent)
    : QtTdLibChatAction { QtTdLibObjectType::CHAT_ACTION_UPLOADING_VOICE_NOTE, parent }
{ }

void QtTdLibChatActionUploadingVoiceNote::updateFromJson (const QJsonObject & json) {
    set_progress_withJSON (json ["progress"]);
}
