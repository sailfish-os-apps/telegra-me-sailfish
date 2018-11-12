#ifndef QtTdLibUser_H
#define QtTdLibUser_H

#include "QtTdLibCommon.h"
#include "QtTdLibFile.h"

class QtTdLibProfilePhoto : public QtTdLibAbstractStrIdObject {
    Q_OBJECT
    Q_TDLIB_PROPERTY_SUBOBJECT (big,   QtTdLibFile)
    Q_TDLIB_PROPERTY_SUBOBJECT (small, QtTdLibFile)

public:
    explicit QtTdLibProfilePhoto (const QString & id = "", QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibLinkState : public QtTdLibAbstractObject {
    Q_OBJECT

public:
    explicit QtTdLibLinkState (const QtTdLibObjectType::Type typeOf = QtTdLibObjectType::INVALID, QObject * parent = Q_NULLPTR);

    static QtTdLibLinkState * create (const QJsonObject & json, QObject * parent);
};

class QtTdLibLinkStateNone : public QtTdLibLinkState {
    Q_OBJECT

public:
    explicit QtTdLibLinkStateNone (QObject * parent = Q_NULLPTR);
};

class QtTdLibLinkStateKnowsPhoneNumber : public QtTdLibLinkState {
    Q_OBJECT

public:
    explicit QtTdLibLinkStateKnowsPhoneNumber (QObject * parent = Q_NULLPTR);
};

class QtTdLibLinkStateIsContact : public QtTdLibLinkState {
    Q_OBJECT

public:
    explicit QtTdLibLinkStateIsContact (QObject * parent = Q_NULLPTR);
};

class QtTdLibUserType : public QtTdLibAbstractObject {
    Q_OBJECT

public:
    explicit QtTdLibUserType (const QtTdLibObjectType::Type typeOf = QtTdLibObjectType::INVALID, QObject * parent = Q_NULLPTR);

    static QtTdLibUserType * create (const QJsonObject & json, QObject * parent);
};

class QtTdLibUserTypeRegular : public QtTdLibUserType {
    Q_OBJECT

public:
    explicit QtTdLibUserTypeRegular (QObject * parent = Q_NULLPTR);
};

class QtTdLibUserTypeDeleted : public QtTdLibUserType {
    Q_OBJECT

public:
    explicit QtTdLibUserTypeDeleted (QObject * parent = Q_NULLPTR);
};

class QtTdLibUserTypeBot : public QtTdLibUserType {
    Q_OBJECT
    //can_join_groups:Bool
    //can_read_all_group_messages:Bool
    //is_inline:Bool
    //inline_query_placeholder:string
    //need_location:Bool

public:
    explicit QtTdLibUserTypeBot (QObject * parent = Q_NULLPTR);
};

class QtTdLibUserTypeUnknown : public QtTdLibUserType {
    Q_OBJECT

public:
    explicit QtTdLibUserTypeUnknown (QObject * parent = Q_NULLPTR);
};

class QtTdLibUserStatus : public QtTdLibAbstractObject {
    Q_OBJECT

public:
    explicit QtTdLibUserStatus (const QtTdLibObjectType::Type typeOf = QtTdLibObjectType::INVALID, QObject * parent = Q_NULLPTR);

    static QtTdLibUserStatus * create (const QJsonObject & json, QObject * parent);
};

class QtTdLibUserStatusEmpty : public QtTdLibUserStatus {
    Q_OBJECT

public:
    explicit QtTdLibUserStatusEmpty (QObject * parent = Q_NULLPTR);
};

class QtTdLibUserStatusOnline : public QtTdLibUserStatus {
    Q_OBJECT
    //expires:int32

public:
    explicit QtTdLibUserStatusOnline (QObject * parent = Q_NULLPTR);
};

class QtTdLibUserStatusOffline : public QtTdLibUserStatus {
    Q_OBJECT
    //was_online:int32

public:
    explicit QtTdLibUserStatusOffline (QObject * parent = Q_NULLPTR);
};

class QtTdLibUserStatusRecently : public QtTdLibUserStatus {
    Q_OBJECT

public:
    explicit QtTdLibUserStatusRecently (QObject * parent = Q_NULLPTR);
};

class QtTdLibUserStatusLastWeek : public QtTdLibUserStatus {
    Q_OBJECT

public:
    explicit QtTdLibUserStatusLastWeek (QObject * parent = Q_NULLPTR);
};

class QtTdLibUserStatusLastMonth : public QtTdLibUserStatus {
    Q_OBJECT

public:
    explicit QtTdLibUserStatusLastMonth (QObject * parent = Q_NULLPTR);
};

class QtTdLibUser : public QtTdLibAbstractInt32IdObject {
    Q_OBJECT
    Q_TDLIB_PROPERTY_STRING    (phoneNumber)
    Q_TDLIB_PROPERTY_STRING    (username)
    Q_TDLIB_PROPERTY_STRING    (firstName)
    Q_TDLIB_PROPERTY_STRING    (lastName)
    Q_TDLIB_PROPERTY_STRING    (languageCode)
    Q_TDLIB_PROPERTY_STRING    (restrictionReason)
    Q_TDLIB_PROPERTY_BOOL      (isVerified)
    Q_TDLIB_PROPERTY_BOOL      (haveAccess)
    Q_TDLIB_PROPERTY_SUBOBJECT (type,             QtTdLibUserType)
    Q_TDLIB_PROPERTY_SUBOBJECT (outgoingLink,    QtTdLibLinkState)
    Q_TDLIB_PROPERTY_SUBOBJECT (incomingLink,    QtTdLibLinkState)
    Q_TDLIB_PROPERTY_SUBOBJECT (status,         QtTdLibUserStatus)
    Q_TDLIB_PROPERTY_SUBOBJECT (profilePhoto, QtTdLibProfilePhoto)

public:
    explicit QtTdLibUser (const qint32 id = 0, QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

#endif // QtTdLibUser_H
