
#include "QtTdLibAuth.h"

QtTdLibAuthorizationState::QtTdLibAuthorizationState (const QtTdLibObjectType::Type typeOf, QObject * parent)
    : QtTdLibAbstractObject { typeOf, parent }
{ }

QtTdLibAuthorizationState * QtTdLibAuthorizationState::create (const QJsonObject & json, QObject * parent) {
    switch (QtTdLibEnums::objectTypeEnumFromJson (json)) {
        case QtTdLibObjectType::AUTHORIZATION_STATE_WAIT_TDLIB_PARAMETERS: return new QtTdLibAuthorizationStateWaitTdlibParameters { parent };
        case QtTdLibObjectType::AUTHORIZATION_STATE_WAIT_ENCRYPTION_KEY:   return new QtTdLibAuthorizationStateWaitEncryptionKey   { parent };
        case QtTdLibObjectType::AUTHORIZATION_STATE_WAIT_PHONE_NUMBER:     return new QtTdLibAuthorizationStateWaitPhoneNumber     { parent };
        case QtTdLibObjectType::AUTHORIZATION_STATE_WAIT_CODE:             return new QtTdLibAuthorizationStateWaitCode            { parent };
        case QtTdLibObjectType::AUTHORIZATION_STATE_WAIT_PASSWORD:         return new QtTdLibAuthorizationStateWaitPassword        { parent };
        case QtTdLibObjectType::AUTHORIZATION_STATE_READY:                 return new QtTdLibAuthorizationStateReady               { parent };
        case QtTdLibObjectType::AUTHORIZATION_STATE_LOGGING_OUT:           return new QtTdLibAuthorizationStateLoggingOut          { parent };
        case QtTdLibObjectType::AUTHORIZATION_STATE_CLOSING:               return new QtTdLibAuthorizationStateClosing             { parent };
        case QtTdLibObjectType::AUTHORIZATION_STATE_CLOSED:                return new QtTdLibAuthorizationStateClosed              { parent };
        default: return Q_NULLPTR;
    }
}

QtTdLibAuthorizationStateWaitTdlibParameters::QtTdLibAuthorizationStateWaitTdlibParameters (QObject * parent)
    : QtTdLibAuthorizationState { QtTdLibObjectType::AUTHORIZATION_STATE_WAIT_TDLIB_PARAMETERS, parent }
{ }

QtTdLibAuthorizationStateWaitEncryptionKey::QtTdLibAuthorizationStateWaitEncryptionKey (QObject * parent)
    : QtTdLibAuthorizationState { QtTdLibObjectType::AUTHORIZATION_STATE_WAIT_ENCRYPTION_KEY, parent }
{ }

QtTdLibAuthorizationStateWaitPhoneNumber::QtTdLibAuthorizationStateWaitPhoneNumber (QObject * parent)
    : QtTdLibAuthorizationState { QtTdLibObjectType::AUTHORIZATION_STATE_WAIT_PHONE_NUMBER, parent }
{ }
QtTdLibAuthorizationStateWaitCode::QtTdLibAuthorizationStateWaitCode (QObject * parent)
    : QtTdLibAuthorizationState { QtTdLibObjectType::AUTHORIZATION_STATE_WAIT_CODE, parent }
{ }

void QtTdLibAuthorizationStateWaitCode::updateFromJson (const QJsonObject & json) {
    set_isRegistered_withJSON  (json ["is_registered"]);
    set_codeInfo_withJSON      (json ["code_info"], &QtTdLibAbstractObject::create<QtTdLibAuthenticationCodeInfo>);
}

QtTdLibAuthorizationStateWaitPassword::QtTdLibAuthorizationStateWaitPassword (QObject * parent)
    : QtTdLibAuthorizationState { QtTdLibObjectType::AUTHORIZATION_STATE_WAIT_PASSWORD, parent }
{ }

QtTdLibAuthorizationStateReady::QtTdLibAuthorizationStateReady (QObject * parent)
    : QtTdLibAuthorizationState { QtTdLibObjectType::AUTHORIZATION_STATE_READY, parent }
{ }

QtTdLibAuthorizationStateLoggingOut::QtTdLibAuthorizationStateLoggingOut (QObject * parent)
    : QtTdLibAuthorizationState { QtTdLibObjectType::AUTHORIZATION_STATE_LOGGING_OUT, parent }
{ }

