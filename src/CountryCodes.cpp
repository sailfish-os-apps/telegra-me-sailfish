
#include "CountryCodes.h"

CountryCodesModelItem::CountryCodesModelItem (const QString & country, const QString & abbr, const QString & code, QObject * parent)
    : QObject   { parent }
    , m_country { country }
    , m_abbr    { abbr }
    , m_code    { code }
{ }

CountryCodes::CountryCodes (QObject * parent)
    : QObject { parent }
    , m_list  { new QQmlObjectListModel<CountryCodesModelItem> { this } }
{
    m_list->append ({
                        new CountryCodesModelItem { "Xxxxx", "xxx", "+xx" },
                        new CountryCodesModelItem { "Xxxxx", "xxx", "+xx" },
                        new CountryCodesModelItem { "Xxxxx", "xxx", "+xx" },
                        new CountryCodesModelItem { "Xxxxx", "xxx", "+xx" },
                        new CountryCodesModelItem { "Xxxxx", "xxx", "+xx" },
                        new CountryCodesModelItem { "Xxxxx", "xxx", "+xx" },
                    });
}
