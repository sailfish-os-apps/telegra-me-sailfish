
#include "QtTdLibConnection.h"

QtTdLibConnectionState::QtTdLibConnectionState (const QtTdLibObjectType::Type typeOf, QObject * parent)
    : QtTdLibAbstractObject { typeOf, parent }
{ }

QtTdLibConnectionState * QtTdLibConnectionState::create (const QJsonObject & json, QObject * parent) {
    switch (QtTdLibEnums::objectTypeEnumFromJson (json)) {
        case QtTdLibObjectType::CONNECTION_STATE_WAITING_FOR_NETWORK: return new QtTdLibConnectionStateWaitingForNetwork { parent };
        case QtTdLibObjectType::CONNECTION_STATE_CONNECTING_TO_PROXY: return new QtTdLibConnectionStateConnectingToProxy { parent };
        case QtTdLibObjectType::CONNECTION_STATE_CONNECTING:          return new QtTdLibConnectionStateConnecting        { parent };
        case QtTdLibObjectType::CONNECTION_STATE_UPDATING:            return new QtTdLibConnectionStateUpdating          { parent };
        case QtTdLibObjectType::CONNECTION_STATE_READY:               return new QtTdLibConnectionStateReady             { parent };
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
