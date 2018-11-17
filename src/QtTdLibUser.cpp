
#include "QtTdLibUser.h"

QtTdLibProfilePhoto::QtTdLibProfilePhoto (const QString & id, QObject * parent)
    : QtTdLibAbstractStrIdObject { QtTdLibObjectType::PROFILE_PHOTO, id, parent }
{ }

void QtTdLibProfilePhoto::updateFromJson (const QJsonObject & json) {
    set_big_withJSON   (json ["big"],   &QtTdLibFile::create);
    set_small_withJSON (json ["small"], &QtTdLibFile::create);
}

QtTdLibLinkState::QtTdLibLinkState (const QtTdLibObjectType::Type typeOf, QObject * parent)
    : QtTdLibAbstractObject { typeOf, parent }
{ }

QtTdLibLinkState * QtTdLibLinkState::createAbstract (const QJsonObject & json, QObject * parent) {
    switch (QtTdLibEnums::objectTypeEnumFromJson (json)) {
        case QtTdLibObjectType::LINK_STATE_IS_CONTACT:         return QtTdLibLinkStateIsContact::create        (json, parent);
        case QtTdLibObjectType::LINK_STATE_KNOWS_PHONE_NUMBER: return QtTdLibLinkStateKnowsPhoneNumber::create (json, parent);
        case QtTdLibObjectType::LINK_STATE_NONE:               return QtTdLibLinkStateNone::create             (json, parent);
        default: return Q_NULLPTR;
    }
}

QtTdLibLinkStateNone::QtTdLibLinkStateNone (QObject * parent)
    : QtTdLibLinkState { QtTdLibObjectType::LINK_STATE_NONE, parent }
{ }

QtTdLibLinkStateKnowsPhoneNumber::QtTdLibLinkStateKnowsPhoneNumber (QObject * parent)
    : QtTdLibLinkState { QtTdLibObjectType::LINK_STATE_KNOWS_PHONE_NUMBER, parent }
{ }

QtTdLibLinkStateIsContact::QtTdLibLinkStateIsContact (QObject * parent)
    : QtTdLibLinkState { QtTdLibObjectType::LINK_STATE_IS_CONTACT, parent }
{ }

QtTdLibUser::QtTdLibUser (const qint32 id, QObject * parent)
    : QtTdLibAbstractInt32IdObject { QtTdLibObjectType::USER, id, parent }
{
    QtTdLibCollection::allUsers.insert (id, this);
}

void QtTdLibUser::updateFromJson (const QJsonObject & json) {
    set_phoneNumber_withJSON       (json ["phone_number"]);
    set_username_withJSON          (json ["username"]);
    set_firstName_withJSON         (json ["first_name"]);
    set_lastName_withJSON          (json ["last_name"]);
    set_languageCode_withJSON      (json ["language_code"]);
    set_restrictionReason_withJSON (json ["restriction_reason"]);
    set_isVerified_withJSON        (json ["is_verified"]);
    set_haveAccess_withJSON        (json ["have_access"]);
    set_type_withJSON              (json ["type"],          &QtTdLibUserType::createAbstract);
    set_status_withJSON            (json ["status"],        &QtTdLibUserStatus::createAbstract);
    set_outgoingLink_withJSON      (json ["outgoing_link"], &QtTdLibLinkState::createAbstract);
    set_incomingLink_withJSON      (json ["incoming_link"], &QtTdLibLinkState::createAbstract);
    set_profilePhoto_withJSON      (json ["profile_photo"], &QtTdLibProfilePhoto::create);
}

QtTdLibUserType::QtTdLibUserType (const QtTdLibObjectType::Type typeOf, QObject * parent)
    : QtTdLibAbstractObject { typeOf, parent }
{ }

