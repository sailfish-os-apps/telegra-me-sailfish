#ifndef QtTdLibEnums_H
#define QtTdLibEnums_H

#include "QmlEnumHelpers.h"

#include <QJsonObject>

QML_ENUM_CLASS (QtTdLibObjectType,
                INVALID = -1,
                ANIMATION,
                ANIMATIONS,
                AUDIO,
                AUTHENTICATION_CODE_INFO,
                AUTHENTICATION_CODE_TYPE_CALL,
                AUTHENTICATION_CODE_TYPE_FLASH_CALL,
                AUTHENTICATION_CODE_TYPE_SMS,
                AUTHENTICATION_CODE_TYPE_TELEGRAM_MESSAGE,
                AUTHORIZATION_STATE_CLOSED,
                AUTHORIZATION_STATE_CLOSING,
                AUTHORIZATION_STATE_LOGGING_OUT,
                AUTHORIZATION_STATE_READY,
                AUTHORIZATION_STATE_WAIT_CODE,
                AUTHORIZATION_STATE_WAIT_ENCRYPTION_KEY,
                AUTHORIZATION_STATE_WAIT_PASSWORD,
                AUTHORIZATION_STATE_WAIT_PHONE_NUMBER,
                AUTHORIZATION_STATE_WAIT_TDLIB_PARAMETERS,
                BASIC_GROUP,
                CALL_DISCARD_REASON_DECLINED,
                CALL_DISCARD_REASON_DISCONNECTED,
                CALL_DISCARD_REASON_EMPTY,
                CALL_DISCARD_REASON_HUNG_UP,
                CALL_DISCARD_REASON_MISSED,
                CHAT,
                CHAT_ACTION_CANCEL,
                CHAT_ACTION_CHOOSING_CONTACT,
                CHAT_ACTION_CHOOSING_LOCATION,
                CHAT_ACTION_RECORDING_VIDEO,
                CHAT_ACTION_RECORDING_VIDEO_NOTE,
                CHAT_ACTION_RECORDING_VOICE_NOTE,
                CHAT_ACTION_START_PLAYING_GAME,
                CHAT_ACTION_TYPING,
                CHAT_ACTION_UPLOADING_DOCUMENT,
                CHAT_ACTION_UPLOADING_PHOTO,
                CHAT_ACTION_UPLOADING_VIDEO,
                CHAT_ACTION_UPLOADING_VIDEO_NOTE,
                CHAT_ACTION_UPLOADING_VOICE_NOTE,
                CHAT_NOTIFICATION_SETTINGS,
                CHAT_PHOTO,
                CHAT_MEMBER,
                CHAT_MEMBERS,
                CHAT_MEMBER_STATUS_ADMINISTRATOR,
                CHAT_MEMBER_STATUS_BANNED,
                CHAT_MEMBER_STATUS_CREATOR,
                CHAT_MEMBER_STATUS_LEFT,
                CHAT_MEMBER_STATUS_MEMBER,
                CHAT_MEMBER_STATUS_RESTRICTED,
                CHAT_TYPE_BASIC_GROUP,
                CHAT_TYPE_PRIVATE,
                CHAT_TYPE_SECRET,
                CHAT_TYPE_SUPERGROUP,
                CONNECTION_STATE_CONNECTING,
                CONNECTION_STATE_CONNECTING_TO_PROXY,
                CONNECTION_STATE_READY,
                CONNECTION_STATE_UPDATING,
                CONNECTION_STATE_WAITING_FOR_NETWORK,
                DOCUMENT,
                FILE,
                FORMATTED_TEXT,
                LINK_STATE_IS_CONTACT,
                LINK_STATE_KNOWS_PHONE_NUMBER,
                LINK_STATE_NONE,
                LOCAL_FILE,
                MESSAGE,
                MESSAGE_ANIMATION,
                MESSAGE_AUDIO,
                MESSAGE_BASIC_GROUP_CHAT_CREATE,
                MESSAGE_CALL,
                MESSAGE_CHAT_ADD_MEMBERS,
                MESSAGE_CHAT_CHANGE_PHOTO,
                MESSAGE_CHAT_CHANGE_TITLE,
                MESSAGE_CHAT_DELETE_MEMBER,
                MESSAGE_CHAT_DELETE_PHOTO,
                MESSAGE_CHAT_JOIN_BY_LINK,
                MESSAGE_CHAT_UPGRADE_FROM,
                MESSAGE_CHAT_UPGRADE_TO,
                MESSAGE_CONTACT_REGISTERED,
                MESSAGE_PIN_MESSAGE,
                MESSAGE_DOCUMENT,
                MESSAGE_PHOTO,
                MESSAGE_STICKER,
                MESSAGE_SUPERGROUP_CHAT_CREATE,
                MESSAGE_TEXT,
                MESSAGE_VIDEO,
                MESSAGE_VIDEO_NOTE,
                MESSAGE_VOICE_NOTE,
                MESSAGES,
                PHOTO,
                PHOTO_SIZE,
                PROFILE_PHOTO,
                REMOTE_FILE,
                STICKER,
                STICKER_SET,
                STICKER_SET_INFO,
                STICKER_SETS,
                SUPERGROUP,
                TEXT_ENTITY,
                TEXT_ENTITY_TYPE_BOLD,
                TEXT_ENTITY_TYPE_BOT_COMMAND,
                TEXT_ENTITY_TYPE_CODE,
                TEXT_ENTITY_TYPE_EMAIL_ADDRESS,
                TEXT_ENTITY_TYPE_HASHTAG,
                TEXT_ENTITY_TYPE_ITALIC,
                TEXT_ENTITY_TYPE_MENTION,
                TEXT_ENTITY_TYPE_MENTION_NAME,
                TEXT_ENTITY_TYPE_PRE,
                TEXT_ENTITY_TYPE_PRE_CODE,
                TEXT_ENTITY_TYPE_TEXT_URL,
                TEXT_ENTITY_TYPE_URL,
                UPDATE_AUTHORIZATION_STATE,
                UPDATE_BASIC_GROUP,
                UPDATE_BASIC_GROUP_FULL_INFO,
                UPDATE_CHAT_DRAFT_MESSAGE,
                UPDATE_CHAT_IS_PINNED,
                UPDATE_CHAT_LAST_MESSAGE,
                UPDATE_CHAT_NOTIFICATION_SETTINGS,
                UPDATE_CHAT_ORDER,
                UPDATE_CHAT_PHOTO,
                UPDATE_CHAT_READ_INBOX,
                UPDATE_CHAT_READ_OUTBOX,
                UPDATE_CHAT_TITLE,
                UPDATE_CHAT_UNREAD_MENTION_COUNT,
                UPDATE_CHAT_PINNED_MESSAGE,
                UPDATE_MESSAGE_MENTION_READ,
                UPDATE_CONNECTION_STATE,
                UPDATE_DELETE_MESSAGES,
                UPDATE_FILE,
                UPDATE_INSTALLED_STICKER_SETS,
                UPDATE_MESSAGE_CONTENT,
                UPDATE_MESSAGE_EDITED,
                UPDATE_MESSAGE_SEND_SUCCEEDED,
                UPDATE_NEW_CHAT,
                UPDATE_NEW_MESSAGE,
                UPDATE_NOTIFICATION_SETTINGS,
                UPDATE_SUPERGROUP,
                UPDATE_SUPERGROUP_FULL_INFO,
                UPDATE_UNREAD_MESSAGE_COUNT,
                UPDATE_USER,
                UPDATE_USER_CHAT_ACTION,
                UPDATE_USER_STATUS,
                USER,
                USERS,
                USER_STATUS_EMPTY,
                USER_STATUS_LAST_MONTH,
                USER_STATUS_LAST_WEEK,
                USER_STATUS_OFFLINE,
                USER_STATUS_ONLINE,
                USER_STATUS_RECENTLY,
                USER_TYPE_BOT,
                USER_TYPE_DELETED,
                USER_TYPE_REGULAR,
                USER_TYPE_UNKNOWN,
                VIDEO,
                VIDEO_NOTE,
                VOICE_NOTE,
                WEB_PAGE,
                )

class QtTdLibEnums {
    Q_GADGET

public:
    static QtTdLibObjectType::Type objectTypeEnumFromString (const QString     & str);
    static QtTdLibObjectType::Type objectTypeEnumFromJson   (const QJsonObject & json);
};

#endif // QtTdLibEnums_H
