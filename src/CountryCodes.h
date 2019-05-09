#ifndef COUNTRYCODES_H
#define COUNTRYCODES_H

#include <QObject>

#include "QmlPropertyHelpers.h"
#include "QQmlObjectListModel.h"

class CountryCodesModelItem : public QObject {
    Q_OBJECT
    QML_CONSTANT_CSTREF_PROPERTY (country, QString)
    QML_CONSTANT_CSTREF_PROPERTY (abbr,    QString)
    QML_CONSTANT_CSTREF_PROPERTY (code,    QString)

public:
    explicit CountryCodesModelItem (const QString & country = { },
                                    const QString & abbr    = { },
                                    const QString & code    = { },
                                    QObject * parent = nullptr);
};

class CountryCodes : public QObject {
    Q_OBJECT
    QML_OBJMODEL_PROPERTY (list, CountryCodesModelItem)

public:
    explicit CountryCodes (QObject * parent = nullptr);
};

#endif // COUNTRYCODES_H
