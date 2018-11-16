#ifndef TEXTFORMATTER_H
#define TEXTFORMATTER_H

#include <QObject>
#include <QColor>
#include <QTextDocument>
#include <QTextBlock>
#include <QTextCursor>
#include <QTextBlockFormat>
#include <QTextCharFormat>
#include <QQuickTextDocument>

#include "QtTdLibContent.h"

#include "QmlPropertyHelpers.h"

class TextFormatter : public QObject {
    Q_OBJECT
    QML_WRITABLE_PTR_PROPERTY    (textDocument,      QQuickTextDocument)
    QML_WRITABLE_PTR_PROPERTY    (entities,     QQmlObjectListModelBase)
    QML_WRITABLE_CSTREF_PROPERTY (primaryColor,                  QColor)
    QML_WRITABLE_CSTREF_PROPERTY (secondaryColor,                QColor)
    QML_WRITABLE_CSTREF_PROPERTY (highlightColor,                QColor)

public:
    explicit TextFormatter (QObject * parent = Q_NULLPTR);

    Q_INVOKABLE void reformat (void);
};

#endif // TEXTFORMATTER_H
