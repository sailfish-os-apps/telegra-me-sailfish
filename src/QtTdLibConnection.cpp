
#include "QtTdLibConnection.h"

QtTdLibConnectionState::QtTdLibConnectionState (const QtTdLibObjectType::Type typeOf, QObject * parent)
    : QtTdLibAbstractObject { typeOf, parent }
{ }

QtTdLibConnectionState * QtTdLibConnectionState::createAbstract (const QJsonObject & json, QObject * parent) {
    switch (QtTdLibEnums::objectTypeEnumFromJson (json)) {
        case QtTdLibObjectType::CONNECTION_STATE_WAITING_FOR_NETWORK: return QtTdLibConnectionStateWaitingForNetwork::create (json, parent);
        case QtTdLibObjectType::CONNECTION_STATE_CONNECTING_TO_PROXY: return QtTdLibConnectionStateConnectingToProxy::create (json, parent);
        case QtTdLibObjectType::CONNECTION_STATE_CONNECTING:          return QtTdLibConnectionStateConnecting::create        (json, parent);
        case QtTdLibObjectType::CONNECTION_STATE_UPDATING:            return QtTdLibConnectionStateUpdating::create          (json, parent);
        case QtTdLibObjectType::CONNECTION_STATE_READY:               return QtTdLibConnectionStateReady::create             (json, parent);
        default: return Q_NULLPTR;
    }
}

QtTdLibConnectionStateWaitingForNetwork::QtTdLibConnectionStateWaitingForNetwork (QObject * parent)
    : QtTdLibConnectionState { QtTdLibObjectType::CONNECTION_STATE_WAITING_FOR_NETWORK, parent }
{ }

QtTdLibConnectionStateConnectingToProxy::QtTdLibConnectionStateConnectingToProxy (QObject * parent)
    : QtTdLibConnectionState { QtTdLibObjectType::CONNECTION_STATE_CONNECTING_TO_PROXY, parent }
{ }

QtTdLibConnectionStateConnecting::QtTdLibConnectionStateConnecting (QObject * parent)
    : QtTdLibConnectionState { QtTdLibObjectType::CONNECTION_STATE_CONNECTING, parent }
{ }

QtTdLibConnectionStateUpdating::QtTdLibConnectionStateUpdating (QObject * parent)
    : QtTdLibConnectionState { QtTdLibObjectType::CONNECTION_STATE_UPDATING, parent }
{ }

QtTdLibConnectionStateReady::QtTdLibConnectionStateReady (QObject * parent)
    : QtTdLibConnectionState { QtTdLibObjectType::CONNECTION_STATE_READY, parent }
{ }
