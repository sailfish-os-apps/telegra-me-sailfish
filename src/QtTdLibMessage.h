#ifndef QtTdLibMessage_H
#define QtTdLibMessage_H

#include "QtTdLibCommon.h"
#include "QtTdLibContent.h"
#include "QtTdLibFile.h"

class QtTdLibMessageContent : public QtTdLibAbstractObject {
    Q_OBJECT

public:
    explicit QtTdLibMessageContent (const QtTdLibObjectType::Type typeOf = QtTdLibObjectType::INVALID, QObject * parent = Q_NULLPTR);

    static QtTdLibMessageContent * createAbstract (const QJsonObject & json, QObject * parent = Q_NULLPTR);
};

class QtTdLibMessageText : public QtTdLibMessageContent, public FactoryNoId<QtTdLibMessageText> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_SUBOBJECT (text, QtTdLibFormattedText)
    Q_TDLIB_PROPERTY_SUBOBJECT (webPage,    QtTdLibWebPage)

public:
    explicit QtTdLibMessageText (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibMessagePhoto : public QtTdLibMessageContent, public FactoryNoId<QtTdLibMessagePhoto> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_SUBOBJECT (caption, QtTdLibFormattedText)
    Q_TDLIB_PROPERTY_SUBOBJECT (photo,   QtTdLibPhoto)

public:
    explicit QtTdLibMessagePhoto (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibMessageDocument : public QtTdLibMessageContent, public FactoryNoId<QtTdLibMessageDocument> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_SUBOBJECT (document,     QtTdLibDocument)
    Q_TDLIB_PROPERTY_SUBOBJECT (caption, QtTdLibFormattedText)

public:
    explicit QtTdLibMessageDocument (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibMessageSticker : public QtTdLibMessageContent, public FactoryNoId<QtTdLibMessageSticker> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_SUBOBJECT (sticker, QtTdLibSticker)

public:
    explicit QtTdLibMessageSticker (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibMessageAnimation : public QtTdLibMessageContent, public FactoryNoId<QtTdLibMessageAnimation> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_SUBOBJECT (animation,   QtTdLibAnimation)
    Q_TDLIB_PROPERTY_SUBOBJECT (caption, QtTdLibFormattedText)

public:
    explicit QtTdLibMessageAnimation (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibMessageVideoNote : public QtTdLibMessageContent, public FactoryNoId<QtTdLibMessageVideoNote> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_BOOL      (isViewed)
    Q_TDLIB_PROPERTY_SUBOBJECT (videoNote, QtTdLibVideoNote)

public:
    explicit QtTdLibMessageVideoNote (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibMessageVoiceNote : public QtTdLibMessageContent, public FactoryNoId<QtTdLibMessageVoiceNote> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_BOOL      (isListened)
    Q_TDLIB_PROPERTY_SUBOBJECT (voiceNote,   QtTdLibVoiceNote)
    Q_TDLIB_PROPERTY_SUBOBJECT (caption, QtTdLibFormattedText)

public:
    explicit QtTdLibMessageVoiceNote (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibMessageVideo : public QtTdLibMessageContent, public FactoryNoId<QtTdLibMessageVideo> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_SUBOBJECT (video,   QtTdLibVideo)
    Q_TDLIB_PROPERTY_SUBOBJECT (caption, QtTdLibFormattedText)

public:
    explicit QtTdLibMessageVideo (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibMessageAudio : public QtTdLibMessageContent, public FactoryNoId<QtTdLibMessageAudio> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_SUBOBJECT (audio,   QtTdLibAudio)
    Q_TDLIB_PROPERTY_SUBOBJECT (caption, QtTdLibFormattedText)

public:
    explicit QtTdLibMessageAudio (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibMessageBasicGroupChatCreate : public QtTdLibMessageContent, public FactoryNoId<QtTdLibMessageBasicGroupChatCreate> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_STRING      (title)
    QML_READONLY_CSTREF_PROPERTY (memberUserIds, QVariantList)

public:
    explicit QtTdLibMessageBasicGroupChatCreate (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibMessageSupergroupChatCreate : public QtTdLibMessageContent, public FactoryNoId<QtTdLibMessageSupergroupChatCreate> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_STRING (title)

public:
    explicit QtTdLibMessageSupergroupChatCreate (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibMessageChatChangeTitle : public QtTdLibMessageContent, public FactoryNoId<QtTdLibMessageChatChangeTitle> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_STRING (title)

public:
    explicit QtTdLibMessageChatChangeTitle (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibMessageChatChangePhoto : public QtTdLibMessageContent, public FactoryNoId<QtTdLibMessageChatChangePhoto> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_SUBOBJECT (photo, QtTdLibPhoto)

public:
    explicit QtTdLibMessageChatChangePhoto (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibMessageChatDeletePhoto : public QtTdLibMessageContent, public FactoryNoId<QtTdLibMessageChatDeletePhoto> {
    Q_OBJECT

public:
    explicit QtTdLibMessageChatDeletePhoto (QObject * parent = Q_NULLPTR);
};

class QtTdLibMessageChatAddMembers : public QtTdLibMessageContent, public FactoryNoId<QtTdLibMessageChatAddMembers> {
    Q_OBJECT
    QML_READONLY_CSTREF_PROPERTY (memberUserIds, QVariantList)

public:
    explicit QtTdLibMessageChatAddMembers (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibMessageChatJoinByLink : public QtTdLibMessageContent, public FactoryNoId<QtTdLibMessageChatJoinByLink> {
    Q_OBJECT

public:
    explicit QtTdLibMessageChatJoinByLink (QObject * parent = Q_NULLPTR);
};

class QtTdLibMessageChatDeleteMember : public QtTdLibMessageContent, public FactoryNoId<QtTdLibMessageChatDeleteMember> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_ID32 (userId)

public:
    explicit QtTdLibMessageChatDeleteMember (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibMessageChatUpgradeTo : public QtTdLibMessageContent, public FactoryNoId<QtTdLibMessageChatUpgradeTo> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_ID32 (supergroupId)

public:
    explicit QtTdLibMessageChatUpgradeTo (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibMessageChatUpgradeFrom : public QtTdLibMessageContent, public FactoryNoId<QtTdLibMessageChatUpgradeFrom> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_STRING (title)
    Q_TDLIB_PROPERTY_ID32   (basicGroupId)

public:
    explicit QtTdLibMessageChatUpgradeFrom (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibMessageContactRegistered : public QtTdLibMessageContent, public FactoryNoId<QtTdLibMessageContactRegistered> {
    Q_OBJECT

public:
    explicit QtTdLibMessageContactRegistered (QObject * parent = Q_NULLPTR);
};

class QtTdLibCallDiscardReason : public QtTdLibAbstractObject {
    Q_OBJECT

public:
    explicit QtTdLibCallDiscardReason (const QtTdLibObjectType::Type typeOf = QtTdLibObjectType::INVALID, QObject * parent = Q_NULLPTR);

    static QtTdLibCallDiscardReason * createAbstract (const QJsonObject & json, QObject * parent = Q_NULLPTR);
};

class QtTdLibCallDiscardReasonDeclined : public QtTdLibCallDiscardReason, public FactoryNoId<QtTdLibCallDiscardReasonDeclined> {
    Q_OBJECT

public:
    explicit QtTdLibCallDiscardReasonDeclined (QObject * parent = Q_NULLPTR);
};

class QtTdLibCallDiscardReasonDisconnected : public QtTdLibCallDiscardReason, public FactoryNoId<QtTdLibCallDiscardReasonDisconnected> {
    Q_OBJECT

public:
    explicit QtTdLibCallDiscardReasonDisconnected (QObject * parent = Q_NULLPTR);
};

class QtTdLibCallDiscardReasonEmpty : public QtTdLibCallDiscardReason, public FactoryNoId<QtTdLibCallDiscardReasonEmpty> {
    Q_OBJECT

public:
    explicit QtTdLibCallDiscardReasonEmpty (QObject * parent = Q_NULLPTR);
};

class QtTdLibCallDiscardReasonHungUp : public QtTdLibCallDiscardReason, public FactoryNoId<QtTdLibCallDiscardReasonHungUp> {
    Q_OBJECT

public:
    explicit QtTdLibCallDiscardReasonHungUp (QObject * parent = Q_NULLPTR);
};

class QtTdLibCallDiscardReasonMissed : public QtTdLibCallDiscardReason, public FactoryNoId<QtTdLibCallDiscardReasonMissed> {
    Q_OBJECT

public:
    explicit QtTdLibCallDiscardReasonMissed (QObject * parent = Q_NULLPTR);
};

class QtTdLibMessageCall : public QtTdLibMessageContent, public FactoryNoId<QtTdLibMessageCall> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_INT32     (duration)
    Q_TDLIB_PROPERTY_SUBOBJECT (discardReason, QtTdLibCallDiscardReason)

public:
    explicit QtTdLibMessageCall (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

//messageExpiredPhoto = MessageContent;
//messageExpiredVideo = MessageContent;
//messageLocation location:location live_period:int32 = MessageContent;
//messageVenue venue:venue = MessageContent;
//messageContact contact:contact = MessageContent;
//messageGame game:game = MessageContent;
//messageInvoice title:string description:string photo:photo currency:string total_amount:int53 start_parameter:string is_test:Bool need_shipping_address:Bool receipt_message_id:int53 = MessageContent;
//messagePinMessage message_id:int53 = MessageContent;
//messageScreenshotTaken = MessageContent;
//messageChatSetTtl ttl:int32 = MessageContent;
//messageCustomServiceAction text:string = MessageContent;
//messageGameScore game_message_id:int53 game_id:int64 score:int32 = MessageContent;
//messagePaymentSuccessful invoice_message_id:int53 currency:string total_amount:int53 = MessageContent;
//messagePaymentSuccessfulBot invoice_message_id:int53 currency:string total_amount:int53 invoice_payload:bytes shipping_option_id:string order_info:orderInfo telegram_payment_charge_id:string provider_payment_charge_id:string = MessageContent;
//messageUnsupported = MessageContent;

class QtTdLibMessage : public QtTdLibAbstractInt53IdObject, public FactoryInt53Id<QtTdLibMessage> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_INT32     (date)
    Q_TDLIB_PROPERTY_INT32     (editDate)
    Q_TDLIB_PROPERTY_INT32     (views)
    Q_TDLIB_PROPERTY_ID32      (senderUserId)
    Q_TDLIB_PROPERTY_ID53      (chatId)
    Q_TDLIB_PROPERTY_ID53      (replyToMessageId)
    Q_TDLIB_PROPERTY_ID64      (mediaAlbumId)
    Q_TDLIB_PROPERTY_BOOL      (isOutgoing)
    Q_TDLIB_PROPERTY_SUBOBJECT (content, QtTdLibMessageContent)
    //ttl:int32
    //ttl_expires_in:double
    //via_bot_user_id:int32
    //author_signature:string
    //can_be_edited:Bool
    //can_be_forwarded:Bool
    //can_be_deleted_only_for_self:Bool
    //can_be_deleted_for_all_users:Bool
    //is_channel_post:Bool
    //contains_unread_mention:Bool
    //sending_state:MessageSendingState
    //reply_markup:ReplyMarkup
    //forward_info:MessageForwardInfo

public:
    explicit QtTdLibMessage (const qint64 id = 0, QObject * parent = Q_NULLPTR);
    virtual ~QtTdLibMessage (void);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

#endif // QtTdLibMessage_H
