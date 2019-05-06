
#include "QtTdLibJsonWrapper.h"
#include "QtTdLibEnums.h"

#include <QStringBuilder>
#include <QJsonDocument>
#include <QJsonArray>
#include <QDebug>

#include "td/telegram/td_json_client.h"

QtTdLibJsonWrapper::QtTdLibJsonWrapper (const bool debug, QObject * parent)
    : QThread              { parent }
    , m_debug              { debug }
    , m_tdJsonClientHandle { td_json_client_create () }
{
    exec (QJsonObject {
              { "@type", "setLogStream" },
              { "log_stream", QJsonObject {
                    { "@type", "logStreamDefault" },
                }
              },
          });
    exec (QJsonObject {
              { "@type", "setLogVerbosityLevel" },
              { "new_verbosity_level", (m_debug ? 2 : 0) },
          });
    const QJsonObject json =  exec (QJsonObject {
                                        { "@type", "getLogTags" },
                                    });
    const QJsonArray list = json.value ("tags").toArray ();
    for (const QJsonValue & tmp : list) {
        const QString tag { tmp.toString () };
        int level { 0 };
        if (tag == QStringLiteral ("td_init")) {
            level = (m_debug ? 2 : 0);
        }
        else if (tag == QStringLiteral ("td_requests")) {
            level = (m_debug ? 2 : 0);
        }
        else if (tag == QStringLiteral ("notifications")) {
            level = (m_debug ? 2 : 0);
        }
        else { }
        exec (QJsonObject {
                  { "@type", "setLogTagVerbosityLevel" },
                  { "tag", tag },
                  { "new_verbosity_level", level },
              });
    }
}

QtTdLibJsonWrapper::~QtTdLibJsonWrapper (void) {
    td_json_client_destroy (m_tdJsonClientHandle);
}

void QtTdLibJsonWrapper::run (void) {
    forever {
        const QByteArray tmp { td_json_client_receive (m_tdJsonClientHandle, 1) };
        if (!tmp.isEmpty ()) {
            const QJsonObject json { QJsonDocument::fromJson (tmp).object () };
            if (!json.isEmpty ()) {
                if (m_debug) {
                    qWarning () << "RECV [IN]" << json;
                }
                emit recv (json);
                if (m_debug) {
                    qWarning () << "RECV [OUT]";
                }
                if (QtTdLibEnums::objectTypeEnumFromJson (json) == QtTdLibObjectType::UPDATE_AUTHORIZATION_STATE) {
                    if (QtTdLibEnums::objectTypeEnumFromJson (json ["authorization_state"].toObject ()) == QtTdLibObjectType::AUTHORIZATION_STATE_CLOSED) {
                        break;
                    }
                }
            }
        }
    }
}

QJsonObject QtTdLibJsonWrapper::exec (const QJsonObject & json) {
    if (m_debug) {
        qWarning () << "EXEC [IN]" << json;
    }
    const QByteArray  tmp { (QJsonDocument (json).toJson (QJsonDocument::Compact) % '\0') };
    const QByteArray  str { QByteArray (td_json_client_execute (m_tdJsonClientHandle, tmp.constData ())) };
    const QJsonObject ret { QJsonDocument::fromJson (str).object () };
    if (m_debug) {
        qWarning () << "EXEC [OUT]" << ret;
    }
    return ret;
}

void QtTdLibJsonWrapper::send (const QJsonObject & json) {
    if (m_debug) {
        qWarning () << "SEND [IN]" << json;
    }
    const QByteArray tmp { (QJsonDocument (json).toJson (QJsonDocument::Compact) % '\0') };
    td_json_client_send (m_tdJsonClientHandle, tmp.constData ());
    if (m_debug) {
        qWarning () << "SEND [OUT]";
    }
}
