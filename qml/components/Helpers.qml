pragma Singleton
import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import Qt.labs.folderlistmodel 2.1;
import QtDocGallery 5.0;
import QtFeedback 5.0;
import Nemo.Thumbnailer 1.0;
import Nemo.Notifications 1.0;
import Nemo.Configuration 1.0;
import harbour.Telegrame 1.0;

QtObject {

    property int currentMsgType : TD_ObjectType.MESSAGE_TEXT;

    property bool showInputPanel : false;

    readonly property color panelColor : Qt.rgba (1.0 - Theme.primaryColor.r, 1.0 - Theme.primaryColor.g, 1.0 - Theme.primaryColor.b, 0.85);

    property alias groupImagesInAlbums            : configGroupImagesInAlbum.value;
    property alias groupVideosInAlbums            : configGroupVideosInAlbum.value;
    property alias sendTextMsgOnEnterKey          : configSendTextMsgOnEnterKey.value;
    property alias includeMutedChatsInUnreadCount : configIncludeMutedChatsInUnreadCount.value;
    property alias keepKeyboardOpenAfterMsgSend   : configKeepKeyboardOpenAfterMsgSend.value;
    property alias limitFilePickerToHome          : configLimitFilePickerToHome.value;
    property alias avatarShape                    : configAvatarShape.value;
    property alias lastUsedStickersetName         : configLastUsedStickersetName.value;
    property alias hideChatHeader                 : configHideChatHeader.value;
    property alias showBubblesAroundMessages      : configShowBubblesAroundMessages.value;

    property list<ConfigurationValue> _configurationItems_ : [
        ConfigurationValue {
            id: configLastUsedStickersetName;
            key: "/apps/telegrame/last_used_stickerset_name";
            defaultValue: "TelegramGreatMinds";
        },
        ConfigurationValue {
            id: configGroupImagesInAlbum;
            key: "/apps/telegrame/group_images_in_album";
            defaultValue: true;
        },
        ConfigurationValue {
            id: configGroupVideosInAlbum;
            key: "/apps/telegrame/group_videos_in_album";
            defaultValue: true;
        },
        ConfigurationValue {
            id: configSendTextMsgOnEnterKey;
            key: "/apps/telegrame/send_text_msg_on_enter_key";
            defaultValue: false;
        },
        ConfigurationValue {
            id: configIncludeMutedChatsInUnreadCount;
            key: "/apps/telegrame/include_muted_chats_in_unread_count";
            defaultValue: false;
        },
        ConfigurationValue {
            id: configKeepKeyboardOpenAfterMsgSend;
            key: "/apps/telegrame/keep_kdb_open_after_msg_send";
            defaultValue: true;
        },
        ConfigurationValue {
            id: configLimitFilePickerToHome;
            key: "/apps/telegrame/limit_file_picker_to_home";
            defaultValue: true;
        },
        ConfigurationValue {
            id: configAvatarShape;
            key: "/apps/telegrame/avatar_shape";
            defaultValue: "square";
        },
        ConfigurationValue {
            id: configHideChatHeader;
            key: "/apps/telegrame/hide_chat_header";
            defaultValue: false;
        },
        ConfigurationValue {
            id: configShowBubblesAroundMessages;
            key: "/apps/telegrame/show_bubbles_around_messages";
            defaultValue: true;
        }
    ]

    function clamp (val, min, max) {
        return (val > max ? max : (val < min ? min : val));
    }
}
