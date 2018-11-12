#ifndef QtTdLibCommon_H
#define QtTdLibCommon_H

#include <QObject>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QHash>

#include "QmlPropertyHelpers.h"
#include "QQmlObjectListModel.h"

#include "QtTdLibEnums.h"

class QtTdLibUser;
class QtTdLibFile;
class QtTdLibChat;
class QtTdLibMessage;

struct QtTdLibId32Helper {
    static QJsonValue fromCppToJson (const qint32       arg) { return QJsonValue { int (arg) }; }
    static QString    fromCppToQml  (const qint32       arg) { return QString::number (arg); }
    static qint32     fromJsonToCpp (const QJsonValue & arg) { return qint32 (arg.toInt ()); }
    static QString    fromJsonToQml (const QJsonValue & arg) { return QString::number (arg.toInt ()); }
    static qint32     fromQmlToCpp  (const QString    & arg) { return qint32 (arg.toInt ()); }
    static QJsonValue fromQmlToJson (const QString    & arg) { return QJsonValue { int (arg.toInt ()) }; }
};

struct QtTdLibId53Helper {
    static QJsonValue fromCppToJson (const qint64       arg) { return QJsonValue { double (arg) }; }
    static QString    fromCppToQml  (const qint64       arg) { return QString::number (arg); }
    static qint64     fromJsonToCpp (const QJsonValue & arg) { return qint64 (arg.toDouble ()); }
    static QString    fromJsonToQml (const QJsonValue & arg) { return QString::number (arg.toDouble (), 'f', 0); }
    static qint64     fromQmlToCpp  (const QString    & arg) { return qint64 (arg.toLongLong ()); }
    static QJsonValue fromQmlToJson (const QString    & arg) { return QJsonValue { double (arg.toDouble ()) }; }
};

struct QtTdLibId64Helper {
    static QJsonValue fromCppToJson (const qint64       arg) { return QJsonValue { QString::number (arg) }; }
    static QString    fromCppToQml  (const qint64       arg) { return QString::number (arg); }
    static qint64     fromJsonToCpp (const QJsonValue & arg) { return qint64 (arg.toString ().toLongLong ()); }
    static QString    fromJsonToQml (const QJsonValue & arg) { return arg.toString (); }
    static qint64     fromQmlToCpp  (const QString    & arg) { return qint64 (arg.toLongLong ()); }
    static QJsonValue fromQmlToJson (const QString    & arg) { return QJsonValue { arg }; }
};

