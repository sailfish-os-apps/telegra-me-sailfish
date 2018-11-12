#ifndef QTTDLIBAUTHORIZATION_H
#define QTTDLIBAUTHORIZATION_H

#include "QtTdLibCommon.h"

class QtTdLibAuthorizationState : public QtTdLibAbstractObject {
    Q_OBJECT

public:
    explicit QtTdLibAuthorizationState (const QtTdLibObjectType::Type typeOf = QtTdLibObjectType::INVALID, QObject * parent = Q_NULLPTR);

    static QtTdLibAuthorizationState * create (const QJsonObject & json, QObject * parent);
};

class QtTdLibAuthorizationStateWaitTdlibParameters : public QtTdLibAuthorizationState {
    Q_OBJECT

public:
    explicit QtTdLibAuthorizationStateWaitTdlibParameters (QObject * parent = Q_NULLPTR);
};

class QtTdLibAuthorizationStateWaitEncryptionKey : public QtTdLibAuthorizationState {
    Q_OBJECT
    Q_TDLIB_PROPERTY_BOOL (isEncrypted)

public:
    explicit QtTdLibAuthorizationStateWaitEncryptionKey (QObject * parent = Q_NULLPTR);
};

class QtTdLibAuthorizationStateWaitPhoneNumber : public QtTdLibAuthorizationState {
    Q_OBJECT

public:
    explicit QtTdLibAuthorizationStateWaitPhoneNumber (QObject * parent = Q_NULLPTR);
};

class QtTdLibAuthenticationCodeType : public QtTdLibAbstractObject {
    Q_OBJECT

public:
    explicit QtTdLibAuthenticationCodeType (const QtTdLibObjectType::Type typeOf = QtTdLibObjectType::INVALID, QObject * parent = Q_NULLPTR);

    static QtTdLibAuthenticationCodeType * create (const QJsonObject & json, QObject * parent);
};

class QtTdLibAuthenticationCodeTypeTelegramMessage : public QtTdLibAuthenticationCodeType {
    Q_OBJECT
    Q_TDLIB_PROPERTY_INT32 (length)

public:
    explicit QtTdLibAuthenticationCodeTypeTelegramMessage (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibAuthenticationCodeTypeSms : public QtTdLibAuthenticationCodeType {
    Q_OBJECT
    Q_TDLIB_PROPERTY_INT32 (length)

public:
    explicit QtTdLibAuthenticationCodeTypeSms (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibAuthenticationCodeTypeCall : public QtTdLibAuthenticationCodeType {
    Q_OBJECT
    Q_TDLIB_PROPERTY_INT32 (length)

public:
    explicit QtTdLibAuthenticationCodeTypeCall (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibAuthenticationCodeTypeFlashCall : public QtTdLibAuthenticationCodeType {
    Q_OBJECT
    Q_TDLIB_PROPERTY_STRING (pattern)

public:
    explicit QtTdLibAuthenticationCodeTypeFlashCall (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibAuthenticationCodeInfo : public QtTdLibAbstractObject {
    Q_OBJECT
    Q_TDLIB_PROPERTY_INT32     (timeout)
    Q_TDLIB_PROPERTY_SUBOBJECT (type,     QtTdLibAuthenticationCodeType)
    Q_TDLIB_PROPERTY_SUBOBJECT (nextType, QtTdLibAuthenticationCodeType)

public:
    explicit QtTdLibAuthenticationCodeInfo (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibAuthorizationStateWaitCode : public QtTdLibAuthorizationState {
    Q_OBJECT
    Q_TDLIB_PROPERTY_BOOL      (isRegistered)
    Q_TDLIB_PROPERTY_SUBOBJECT (codeInfo, QtTdLibAuthenticationCodeInfo)

public:
    explicit QtTdLibAuthorizationStateWaitCode (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibAuthorizationStateWaitPassword : public QtTdLibAuthorizationState {
    Q_OBJECT
    //password_hint:string
    //has_recovery_email_address:Bool
    //recovery_email_address_pattern:strin

public:
    explicit QtTdLibAuthorizationStateWaitPassword (QObject * parent = Q_NULLPTR);
};

class QtTdLibAuthorizationStateReady : public QtTdLibAuthorizationState {
    Q_OBJECT

public:
    explicit QtTdLibAuthorizationStateReady (QObject * parent = Q_NULLPTR);
};

class QtTdLibAuthorizationStateLoggingOut : public QtTdLibAuthorizationState {
    Q_OBJECT

public:
    explicit QtTdLibAuthorizationStateLoggingOut (QObject * parent = Q_NULLPTR);
};

class QtTdLibAuthorizationStateClosing : public QtTdLibAuthorizationState {
    Q_OBJECT

public:
    explicit QtTdLibAuthorizationStateClosing (QObject * parent = Q_NULLPTR);
};

class QtTdLibAuthorizationStateClosed : public QtTdLibAuthorizationState {
    Q_OBJECT

public:
    explicit QtTdLibAuthorizationStateClosed (QObject * parent = Q_NULLPTR);
};

#endif // QTTDLIBAUTHORIZATION_H
