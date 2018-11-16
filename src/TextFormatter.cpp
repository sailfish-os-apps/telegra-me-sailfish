
#include "TextFormatter.h"

#include <QStringBuilder>

TextFormatter::TextFormatter (QObject * parent)
    : QObject        { parent }
    , m_textDocument { Q_NULLPTR }
    , m_entities     { Q_NULLPTR }
{
    connect (this, &TextFormatter::primaryColorChanged,   this, &TextFormatter::reformat);
    connect (this, &TextFormatter::secondaryColorChanged, this, &TextFormatter::reformat);
    connect (this, &TextFormatter::highlightColorChanged, this, &TextFormatter::reformat);
    connect (this, &TextFormatter::textDocumentChanged, this, [this] (void) {
        if (QTextDocument * doc = m_textDocument->textDocument ()) {
            connect (doc, &QTextDocument::contentsChange, this, &TextFormatter::reformat);
            reformat ();
        }
    });
    connect (this, &TextFormatter::entitiesChanged, this, [this] (void) {
        if (m_entities) {
            connect (m_entities, &QQmlObjectListModelBase::modelReset,   this, &TextFormatter::reformat);
            connect (m_entities, &QQmlObjectListModelBase::rowsInserted, this, &TextFormatter::reformat);
            connect (m_entities, &QQmlObjectListModelBase::rowsRemoved,  this, &TextFormatter::reformat);
            connect (m_entities, &QQmlObjectListModelBase::dataChanged,  this, &TextFormatter::reformat);
            reformat ();
        }
    });
}

void TextFormatter::reformat (void) {
    if (m_textDocument != Q_NULLPTR) {
        if (QTextDocument * doc = { m_textDocument->textDocument () }) {
#if QT_VERSION >= 0x050900
            const QString rawText { doc->toRawText () };
#else
            const QString rawText { doc->toPlainText () };
#endif
            if (!rawText.isEmpty ()) {
                if (m_entities != Q_NULLPTR) {
                    const int count { m_entities->count () };
                    for (int idx { 0 }; idx < count; ++idx) {
                        if (QtTdLibTextEntity * entity = { qobject_cast<QtTdLibTextEntity *> (m_entities->get (idx)) }) {
                            QTextCursor cursor { doc };
                            cursor.setPosition (entity->get_offset (), QTextCursor::MoveAnchor);
                            cursor.setPosition (entity->get_offset () + entity->get_length (), QTextCursor::KeepAnchor);
                            if (QtTdLibTextEntityType * entityType = { entity->get_type () }) {
                                const QString subText { rawText.mid (entity->get_offset (), entity->get_length ()) };
                                switch (entityType->get_typeOf ()) {
                                    case QtTdLibObjectType::TEXT_ENTITY_TYPE_URL: {
                                        QTextCharFormat formatChar { };
                                        formatChar.setAnchor (true);
                                        formatChar.setAnchorHref (subText);
                                        formatChar.setFontUnderline (true);
                                        formatChar.setForeground (m_highlightColor);
                                        cursor.mergeCharFormat (formatChar);
                                        break;
                                    }
                                    case QtTdLibObjectType::TEXT_ENTITY_TYPE_EMAIL_ADDRESS: {
                                        QTextCharFormat formatChar { };
                                        formatChar.setAnchor (true);
                                        formatChar.setAnchorHref ("mailto:" % subText);
                                        formatChar.setFontUnderline (true);
                                        formatChar.setForeground (m_highlightColor);
                                        cursor.mergeCharFormat (formatChar);
                                        break;
                                    }
                                    case QtTdLibObjectType::TEXT_ENTITY_TYPE_MENTION: {
                                        QTextCharFormat formatChar { };
                                        formatChar.setAnchor (true);
                                        formatChar.setAnchorHref (subText);
                                        formatChar.setForeground (m_highlightColor);
                                        cursor.mergeCharFormat (formatChar);
                                        break;
                                    }
                                    case QtTdLibObjectType::TEXT_ENTITY_TYPE_HASHTAG: {
                                        QTextCharFormat formatChar { };
                                        formatChar.setAnchor (true);
                                        formatChar.setAnchorHref (subText);
                                        formatChar.setForeground (m_highlightColor);
                                        cursor.mergeCharFormat (formatChar);
                                        break;
                                    }
                                    case QtTdLibObjectType::TEXT_ENTITY_TYPE_BOLD: {
                                        QTextCharFormat formatChar { };
                                        formatChar.setFontWeight (75);
                                        cursor.mergeCharFormat (formatChar);
                                        break;
                                    }
                                    case QtTdLibObjectType::TEXT_ENTITY_TYPE_ITALIC: {
                                        QTextCharFormat formatChar { };
                                        formatChar.setFontItalic (true);
                                        cursor.mergeCharFormat (formatChar);
                                        break;
                                    }
                                    case QtTdLibObjectType::TEXT_ENTITY_TYPE_CODE:
                                    case QtTdLibObjectType::TEXT_ENTITY_TYPE_PRE: {
                                        QTextCharFormat formatChar { };
                                        formatChar.setFontFamily ("Liberation Mono");
                                        formatChar.setFontFixedPitch (true);
                                        formatChar.setForeground (QColor ("#AAAAAA"));
                                        formatChar.setBackground (QColor ("#333333"));
                                        cursor.mergeCharFormat (formatChar);
                                        break;
                                    }
                                    case QtTdLibObjectType::TEXT_ENTITY_TYPE_PRE_CODE: {
                                        if (QtTdLibTextEntityTypePreCode * tmp = { qobject_cast<QtTdLibTextEntityTypePreCode *> (entityType) }) {
                                            QTextCharFormat formatChar { };
                                            formatChar.setFontFamily ("Liberation Mono");
                                            formatChar.setFontFixedPitch (true);
                                            formatChar.setForeground (QColor ("#AAAAAA"));
                                            formatChar.setBackground (QColor ("#333333"));
                                            cursor.mergeCharFormat (formatChar);
                                            Q_UNUSED (tmp)
                                            // TODO : highlight using tmp->get_language ()
                                        }
                                        break;
                                    }
                                    case QtTdLibObjectType::TEXT_ENTITY_TYPE_TEXT_URL: {
                                        if (QtTdLibTextEntityTypeTextUrl * tmp = { qobject_cast<QtTdLibTextEntityTypeTextUrl *> (entityType) }) {
                                            QTextCharFormat formatChar { };
                                            formatChar.setAnchor (true);
                                            formatChar.setAnchorHref (tmp->get_url ());
                                            formatChar.setFontUnderline (true);
                                            formatChar.setForeground (m_highlightColor);
                                            cursor.mergeCharFormat (formatChar);
                                        }
                                        break;
                                    }
                                    case QtTdLibObjectType::TEXT_ENTITY_TYPE_MENTION_NAME: {
                                        if (QtTdLibTextEntityTypeMentionName * tmp = { qobject_cast<QtTdLibTextEntityTypeMentionName *> (entityType) }) {
                                            QTextCharFormat formatChar { };
                                            formatChar.setAnchor (true);
                                            formatChar.setAnchorHref ("td:userid:" % QString::number (tmp->get_userId ()));
                                            formatChar.setForeground (m_highlightColor);
                                            cursor.mergeCharFormat (formatChar);
                                        }
                                        break;
                                    }
                                    default: break;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