QtTdLibAuthorizationStateClosing::QtTdLibAuthorizationStateClosing (QObject * parent)
    : QtTdLibAuthorizationState { QtTdLibObjectType::AUTHORIZATION_STATE_CLOSING, parent }
{ }

QtTdLibAuthorizationStateClosed::QtTdLibAuthorizationStateClosed (QObject * parent)
    : QtTdLibAuthorizationState { QtTdLibObjectType::AUTHORIZATION_STATE_CLOSED, parent }
{ }

QtTdLibAuthenticationCodeInfo::QtTdLibAuthenticationCodeInfo (QObject * parent)
    : QtTdLibAbstractObject { QtTdLibObjectType::AUTHENTICATION_CODE_INFO, parent }
{ }

void QtTdLibAuthenticationCodeInfo::updateFromJson (const QJsonObject & json) {
    set_timeout_withJSON  (json ["timeout"]);
    set_type_withJSON     (json ["type"],      &QtTdLibAuthenticationCodeType::create);
    set_nextType_withJSON (json ["next_type"], &QtTdLibAuthenticationCodeType::create);
}

QtTdLibAuthenticationCodeType::QtTdLibAuthenticationCodeType (const QtTdLibObjectType::Type typeOf, QObject * parent)
    : QtTdLibAbstractObject { typeOf, parent }
{ }

QtTdLibAuthenticationCodeType * QtTdLibAuthenticationCodeType::create (const QJsonObject & json, QObject * parent) {
    switch (QtTdLibEnums::objectTypeEnumFromJson (json)) {
        case QtTdLibObjectType::AUTHENTICATION_CODE_TYPE_TELEGRAM_MESSAGE: return new QtTdLibAuthenticationCodeTypeTelegramMessage { parent };
        case QtTdLibObjectType::AUTHENTICATION_CODE_TYPE_SMS:              return new QtTdLibAuthenticationCodeTypeSms             { parent };
        case QtTdLibObjectType::AUTHENTICATION_CODE_TYPE_CALL:             return new QtTdLibAuthenticationCodeTypeCall            { parent };
        case QtTdLibObjectType::AUTHENTICATION_CODE_TYPE_FLASH_CALL:       return new QtTdLibAuthenticationCodeTypeFlashCall       { parent };
        default: return Q_NULLPTR;
    }
}

QtTdLibAuthenticationCodeTypeTelegramMessage::QtTdLibAuthenticationCodeTypeTelegramMessage (QObject * parent)
    : QtTdLibAuthenticationCodeType { QtTdLibObjectType::AUTHENTICATION_CODE_TYPE_TELEGRAM_MESSAGE, parent }
{ }

void QtTdLibAuthenticationCodeTypeTelegramMessage::updateFromJson (const QJsonObject & json) {
    set_length_withJSON (json ["length"]);
}

QtTdLibAuthenticationCodeTypeSms::QtTdLibAuthenticationCodeTypeSms (QObject * parent)
    : QtTdLibAuthenticationCodeType { QtTdLibObjectType::AUTHENTICATION_CODE_TYPE_SMS, parent }
{ }

void QtTdLibAuthenticationCodeTypeSms::updateFromJson (const QJsonObject & json) {
    set_length_withJSON (json ["length"]);
}

QtTdLibAuthenticationCodeTypeCall::QtTdLibAuthenticationCodeTypeCall (QObject * parent)
    : QtTdLibAuthenticationCodeType { QtTdLibObjectType::AUTHENTICATION_CODE_TYPE_CALL, parent }
{ }

void QtTdLibAuthenticationCodeTypeCall::updateFromJson (const QJsonObject & json) {
    set_length_withJSON (json ["length"]);
}

QtTdLibAuthenticationCodeTypeFlashCall::QtTdLibAuthenticationCodeTypeFlashCall (QObject * parent)
    : QtTdLibAuthenticationCodeType { QtTdLibObjectType::AUTHENTICATION_CODE_TYPE_FLASH_CALL, parent }
{ }

void QtTdLibAuthenticationCodeTypeFlashCall::updateFromJson (const QJsonObject & json) {
    set_pattern_withJSON (json ["pattern"]);
}
