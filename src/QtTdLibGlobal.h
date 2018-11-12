#ifndef QTTDLIBGLOBAL_H
#define QTTDLIBGLOBAL_H

#include <QObject>
#include <QQmlEngine>

#include "QtTdLibCommon.h"
#include "QtTdLibJsonWrapper.h"
#include "QtTdLibConnection.h"
#include "QtTdLibAuth.h"
#include "QtTdLibUser.h"
#include "QtTdLibFile.h"
#include "QtTdLibChat.h"
#include "QtTdLibMessage.h"

#include "QmlPropertyHelpers.h"
#include "QQmlObjectListModel.h"

class QtTdLibGlobal : public QObject {
    Q_OBJECT
    Q_TDLIB_PROPERTY_SUBOBJECT (connectionState,       QtTdLibConnectionState)
    Q_TDLIB_PROPERTY_SUBOBJECT (authorizationState, QtTdLibAuthorizationState)
    QML_OBJMODEL_PROPERTY      (chatsList,                        QtTdLibChat)

public:
    explicit QtTdLibGlobal (QObject * parent = Q_NULLPTR);
    virtual ~QtTdLibGlobal (void);

    static QObject * qmlSingletonFactory (QQmlEngine * qmlEngine, QJSEngine * scriptEngine);

    Q_INVOKABLE void send (const QJsonObject & json) const;

    Q_INVOKABLE QString formatSize (const int bytes) const;

    Q_INVOKABLE QString urlFromLocalPath (const QString & path) const;

    Q_INVOKABLE QString getSvgIconForMimeType (const QString & type) const;

    Q_INVOKABLE QtTdLibFile    * getFileItemById    (const qint32 id) const;
    Q_INVOKABLE QtTdLibUser    * getUserItemById    (const qint32 id) const;
    Q_INVOKABLE QtTdLibChat    * getChatItemById    (const qint64 id) const;
    Q_INVOKABLE QtTdLibMessage * getMessageItemById (const qint64 id) const;

protected:
    void onFrame (const QJsonObject & json);

private:
    const QHash<QString, QString> m_svgIconForMimetype;

    QtTdLibJsonWrapper * m_tdLibJsonWrapper;
};

#endif // QTTDLIBGLOBAL_H
