#ifndef QTTDLIBAUTHORIZATION_H
#define QTTDLIBAUTHORIZATION_H

#include "QtTdLibCommon.h"

class QtTdLibAuthenticationCodeType : public QtTdLibAbstractObject {
    Q_OBJECT

public:
    explicit QtTdLibAuthenticationCodeType (const QtTdLibObjectType::Type typeOf = QtTdLibObjectType::INVALID, QObject * parent = Q_NULLPTR);

    static QtTdLibAuthenticationCodeType * createXXX (const QJsonObject & json, QObject * parent = Q_NULLPTR);
};

class QtTdLibAuthenticationCodeTypeTelegramMessage : public QtTdLibAuthenticationCodeType, public FactoryNoId<QtTdLibAuthenticationCodeTypeTelegramMessage> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_INT32 (length)

public:
    explicit QtTdLibAuthenticationCodeTypeTelegramMessage (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibAuthenticationCodeTypeSms : public QtTdLibAuthenticationCodeType, public FactoryNoId<QtTdLibAuthenticationCodeTypeSms> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_INT32 (length)

public:
    explicit QtTdLibAuthenticationCodeTypeSms (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibAuthenticationCodeTypeCall : public QtTdLibAuthenticationCodeType, public FactoryNoId<QtTdLibAuthenticationCodeTypeCall> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_INT32 (length)

public:
    explicit QtTdLibAuthenticationCodeTypeCall (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibAuthenticationCodeTypeFlashCall : public QtTdLibAuthenticationCodeType, public FactoryNoId<QtTdLibAuthenticationCodeTypeFlashCall> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_STRING (pattern)

public:
    explicit QtTdLibAuthenticationCodeTypeFlashCall (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibAuthenticationCodeInfo : public QtTdLibAbstractObject, public FactoryNoId<QtTdLibAuthenticationCodeInfo> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_INT32     (timeout)
    Q_TDLIB_PROPERTY_SUBOBJECT (type,     QtTdLibAuthenticationCodeType)
    Q_TDLIB_PROPERTY_SUBOBJECT (nextType, QtTdLibAuthenticationCodeType)

public:
    explicit QtTdLibAuthenticationCodeInfo (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibAuthorizationState : public QtTdLibAbstractObject {
    Q_OBJECT

public:
    explicit QtTdLibAuthorizationState (const QtTdLibObjectType::Type typeOf = QtTdLibObjectType::INVALID, QObject * parent = Q_NULLPTR);

    static QtTdLibAuthorizationState * createXXX (const QJsonObject & json, QObject * parent = Q_NULLPTR);
};

class QtTdLibAuthorizationStateWaitTdlibParameters : public QtTdLibAuthorizationState, public FactoryNoId<QtTdLibAuthorizationStateWaitTdlibParameters> {
    Q_OBJECT

public:
    explicit QtTdLibAuthorizationStateWaitTdlibParameters (QObject * parent = Q_NULLPTR);
};

class QtTdLibAuthorizationStateWaitEncryptionKey : public QtTdLibAuthorizationState, public FactoryNoId<QtTdLibAuthorizationStateWaitEncryptionKey> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_BOOL (isEncrypted)

public:
    explicit QtTdLibAuthorizationStateWaitEncryptionKey (QObject * parent = Q_NULLPTR);
};

class QtTdLibAuthorizationStateWaitPhoneNumber : public QtTdLibAuthorizationState, public FactoryNoId<QtTdLibAuthorizationStateWaitPhoneNumber> {
    Q_OBJECT

public:
    explicit QtTdLibAuthorizationStateWaitPhoneNumber (QObject * parent = Q_NULLPTR);
};

class QtTdLibAuthorizationStateWaitCode : public QtTdLibAuthorizationState, public FactoryNoId<QtTdLibAuthorizationStateWaitCode> {
    Q_OBJECT
    Q_TDLIB_PROPERTY_BOOL      (isRegistered)
    Q_TDLIB_PROPERTY_SUBOBJECT (codeInfo, QtTdLibAuthenticationCodeInfo)

public:
    explicit QtTdLibAuthorizationStateWaitCode (QObject * parent = Q_NULLPTR);

    void updateFromJson (const QJsonObject & json) Q_DECL_FINAL;
};

class QtTdLibAuthorizationStateWaitPassword : public QtTdLibAuthorizationState, public FactoryNoId<QtTdLibAuthorizationStateWaitPassword> {
    Q_OBJECT
    //password_hint:string
    //has_recovery_email_address:Bool
    //recovery_email_address_pattern:strin

public:
    explicit QtTdLibAuthorizationStateWaitPassword (QObject * parent = Q_NULLPTR);
};

class QtTdLibAuthorizationStateReady : public QtTdLibAuthorizationState, public FactoryNoId<QtTdLibAuthorizationStateReady> {
    Q_OBJECT

public:
    explicit QtTdLibAuthorizationStateReady (QObject * parent = Q_NULLPTR);
};

class QtTdLibAuthorizationStateLoggingOut : public QtTdLibAuthorizationState, public FactoryNoId<QtTdLibAuthorizationStateLoggingOut> {
    Q_OBJECT

public:
    explicit QtTdLibAuthorizationStateLoggingOut (QObject * parent = Q_NULLPTR);
};

class QtTdLibAuthorizationStateClosing : public QtTdLibAuthorizationState, public FactoryNoId<QtTdLibAuthorizationStateClosing> {
    Q_OBJECT

public:
    explicit QtTdLibAuthorizationStateClosing (QObject * parent = Q_NULLPTR);
};

class QtTdLibAuthorizationStateClosed : public QtTdLibAuthorizationState, public FactoryNoId<QtTdLibAuthorizationStateClosed> {
    Q_OBJECT

public:
    explicit QtTdLibAuthorizationStateClosed (QObject * parent = Q_NULLPTR);
};

#endif // QTTDLIBAUTHORIZATION_H
