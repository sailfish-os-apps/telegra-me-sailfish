#ifndef QTTDLIBJSONWRAPPER_H
#define QTTDLIBJSONWRAPPER_H

#include <QObject>
#include <QJsonObject>
#include <QThread>

class QtTdLibJsonWrapper : public QThread {
    Q_OBJECT

public:
    explicit QtTdLibJsonWrapper (const bool debug, QObject * parent = Q_NULLPTR);
    virtual ~QtTdLibJsonWrapper (void);

    Q_INVOKABLE QJsonObject exec (const QJsonObject & json);

public slots:
    void send (const QJsonObject & json);

signals:
    void recv (const QJsonObject & json);

protected:
    void run (void) Q_DECL_FINAL;

private:
    const bool m_debug;
    void * m_tdJsonClientHandle;
};

#endif // QTTDLIBJSONWRAPPER_H
