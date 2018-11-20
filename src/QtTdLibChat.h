#ifndef QTTDCHAT_H
#define QTTDCHAT_H

#include "QQmlFastObjectListModel.h"

#include "QtTdLibCommon.h"
#include "QtTdLibFile.h"
#include "QtTdLibMessage.h"

class QtTdLibChatMemberStatus : public QtTdLibAbstractObject {
    Q_OBJECT

public:
    explicit QtTdLibChatMemberStatus (const QtTdLibObjectType::Type typeOf = QtTdLibObjectType::INVALID, QObject * parent = Q_NULLPTR);

    static QtTdLibChatMemberStatus * createAbstract (const QJsonObject & json, QObject * parent = Q_NULLPTR);
};

class QtTdLibChatMemberStatusAdministrator : public QtTdLibChatMemberStatus, public FactoryNoId<QtTdLibChatMemberStatusAdministrator> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_BOOL (canBeEdited)
    Q_TDLIB_PROPERTY_BOOL (canChangeInfo)
    Q_TDLIB_PROPERTY_BOOL (canPostMessages)
    Q_TDLIB_PROPERTY_BOOL (canEditMessages)
    Q_TDLIB_PROPERTY_BOOL (canDeleteMessages)
    Q_TDLIB_PROPERTY_BOOL (canInviteUsers)
    Q_TDLIB_PROPERTY_BOOL (canRestrictMembers)
    Q_TDLIB_PROPERTY_BOOL (canPinMessages)
    Q_TDLIB_PROPERTY_BOOL (canPromoteMembers)