#define Q_TDLIB_PROPERTY_BOOL(NAME) \
    protected: Q_PROPERTY (bool NAME READ get_##NAME NOTIFY NAME##Changed) \
    private: bool m_##NAME { false }; \
    public: bool get_##NAME (void) const { return m_##NAME; } \
    public: QJsonValue get_##NAME##_asJSON (void) const { return QJsonValue { m_##NAME }; } \
    public: void set_##NAME##_withJSON (const QJsonValue & json) { set_##NAME (json.toBool ()); } \
    public Q_SLOTS: void set_##NAME (const bool NAME) { if (m_##NAME != NAME) { m_##NAME = NAME; Q_EMIT NAME##Changed (); } } \
    Q_SIGNALS: void NAME##Changed (void); \
    private:

#define Q_TDLIB_PROPERTY_STRING(NAME) \
    protected: Q_PROPERTY (QString NAME READ get_##NAME NOTIFY NAME##Changed) \
    private: QString m_##NAME { "" }; \
    public: const QString & get_##NAME (void) const { return m_##NAME; } \
    public: QJsonValue get_##NAME##_asJSON (void) const { return QJsonValue { m_##NAME }; } \
    public: void set_##NAME##_withJSON (const QJsonValue & json) { set_##NAME (json.toString ()); } \
    public Q_SLOTS: void set_##NAME (const QString & NAME) { if (m_##NAME != NAME) { m_##NAME = NAME; Q_EMIT NAME##Changed (); } } \
    Q_SIGNALS: void NAME##Changed (void); \
    private:

#define Q_TDLIB_PROPERTY_DOUBLE(NAME) \
    protected: Q_PROPERTY (double NAME READ get_##NAME NOTIFY NAME##Changed) \
    private: double m_##NAME { 0.0 }; \
    public: double get_##NAME (void) const { return m_##NAME; } \
    public: QJsonValue get_##NAME##_asJSON (void) const { return QJsonValue { m_##NAME }; } \
    public: void set_##NAME##_withJSON (const QJsonValue & json) { set_##NAME (json.toDouble ()); } \
    public Q_SLOTS: void set_##NAME (const double NAME) { if (m_##NAME != NAME) { m_##NAME = NAME; Q_EMIT NAME##Changed (); } } \
    Q_SIGNALS: void NAME##Changed (void); \
    private:

#define Q_TDLIB_PROPERTY_INT32(NAME) \
    protected: Q_PROPERTY (int NAME READ get_##NAME##_forQML NOTIFY NAME##Changed) \
    private: qint32 m_##NAME { 0 }; \
    public: qint32 get_##NAME (void) const { return m_##NAME; } \
    public: int get_##NAME##_forQML (void) const { return m_##NAME; } \
    public: QJsonValue get_##NAME##_asJSON (void) const { return QJsonValue { m_##NAME }; } \
    public: void set_##NAME##_withJSON (const QJsonValue & json) { set_##NAME (json.toInt ()); } \
    public Q_SLOTS: void set_##NAME (const qint32 NAME) { if (m_##NAME != NAME) { m_##NAME = NAME; Q_EMIT NAME##Changed (); } } \
    Q_SIGNALS: void NAME##Changed (void); \
    private:

#define Q_TDLIB_PROPERTY_ID32(NAME) \
    protected: Q_PROPERTY (QString NAME READ get_##NAME##_forQML NOTIFY NAME##Changed) \
    private: qint32 m_##NAME { 0 }; \
    public: qint32 get_##NAME (void) const { return m_##NAME; } \
    public: QString get_##NAME##_forQML (void) const { return QtTdLibId32Helper::fromCppToQml (m_##NAME); } \
    public: QJsonValue get_##NAME##_asJSON (void) const { return QtTdLibId32Helper::fromCppToJson (m_##NAME); } \
    public: void set_##NAME##_withJSON (const QJsonValue & json) { set_##NAME (QtTdLibId32Helper::fromJsonToCpp (json)); } \
    public Q_SLOTS: void set_##NAME (const qint32 NAME) { if (m_##NAME != NAME) { m_##NAME = NAME; Q_EMIT NAME##Changed (); } } \
    Q_SIGNALS: void NAME##Changed (void); \
    private:

#define Q_TDLIB_PROPERTY_ID53(NAME) \
    protected: Q_PROPERTY (QString NAME READ get_##NAME##_forQML NOTIFY NAME##Changed) \
    private: qint64 m_##NAME { 0 }; \
    public: qint64 get_##NAME (void) const { return m_##NAME; } \
    public: QString get_##NAME##_forQML (void) const { return QtTdLibId53Helper::fromCppToQml (m_##NAME); } \
    public: QJsonValue get_##NAME##_asJSON (void) const { return QtTdLibId53Helper::fromCppToJson (m_##NAME); } \
    public: void set_##NAME##_withJSON (const QJsonValue & json) { set_##NAME (QtTdLibId53Helper::fromJsonToCpp (json)); } \
    public Q_SLOTS: void set_##NAME (const qint64 NAME) { if (m_##NAME != NAME) { m_##NAME = NAME; Q_EMIT NAME##Changed (); } } \
    Q_SIGNALS: void NAME##Changed (void); \
    private:

#define Q_TDLIB_PROPERTY_ID64(NAME) \
    protected: Q_PROPERTY (QString NAME READ get_##NAME##_forQML NOTIFY NAME##Changed) \
    private: qint64 m_##NAME { 0 }; \
    public: qint64 get_##NAME (void) const { return m_##NAME; } \
    public: QString get_##NAME##_forQML (void) const { return QtTdLibId64Helper::fromCppToQml (m_##NAME); } \
    public: QJsonValue get_##NAME##_asJSON (void) const { return QtTdLibId64Helper::fromCppToJson (m_##NAME); } \
    public: void set_##NAME##_withJSON (const QJsonValue & json) { set_##NAME (QtTdLibId64Helper::fromJsonToCpp (json)); } \
    public Q_SLOTS: void set_##NAME (const qint64 NAME) { if (m_##NAME != NAME) { m_##NAME = NAME; Q_EMIT NAME##Changed (); } } \
    Q_SIGNALS: void NAME##Changed (void); \
    private:

#define Q_TDLIB_PROPERTY_SUBOBJECT(NAME,TYPE) \
    protected: Q_PROPERTY (TYPE * NAME READ get_##NAME NOTIFY NAME##Changed) \
    private: TYPE * m_##NAME { Q_NULLPTR }; \
    public: TYPE * get_##NAME (void) { return m_##NAME; } \
    public Q_SLOTS: void set_##NAME (TYPE * NAME) { if (m_##NAME != NAME) { m_##NAME = NAME; Q_EMIT NAME##Changed (); } } \
    public: template<class T> void set_##NAME##_withJSON (const QJsonValue & json, T * (* factory) (const QJsonObject &, QObject *)) { \
        const QJsonObject object { json.toObject () }; \
        if (m_##NAME != Q_NULLPTR && !m_##NAME->isCompatibleWith (object)) { \
            if (!QtTdLibCollection::IsCollectable<T>::VALUE) { \
                m_##NAME->deleteLater (); \
            } \
            set_##NAME (Q_NULLPTR); \
        } \
        if (m_##NAME == Q_NULLPTR && !object ["@type"].toString ().isEmpty ()) { \
            set_##NAME (factory (object, (!QtTdLibCollection::IsCollectable<T>::VALUE ? this : Q_NULLPTR))); \
        } \
        if (m_##NAME != Q_NULLPTR) { \
            m_##NAME->updateFromJson (object); \
        } \
    } \
    Q_SIGNALS: void NAME##Changed (void); \
    private:


class QtTdLibAbstractObject : public QObject {
    Q_OBJECT
    QML_CONSTANT_VAR_PROPERTY (typeOf, int)

public:
    explicit QtTdLibAbstractObject (const QtTdLibObjectType::Type typeOf = QtTdLibObjectType::INVALID, QObject * parent = Q_NULLPTR);

    virtual void updateFromJson   (const QJsonObject & json) { Q_UNUSED (json) }
    virtual bool isCompatibleWith (const QJsonObject & json) {
        return (QtTdLibEnums::objectTypeEnumFromJson (json) == m_typeOf);
    }

    template<class T> static T * create (const QJsonObject & json, QObject * parent) { Q_UNUSED (json); return new T { parent }; }
};

class QtTdLibAbstractInt32IdObject : public QtTdLibAbstractObject {
    Q_OBJECT
    Q_TDLIB_PROPERTY_ID32 (id)

public:
    explicit QtTdLibAbstractInt32IdObject (const QtTdLibObjectType::Type typeOf = QtTdLibObjectType::INVALID, const qint32 id = 0, QObject * parent = Q_NULLPTR);

    bool isCompatibleWith (const QJsonObject & json) Q_DECL_FINAL {
        return (QtTdLibAbstractObject::isCompatibleWith (json) && QtTdLibId32Helper::fromJsonToCpp (json ["id"]) == m_id);
    }

    template<class T> static T * create (const QJsonObject & json, QObject * parent) { return new T { QtTdLibId32Helper::fromJsonToCpp (json ["id"]), parent }; }
};

class QtTdLibAbstractInt53IdObject : public QtTdLibAbstractObject {
    Q_OBJECT
    Q_TDLIB_PROPERTY_ID53 (id)

public:
    explicit QtTdLibAbstractInt53IdObject (const QtTdLibObjectType::Type typeOf = QtTdLibObjectType::INVALID, const qint64 id = 0, QObject * parent = Q_NULLPTR);

    bool isCompatibleWith (const QJsonObject & json) Q_DECL_FINAL {
        return (QtTdLibAbstractObject::isCompatibleWith (json) && QtTdLibId53Helper::fromJsonToCpp (json ["id"]) == m_id);
    }

    template<class T> static T * create (const QJsonObject & json, QObject * parent) { return new T { QtTdLibId53Helper::fromJsonToCpp (json ["id"]), parent }; }
};

class QtTdLibAbstractInt64IdObject : public QtTdLibAbstractObject {
    Q_OBJECT
    Q_TDLIB_PROPERTY_ID64 (id)

public:
    explicit QtTdLibAbstractInt64IdObject (const QtTdLibObjectType::Type typeOf = QtTdLibObjectType::INVALID, const qint64 id = 0, QObject * parent = Q_NULLPTR);

    bool isCompatibleWith (const QJsonObject & json) Q_DECL_FINAL {
        return (QtTdLibAbstractObject::isCompatibleWith (json) && QtTdLibId64Helper::fromJsonToCpp (json ["id"]) == m_id);
    }

    template<class T> static T * create (const QJsonObject & json, QObject * parent) { return new T { QtTdLibId64Helper::fromJsonToCpp (json ["id"]), parent }; }
};

class QtTdLibAbstractStrIdObject : public QtTdLibAbstractObject {
    Q_OBJECT
    QML_CONSTANT_CSTREF_PROPERTY (id, QString)

public:
    explicit QtTdLibAbstractStrIdObject (const QtTdLibObjectType::Type typeOf = QtTdLibObjectType::INVALID, const QString & id = "", QObject * parent = Q_NULLPTR);

    bool isCompatibleWith (const QJsonObject & json) Q_DECL_FINAL {
        return (QtTdLibAbstractObject::isCompatibleWith (json) && json ["id"].toString () == m_id);
    }

    template<class T> static T * create (const QJsonObject & json, QObject * parent) { return new T { json ["id"].toString (), parent }; }
};

namespace QtTdLibCollection {

template<class T> struct IsCollectable                 { static constexpr bool VALUE { false }; };
template<>        struct IsCollectable<QtTdLibUser>    { static constexpr bool VALUE { true }; };
template<>        struct IsCollectable<QtTdLibFile>    { static constexpr bool VALUE { true }; };
template<>        struct IsCollectable<QtTdLibChat>    { static constexpr bool VALUE { true }; };
template<>        struct IsCollectable<QtTdLibMessage> { static constexpr bool VALUE { true }; };

extern QHash<qint32, QtTdLibUser *>    allUsers;
extern QHash<qint32, QtTdLibFile *>    allFiles;
extern QHash<qint64, QtTdLibChat *>    allChats;
extern QHash<qint64, QtTdLibMessage *> allMessages;

}

#endif // QtTdLibCommon_H
