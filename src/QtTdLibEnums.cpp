
#include "QtTdLibEnums.h"

#include <QHash>

QtTdLibObjectType::Type QtTdLibEnums::objectTypeEnumFromString (const QString & str) {
    static const QHash<QString, QtTdLibObjectType::Type> ret {
        { "animation", QtTdLibObjectType::ANIMATION },
        { "audio", QtTdLibObjectType::AUDIO },
        { "authenticationCodeTypeSms", QtTdLibObjectType::AUTHENTICATION_CODE_TYPE_SMS },
        { "authenticationCodeTypeTelegramMessage", QtTdLibObjectType::AUTHENTICATION_CODE_TYPE_TELEGRAM_MESSAGE },
        { "authenticationCodeTypeCall", QtTdLibObjectType::AUTHENTICATION_CODE_TYPE_CALL },
        { "authenticationCodeTypeFlashCall", QtTdLibObjectType::AUTHENTICATION_CODE_TYPE_FLASH_CALL },
        { "authorizationStateClosed", QtTdLibObjectType::AUTHORIZATION_STATE_CLOSED },
        { "authorizationStateClosing", QtTdLibObjectType::AUTHORIZATION_STATE_CLOSING },
        { "authorizationStateLoggingOut", QtTdLibObjectType::AUTHORIZATION_STATE_LOGGING_OUT },
        { "authorizationStateReady", QtTdLibObjectType::AUTHORIZATION_STATE_READY },
        { "authorizationStateWaitCode", QtTdLibObjectType::AUTHORIZATION_STATE_WAIT_CODE },
        { "authorizationStateWaitEncryptionKey", QtTdLibObjectType::AUTHORIZATION_STATE_WAIT_ENCRYPTION_KEY },
        { "authorizationStateWaitPhoneNumber", QtTdLibObjectType::AUTHORIZATION_STATE_WAIT_PHONE_NUMBER },
        { "authorizationStateWaitTdlibParameters", QtTdLibObjectType::AUTHORIZATION_STATE_WAIT_TDLIB_PARAMETERS },
        { "connectionStateConnecting", QtTdLibObjectType::CONNECTION_STATE_CONNECTING },
        { "connectionStateConnectingToProxy", QtTdLibObjectType::CONNECTION_STATE_CONNECTING_TO_PROXY },
        { "connectionStateReady", QtTdLibObjectType::CONNECTION_STATE_READY },
        { "connectionStateUpdating", QtTdLibObjectType::CONNECTION_STATE_UPDATING },
        { "connectionStateWaitingForNetwork", QtTdLibObjectType::CONNECTION_STATE_WAITING_FOR_NETWORK },
        { "chat", QtTdLibObjectType::CHAT },
        { "chatPhoto", QtTdLibObjectType::CHAT_PHOTO },
        { "chatTypePrivate", QtTdLibObjectType::CHAT_TYPE_PRIVATE },
        { "chatTypeBasicGroup", QtTdLibObjectType::CHAT_TYPE_BASIC_GROUP },
        { "chatTypeSupergroup", QtTdLibObjectType::CHAT_TYPE_SUPERGROUP },
        { "chatTypeSecret", QtTdLibObjectType::CHAT_TYPE_SECRET },
        { "document", QtTdLibObjectType::DOCUMENT },
        { "file", QtTdLibObjectType::FILE },
        { "formattedText", QtTdLibObjectType::FORMATTED_TEXT },
        { "linkStateIsContact", QtTdLibObjectType::LINK_STATE_IS_CONTACT },
        { "linkStateKnowsPhoneNumber", QtTdLibObjectType::LINK_STATE_KNOWS_PHONE_NUMBER },
        { "linkStateNone", QtTdLibObjectType::LINK_STATE_NONE },
        { "localFile", QtTdLibObjectType::LOCAL_FILE },
        { "message", QtTdLibObjectType::MESSAGE },
        { "messages", QtTdLibObjectType::MESSAGES },
        { "messageAnimation", QtTdLibObjectType::MESSAGE_ANIMATION },
        { "messageAudio", QtTdLibObjectType::MESSAGE_AUDIO },
        { "messageDocument", QtTdLibObjectType::MESSAGE_DOCUMENT },
        { "messageText", QtTdLibObjectType::MESSAGE_TEXT },
        { "messagePhoto", QtTdLibObjectType::MESSAGE_PHOTO },
        { "messageSticker", QtTdLibObjectType::MESSAGE_STICKER },
        { "messageVideo", QtTdLibObjectType::MESSAGE_VIDEO },
        { "messageVideoNote", QtTdLibObjectType::MESSAGE_VIDEO_NOTE },
        { "messageVoiceNote", QtTdLibObjectType::MESSAGE_VOICE_NOTE },
        { "photo", QtTdLibObjectType::PHOTO },
        { "photoSize", QtTdLibObjectType::PHOTO_SIZE },
        { "profilePhoto", QtTdLibObjectType::PROFILE_PHOTO },
        { "remoteFile", QtTdLibObjectType::REMOTE_FILE },
        { "sticker", QtTdLibObjectType::STICKER },
        { "stickerSetInfo", QtTdLibObjectType::STICKER_SET_INFO },
        { "textEntity", QtTdLibObjectType::TEXT_ENTITY },
        { "textEntityTypeMention", QtTdLibObjectType::TEXT_ENTITY_TYPE_MENTION },
        { "textEntityTypeHashtag", QtTdLibObjectType::TEXT_ENTITY_TYPE_HASHTAG },
        { "textEntityTypeBotCommand", QtTdLibObjectType::TEXT_ENTITY_TYPE_BOT_COMMAND },
        { "textEntityTypeUrl", QtTdLibObjectType::TEXT_ENTITY_TYPE_URL },
        { "textEntityTypeEmailAddress", QtTdLibObjectType::TEXT_ENTITY_TYPE_EMAIL_ADDRESS },
        { "textEntityTypeBold", QtTdLibObjectType::TEXT_ENTITY_TYPE_BOLD },
        { "textEntityTypeItalic", QtTdLibObjectType::TEXT_ENTITY_TYPE_ITALIC },
        { "textEntityTypeCode", QtTdLibObjectType::TEXT_ENTITY_TYPE_CODE },
        { "textEntityTypePre", QtTdLibObjectType::TEXT_ENTITY_TYPE_PRE },
        { "textEntityTypePreCode", QtTdLibObjectType::TEXT_ENTITY_TYPE_PRE_CODE },
        { "textEntityTypeTextUrl", QtTdLibObjectType::TEXT_ENTITY_TYPE_TEXT_URL },
        { "textEntityTypeMentionName", QtTdLibObjectType::TEXT_ENTITY_TYPE_MENTION_NAME },
        { "user", QtTdLibObjectType::USER },
        { "userStatusEmpty", QtTdLibObjectType::USER_STATUS_EMPTY },
        { "userStatusLastMonth", QtTdLibObjectType::USER_STATUS_LAST_MONTH },
        { "userStatusLastWeek", QtTdLibObjectType::USER_STATUS_LAST_WEEK },
        { "userStatusOffline", QtTdLibObjectType::USER_STATUS_OFFLINE },
        { "userStatusOnline", QtTdLibObjectType::USER_STATUS_ONLINE },
        { "userStatusRecently", QtTdLibObjectType::USER_STATUS_RECENTLY },
        { "userTypeBot", QtTdLibObjectType::USER_TYPE_BOT },
        { "userTypeDeleted", QtTdLibObjectType::USER_TYPE_DELETED },
        { "userTypeRegular", QtTdLibObjectType::USER_TYPE_REGULAR },
        { "updateAuthorizationState", QtTdLibObjectType::UPDATE_AUTHORIZATION_STATE },
        { "updateConnectionState", QtTdLibObjectType::UPDATE_CONNECTION_STATE },
        { "updateUser", QtTdLibObjectType::UPDATE_USER },
        { "updateUserStatus", QtTdLibObjectType::UPDATE_USER_STATUS },
        { "updateNewChat", QtTdLibObjectType::UPDATE_NEW_CHAT },
        { "updateNewMessage", QtTdLibObjectType::UPDATE_NEW_MESSAGE },
        { "updateChatReadOutbox", QtTdLibObjectType::UPDATE_CHAT_READ_OUTBOX },
        { "updateChatReadInbox", QtTdLibObjectType::UPDATE_CHAT_READ_INBOX },
        { "updateChatLastMessage", QtTdLibObjectType::UPDATE_CHAT_LAST_MESSAGE },
        { "updateFile", QtTdLibObjectType::UPDATE_FILE },
        { "webPage", QtTdLibObjectType::WEB_PAGE },
        { "video", QtTdLibObjectType::VIDEO },
        { "videoNote", QtTdLibObjectType::VIDEO_NOTE },
        { "voiceNote", QtTdLibObjectType::VOICE_NOTE },
    };
    return ret.value (str, QtTdLibObjectType::INVALID);
}

QtTdLibObjectType::Type QtTdLibEnums::objectTypeEnumFromJson (const QJsonObject & json) {
    return objectTypeEnumFromString (json ["@type"].toString ());
}