#ifndef QTTDCHAT_H
#define QTTDCHAT_H

#include "QtTdLibCommon.h"
#include "QtTdLibFile.h"
#include "QtTdLibMessage.h"

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

class QtTdLibChat : public QtTdLibAbstractInt53IdObject, public FactoryInt53Id<QtTdLibChat> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_INT32     (unreadCount)
    Q_TDLIB_PROPERTY_INT32     (unreadMentionCount)
    Q_TDLIB_PROPERTY_ID53      (lastReadInboxMessageId)
    Q_TDLIB_PROPERTY_ID53      (lastReadOutboxMessageId)
    Q_TDLIB_PROPERTY_ID53      (replyMarkupMessageId)
    //order:Int64
    Q_TDLIB_PROPERTY_BOOL      (isPinned)
    Q_TDLIB_PROPERTY_STRING    (title)
    Q_TDLIB_PROPERTY_STRING    (clientData)
    Q_TDLIB_PROPERTY_SUBOBJECT (type,   QtTdLibChatType)
    Q_TDLIB_PROPERTY_SUBOBJECT (photo, QtTdLibChatPhoto)
    //last_message:message
    //notification_settings:notificationSettings
    //draft_message:draftMessage
    QML_OBJMODEL_PROPERTY     (messagesModel, QtTdLibMessage)

public:
    explicit QtTdLibChat (const qint64 id = 0, QObject * parent = Q_NULLPTR);

    QHash<qint64, QtTdLibMessage *> allMessages;

    Q_INVOKABLE QtTdLibMessage * getMessageItemById (const qint64 id) const;

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

#endif // QTTDCHAT_H