public:
    explicit QtTdLibChatMemberStatusAdministrator (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibChatMemberStatusBanned : public QtTdLibChatMemberStatus, public FactoryNoId<QtTdLibChatMemberStatusBanned> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_DATETIME (bannedUntilDate)

public:
    explicit QtTdLibChatMemberStatusBanned (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibChatMemberStatusCreator : public QtTdLibChatMemberStatus, public FactoryNoId<QtTdLibChatMemberStatusCreator> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_BOOL (isMember)

public:
    explicit QtTdLibChatMemberStatusCreator (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibChatMemberStatusLeft : public QtTdLibChatMemberStatus, public FactoryNoId<QtTdLibChatMemberStatusLeft> {
    Q_OBJECT

public:
    explicit QtTdLibChatMemberStatusLeft (QObject * parent = Q_NULLPTR);
};

class QtTdLibChatMemberStatusMember : public QtTdLibChatMemberStatus, public FactoryNoId<QtTdLibChatMemberStatusMember> {
    Q_OBJECT

public:
    explicit QtTdLibChatMemberStatusMember (QObject * parent = Q_NULLPTR);
};

class QtTdLibChatMemberStatusRestricted : public QtTdLibChatMemberStatus, public FactoryNoId<QtTdLibChatMemberStatusRestricted> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_BOOL     (isMember)
    Q_TDLIB_PROPERTY_BOOL     (canSendMessages)
    Q_TDLIB_PROPERTY_BOOL     (canSendMediaMessages)
    Q_TDLIB_PROPERTY_BOOL     (canSendOtherMessages)
    Q_TDLIB_PROPERTY_BOOL     (canAddWebPagePreviews)
    Q_TDLIB_PROPERTY_DATETIME (restrictedUntilDate)

public:
    explicit QtTdLibChatMemberStatusRestricted (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibChatMember : public QtTdLibAbstractObject, public FactoryNoId<QtTdLibChatMember> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_ID32      (userId)
    Q_TDLIB_PROPERTY_ID32      (inviterUserId)
    Q_TDLIB_PROPERTY_DATETIME  (joinedChatDate)
    Q_TDLIB_PROPERTY_SUBOBJECT (status, QtTdLibChatMemberStatus)
    //object_ptr< botInfo > &&bot_info

public:
    explicit QtTdLibChatMember (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibSupergroup : public QtTdLibAbstractInt32IdObject, public FactoryInt32Id<QtTdLibSupergroup> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_STRING    (username)
    Q_TDLIB_PROPERTY_DATETIME  (date)
    Q_TDLIB_PROPERTY_INT32     (memberCount)
    Q_TDLIB_PROPERTY_BOOL      (anyoneCanInvite)
    Q_TDLIB_PROPERTY_BOOL      (signMessages)
    Q_TDLIB_PROPERTY_BOOL      (isChannel)
    Q_TDLIB_PROPERTY_BOOL      (isVerified)
    Q_TDLIB_PROPERTY_STRING    (restrictionReason)
    Q_TDLIB_PROPERTY_STRING    (description)
    Q_TDLIB_PROPERTY_INT32     (administratorCount)
    Q_TDLIB_PROPERTY_INT32     (restrictedCount)
    Q_TDLIB_PROPERTY_INT32     (bannedCount)
    Q_TDLIB_PROPERTY_BOOL      (canGetMembers)
    Q_TDLIB_PROPERTY_BOOL      (canSetUsername)
    Q_TDLIB_PROPERTY_BOOL      (canSetStickerSet)
    Q_TDLIB_PROPERTY_BOOL      (isAllHistoryAvailable)
    Q_TDLIB_PROPERTY_ID64      (stickerSetId)
    Q_TDLIB_PROPERTY_STRING    (inviteLink)
    Q_TDLIB_PROPERTY_ID64      (pinnedMessageId)
    Q_TDLIB_PROPERTY_ID32      (upgradedFromBasicGroupId)
    Q_TDLIB_PROPERTY_ID64      (upgradedFromMaxMessageId)
    Q_TDLIB_PROPERTY_SUBOBJECT (status, QtTdLibChatMemberStatus)
    QML_OBJMODEL_PROPERTY      (members, QtTdLibChatMember)

public:
    explicit QtTdLibSupergroup (const qint32 id = 0, QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibBasicGroup : public QtTdLibAbstractInt32IdObject, public FactoryInt32Id<QtTdLibBasicGroup> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_INT32     (memberCount)
    Q_TDLIB_PROPERTY_BOOL      (isActive)
    Q_TDLIB_PROPERTY_BOOL      (everyoneIsAdministrator)
    Q_TDLIB_PROPERTY_ID32      (upgradedToSupergroupId)
    Q_TDLIB_PROPERTY_ID32      (creatorUserId)
    Q_TDLIB_PROPERTY_STRING    (inviteLink)
    Q_TDLIB_PROPERTY_SUBOBJECT (status, QtTdLibChatMemberStatus)
    QML_OBJMODEL_PROPERTY      (members, QtTdLibChatMember)

public:
    explicit QtTdLibBasicGroup (const qint32 id = 0, QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibChatPhoto : public QtTdLibAbstractObject, public FactoryNoId<QtTdLibChatPhoto> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_SUBOBJECT (big,   QtTdLibFile)
    Q_TDLIB_PROPERTY_SUBOBJECT (small, QtTdLibFile)

public:
    explicit QtTdLibChatPhoto (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibChatType : public QtTdLibAbstractObject {
    Q_OBJECT

public:
    explicit QtTdLibChatType (const QtTdLibObjectType::Type typeOf = QtTdLibObjectType::INVALID, QObject * parent = Q_NULLPTR);

    static QtTdLibChatType * createAbstract (const QJsonObject & json, QObject * parent = Q_NULLPTR);
};

class QtTdLibChatTypePrivate : public QtTdLibChatType, public FactoryNoId<QtTdLibChatTypePrivate> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_ID32 (userId)

public:
    explicit QtTdLibChatTypePrivate (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibChatTypeBasicGroup : public QtTdLibChatType, public FactoryNoId<QtTdLibChatTypeBasicGroup> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_ID32 (basicGroupId)

public:
    explicit QtTdLibChatTypeBasicGroup (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibChatTypeSupergroup : public QtTdLibChatType, public FactoryNoId<QtTdLibChatTypeSupergroup> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_ID32 (supergroupId)
    Q_TDLIB_PROPERTY_BOOL (isChannel)

public:
    explicit QtTdLibChatTypeSupergroup (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibChatTypeSecret : public QtTdLibChatType, public FactoryNoId<QtTdLibChatTypeSecret> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_ID32 (secretChatId)
    Q_TDLIB_PROPERTY_ID32 (userId)

public:
    explicit QtTdLibChatTypeSecret (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibChatNotificationSettings : public QtTdLibAbstractObject, public FactoryNoId<QtTdLibChatNotificationSettings> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_BOOL  (useDefaultMuteFor)
    Q_TDLIB_PROPERTY_INT32 (muteFor)
    //use_default_sound:bool
    //sound:string
    //use_default_show_preview:bool
    //show_preview:bool

public:
    explicit QtTdLibChatNotificationSettings (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibChat : public QtTdLibAbstractInt53IdObject, public FactoryInt53Id<QtTdLibChat> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_INT32     (unreadCount)
    Q_TDLIB_PROPERTY_INT32     (unreadMentionCount)
    Q_TDLIB_PROPERTY_ID53      (lastReadInboxMessageId)
    Q_TDLIB_PROPERTY_ID53      (lastReadOutboxMessageId)
    Q_TDLIB_PROPERTY_ID53      (replyMarkupMessageId)
    Q_TDLIB_PROPERTY_INT64     (order)
    Q_TDLIB_PROPERTY_BOOL      (isPinned)
    Q_TDLIB_PROPERTY_STRING    (title)
    Q_TDLIB_PROPERTY_STRING    (clientData)
    Q_TDLIB_PROPERTY_SUBOBJECT (type, QtTdLibChatType)
    Q_TDLIB_PROPERTY_SUBOBJECT (photo, QtTdLibChatPhoto)
    Q_TDLIB_PROPERTY_SUBOBJECT (notificationSettings, QtTdLibChatNotificationSettings)
    QML_FASTOBJMODEL_PROPERTY  (messagesModel, QtTdLibMessage)
    //last_message:message
    //draft_message:draftMessage

public:
    explicit QtTdLibChat (const qint64 id = 0, QObject * parent = Q_NULLPTR);

    QHash<qint64, QtTdLibMessage *> allMessages;

    Q_INVOKABLE QtTdLibMessage * getMessageItemById (const QString & id) const;

    QtTdLibMessage * getMessageItemById (const qint64 id) const;

    void addMessageItem    (QtTdLibMessage * messageItem);
    void removeMessageItem (QtTdLibMessage * messageItem);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

#endif // QTTDCHAT_H
