
#include "QtTdLibCommon.h"

#include "QtTdLibFile.h"
#include "QtTdLibUser.h"
#include "QtTdLibChat.h"
#include "QtTdLibMessage.h"

QHash<qint32, QtTdLibUser *>    QtTdLibCollection::allUsers { };
QHash<qint32, QtTdLibFile *>    QtTdLibCollection::allFiles { };
QHash<qint64, QtTdLibChat *>    QtTdLibCollection::allChats { };
QHash<qint64, QtTdLibMessage *> QtTdLibCollection::allMessages { };

QtTdLibAbstractObject::QtTdLibAbstractObject (const QtTdLibObjectType::Type typeOf, QObject * parent)
    : QObject  { parent }
    , m_typeOf { typeOf }
{ }

QtTdLibAbstractInt32IdObject::QtTdLibAbstractInt32IdObject (const QtTdLibObjectType::Type typeOf, const qint32 id, QObject * parent)
    : QtTdLibAbstractObject { typeOf, parent }
    , m_id { id }
{ }

QtTdLibAbstractInt53IdObject::QtTdLibAbstractInt53IdObject (const QtTdLibObjectType::Type typeOf, const qint64 id, QObject * parent)
    : QtTdLibAbstractObject  { typeOf, parent }
    , m_id { id }
{ }

QtTdLibAbstractInt64IdObject::QtTdLibAbstractInt64IdObject (const QtTdLibObjectType::Type typeOf, const qint64 id, QObject * parent)
    : QtTdLibAbstractObject  { typeOf, parent }
    , m_id { id }
{ }

QtTdLibAbstractStrIdObject::QtTdLibAbstractStrIdObject (const QtTdLibObjectType::Type typeOf, const QString & id, QObject * parent)
    : QtTdLibAbstractObject  { typeOf, parent }
    , m_id { id }
{ }
