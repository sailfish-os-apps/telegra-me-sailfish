#ifndef COUNTRYCODES_H
#define COUNTRYCODES_H

#include <QObject>

#include "QmlPropertyHelpers.h"
#include "QQmlObjectListModel.h"

class CountryCodesModelItem : public QObject {
    Q_OBJECT
    QML_CONSTANT_CSTREF_PROPERTY (name, QString)
    QML_CONSTANT_CSTREF_PROPERTY (flag, QString)
    QML_CONSTANT_CSTREF_PROPERTY (code, QString)

public:
    explicit CountryCodesModelItem (const QString & name = { },
                                    const QString & flag = { },
                                    const QString & code = { },
                                    QObject * parent = nullptr);

    Q_INVOKABLE bool match (const QString & filter) const;
};

class CountryCodes : public QObject {
    Q_OBJECT
    QML_OBJMODEL_PROPERTY (list, CountryCodesModelItem)

public:
    explicit CountryCodes (QObject * parent = nullptr);
};

#endif // COUNTRYCODES_H
