#ifndef QTTDLIBCONNECTION_H
#define QTTDLIBCONNECTION_H

#include "QtTdLibCommon.h"

class QtTdLibConnectionState : public QtTdLibAbstractObject {
    Q_OBJECT

public:
    explicit QtTdLibConnectionState (const QtTdLibObjectType::Type typeOf = QtTdLibObjectType::INVALID, QObject * parent = Q_NULLPTR);

    static QtTdLibConnectionState * createXXX (const QJsonObject & json, QObject * parent = Q_NULLPTR);
};

class QtTdLibConnectionStateWaitingForNetwork : public QtTdLibConnectionState, public FactoryNoId<QtTdLibConnectionStateWaitingForNetwork> {
    Q_OBJECT

public:
    explicit QtTdLibConnectionStateWaitingForNetwork (QObject * parent = Q_NULLPTR);
};

class QtTdLibConnectionStateConnectingToProxy : public QtTdLibConnectionState, public FactoryNoId<QtTdLibConnectionStateConnectingToProxy> {
    Q_OBJECT

public:
    explicit QtTdLibConnectionStateConnectingToProxy (QObject * parent = Q_NULLPTR);
};

class QtTdLibConnectionStateConnecting : public QtTdLibConnectionState, public FactoryNoId<QtTdLibConnectionStateConnecting> {
    Q_OBJECT

public:
    explicit QtTdLibConnectionStateConnecting (QObject * parent = Q_NULLPTR);
};

class QtTdLibConnectionStateUpdating : public QtTdLibConnectionState, public FactoryNoId<QtTdLibConnectionStateUpdating> {
    Q_OBJECT

public:
    explicit QtTdLibConnectionStateUpdating (QObject * parent = Q_NULLPTR);
};

class QtTdLibConnectionStateReady : public QtTdLibConnectionState, public FactoryNoId<QtTdLibConnectionStateReady> {
    Q_OBJECT

public:
    explicit QtTdLibConnectionStateReady (QObject * parent = Q_NULLPTR);
};

#endif // QTTDLIBCONNECTION_H