QtTdLibUserType * QtTdLibUserType::createAbstract (const QJsonObject & json, QObject * parent) {
    switch (QtTdLibEnums::objectTypeEnumFromJson (json)) {
        case QtTdLibObjectType::USER_TYPE_REGULAR: return QtTdLibUserTypeRegular::create (json, parent);
        case QtTdLibObjectType::USER_TYPE_DELETED: return QtTdLibUserTypeDeleted::create (json, parent);
        case QtTdLibObjectType::USER_TYPE_BOT:     return QtTdLibUserTypeBot::create     (json, parent);
        case QtTdLibObjectType::USER_TYPE_UNKNOWN: return QtTdLibUserTypeUnknown::create (json, parent);
        default: return Q_NULLPTR;
    }
}

QtTdLibUserTypeRegular::QtTdLibUserTypeRegular (QObject * parent)
    : QtTdLibUserType { QtTdLibObjectType::USER_TYPE_REGULAR, parent }
{ }

QtTdLibUserTypeDeleted::QtTdLibUserTypeDeleted (QObject * parent)
    : QtTdLibUserType { QtTdLibObjectType::USER_TYPE_DELETED, parent }
{ }

QtTdLibUserTypeBot::QtTdLibUserTypeBot (QObject * parent)
    : QtTdLibUserType { QtTdLibObjectType::USER_TYPE_BOT, parent }
{ }

QtTdLibUserTypeUnknown::QtTdLibUserTypeUnknown (QObject * parent)
    : QtTdLibUserType { QtTdLibObjectType::USER_TYPE_UNKNOWN, parent }
{ }

QtTdLibUserStatus::QtTdLibUserStatus (const QtTdLibObjectType::Type typeOf, QObject * parent)
    : QtTdLibAbstractObject { typeOf, parent }
{ }

QtTdLibUserStatus * QtTdLibUserStatus::createAbstract (const QJsonObject & json, QObject * parent) {
    switch (QtTdLibEnums::objectTypeEnumFromJson (json)) {
        case QtTdLibObjectType::USER_STATUS_EMPTY:      return QtTdLibUserStatusEmpty::create     (json, parent);
        case QtTdLibObjectType::USER_STATUS_ONLINE:     return QtTdLibUserStatusOnline::create    (json, parent);
        case QtTdLibObjectType::USER_STATUS_OFFLINE:    return QtTdLibUserStatusOffline::create   (json, parent);
        case QtTdLibObjectType::USER_STATUS_RECENTLY:   return QtTdLibUserStatusRecently::create  (json, parent);
        case QtTdLibObjectType::USER_STATUS_LAST_WEEK:  return QtTdLibUserStatusLastWeek::create  (json, parent);
        case QtTdLibObjectType::USER_STATUS_LAST_MONTH: return QtTdLibUserStatusLastMonth::create (json, parent);
        default: return Q_NULLPTR;
    }
}

QtTdLibUserStatusEmpty::QtTdLibUserStatusEmpty (QObject * parent)
    : QtTdLibUserStatus { QtTdLibObjectType::USER_STATUS_EMPTY, parent }
{ }

QtTdLibUserStatusOnline::QtTdLibUserStatusOnline (QObject * parent)
    : QtTdLibUserStatus { QtTdLibObjectType::USER_STATUS_ONLINE, parent }
{ }

QtTdLibUserStatusOffline::QtTdLibUserStatusOffline (QObject * parent)
    : QtTdLibUserStatus { QtTdLibObjectType::USER_STATUS_OFFLINE, parent }
{ }

void QtTdLibUserStatusOffline::updateFromJson (const QJsonObject & json) {
    set_wasOnline_withJSON (json ["was_online"]);
}

QtTdLibUserStatusRecently::QtTdLibUserStatusRecently (QObject * parent)
    : QtTdLibUserStatus { QtTdLibObjectType::USER_STATUS_RECENTLY, parent }
{ }

QtTdLibUserStatusLastWeek::QtTdLibUserStatusLastWeek (QObject * parent)
    : QtTdLibUserStatus { QtTdLibObjectType::USER_STATUS_LAST_WEEK, parent }
{ }

QtTdLibUserStatusLastMonth::QtTdLibUserStatusLastMonth (QObject * parent)
    : QtTdLibUserStatus { QtTdLibObjectType::USER_STATUS_LAST_MONTH, parent }
{ }
