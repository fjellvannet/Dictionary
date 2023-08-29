#include "localsortkeygenerator.h"

LocalSortKeyGenerator::LocalSortKeyGenerator()
{

}

void LocalSortKeyGenerator::addReplacePair(const QChar a_value, const QString a_replacement)
{
    m_replace_pairs.append(ReplacePair(a_value, a_replacement));
}

QString LocalSortKeyGenerator::toString()
{
    QString s;
    for(ReplacePair pair: m_replace_pairs){
        s.append(pair.toString());
    }
    return s;
}

/**
 * @brief LocalSortKeyGenerator::setMaxLength, sets the maximum length the sorting key is supposed to have (fx 5 chars)
 * @param a_maxLength if you want to reset this value to infinity (which is the default), pass 0 as argument
 */
void LocalSortKeyGenerator::setMaxLength(int a_maxLength)
{
    if(a_maxLength == 0) a_maxLength = INT_MAX;
    m_maxLength = a_maxLength;
}

int LocalSortKeyGenerator::maxLength()
{
    return m_maxLength;
}

QPair<QString, QChar> LocalSortKeyGenerator::sortKey(const QString& input)
{
    int sortKeyLength = qMin(input.length(), maxLength());
    QString localSortKey;
    QChar sectionLetter = QChar();
    localSortKey.reserve(sortKeyLength + 1);
    for(int i = 0; qMax(localSortKey.length(), i) < sortKeyLength; ++i) {
        QChar c = input.at(i).toLower();
        if(i == 0 && c == '(') {
            i = input.indexOf(')');
            continue;
        }
        if(!(c.isLetter() || (sectionLetter != QChar() && c == ' '))) continue;
        if(c != QString("å").at(0)) {
            c = QString(c).normalized(QString::NormalizationForm_D).at(0);
        }
        bool appended = false;
        if(sectionLetter == QChar())
        {
            sectionLetter = c.toUpper();
        }
        for(ReplacePair pair : m_replace_pairs) {
            if(c == pair.value){
                localSortKey.append(pair.replacement);
                appended = true;
                break;
            }
        }
        if(!appended) localSortKey.append(c);
    }
    localSortKey.squeeze();
    return QPair<QString, QChar>(localSortKey, sectionLetter);
}
