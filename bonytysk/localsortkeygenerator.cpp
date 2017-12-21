#include "localsortkeygenerator.h"

LocalSortKeyGenerator::LocalSortKeyGenerator()
{

}

void LocalSortKeyGenerator::addReplacePair(const QChar a_value, const QString a_replacement)
{
    m_replace_pairs.append(replace_pair(a_value, a_replacement));
}

QString LocalSortKeyGenerator::toString()
{
    QString s;
    for(replace_pair pair: m_replace_pairs){
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

QString LocalSortKeyGenerator::sortKey(const QString& input)
{
    int sortKeyLength = qMin(input.length(), maxLength());
    QString localSortKey;
    localSortKey.reserve(sortKeyLength + 1);
    for(int i = 0; i < sortKeyLength; ++i) {
        const QChar& c = input.at(i).toLower();
        if(!c.isLetter()) continue;
        bool appended = false;
        for(replace_pair pair : m_replace_pairs) {
            if(c == pair.value){
                localSortKey.append(pair.replacement);
                appended = true;
                break;
            }
        }
        if(!appended) localSortKey.append(c);
    }
    localSortKey.squeeze();
    return localSortKey;
}
