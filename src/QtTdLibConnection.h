#ifndef QTTDLIBCONNECTION_H
#define QTTDLIBCONNECTION_H

#include "QtTdLibCommon.h"

class QtTdLibConnectionState : public QtTdLibAbstractObject {
    Q_OBJECT

public:
    explicit QtTdLibConnectionState (const QtTdLibObjectType::Type typeOf = QtTdLibObjectType::INVALID, QObject * parent = Q_NULLPTR);

    static QtTdLibConnectionState * create (const QJsonObject & json, QObject * parent);
};

class QtTdLibConnectionStateWaitingForNetwork : public QtTdLibConnectionState {
    Q_OBJECT

public:
    explicit QtTdLibConnectionStateWaitingForNetwork (QObject * parent = Q_NULLPTR);
};

class QtTdLibConnectionStateConnectingToProxy : public QtTdLibConnectionState {
    Q_OBJECT

public:
    explicit QtTdLibConnectionStateConnectingToProxy (QObject * parent = Q_NULLPTR);
};

class QtTdLibConnectionStateConnecting : public QtTdLibConnectionState {
    Q_OBJECT

public:
    explicit QtTdLibConnectionStateConnecting (QObject * parent = Q_NULLPTR);
};

class QtTdLibConnectionStateUpdating : public QtTdLibConnectionState {
    Q_OBJECT

public:
    explicit QtTdLibConnectionStateUpdating (QObject * parent = Q_NULLPTR);
};

class QtTdLibConnectionStateReady : public QtTdLibConnectionState {
    Q_OBJECT

public:
    explicit QtTdLibConnectionStateReady (QObject * parent = Q_NULLPTR);
};

#endif // QTTDLIBCONNECTION_H
