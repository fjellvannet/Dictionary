/****************************************************************************
**
** Copyright (C) 2015 The Qt Company Ltd.
** Contact: http://www.qt.io/licensing/
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/
#include "vocabularymodel.h"

const QRegularExpression WaddenseaWord::s_removeParanthesis = QRegularExpression("^\\(.*\\)\\s*");

WaddenseaWord::WaddenseaWord()
{
}

QString WaddenseaWord::word(int role) const
{
    return role < m_word.length() ? m_word.at(role) : "";
}

bool WaddenseaWord::fillFromCsvLine(QString csvLine)
{
    m_word.clear();
    QVector<QString> wordInAllLanguages = csvLine.split("\t").toVector();
    //I denne QString-Listen, som konverteres til en vektor, har ingen av strengene en høyere kapasitet enn nødvendig. Derfor er det ikke
    //nødvendig å kalle squeeze på hver eneste av strengene.

    if(wordInAllLanguages.length() == 5 || wordInAllLanguages.length() == 4)
    {
        m_word = wordInAllLanguages;
        m_word.squeeze();
        return true;
    }
    else return false;
}

VocabularyModel::VocabularyModel(QObject *parent)
    : QAbstractTableModel(parent)
{
    fillModelFromCsv(":/qt/qml/Dictionary/txt/Wadden_Sea_vocabulary.csv");
}

bool VocabularyModel::fillModelFromCsv(QString a_csvPath)
{
    QFile csv(a_csvPath);
    csv.open(QIODevice::ReadOnly | QIODevice::Text);
    qDebug().noquote() << "csv Wörterbuchdatei" << (csv.exists() ? "existiert" : "existiert nicht");
    QTextStream csvStream(&csv);
    csvStream.setEncoding(QStringConverter::Utf8);//wichtig, die Datei muss mit UTF-8 codiert sein
    QVector<WaddenseaWord> vocabulary;
    qDebug().noquote() << csvStream.readLine().replace("\t", " "); //in der ersten Zeile stehen die Sprachennamen - die sollen nicht ins Model
    while(!csvStream.atEnd())
    {
        WaddenseaWord waddenseaword;
        if(waddenseaword.fillFromCsvLine(csvStream.readLine()))
        {
            vocabulary.append(waddenseaword);
        }
        else
        {
            return false;
        }
    }
    vocabulary.squeeze();//det er nok å squeeze her - m_vocabulary har da heller ikke preallokert for mye minne.
    beginInsertRows(QModelIndex(), 0, (int)vocabulary.count() - 1);
    m_vocabulary = vocabulary;
    endInsertRows();
    return true;
}

int VocabularyModel::rowCount(const QModelIndex & parent) const {
    Q_UNUSED(parent);
    return (int)m_vocabulary.count();
}

int VocabularyModel::columnCount(const QModelIndex & parent) const
{
    Q_UNUSED(parent);
    return 5;
}

QVariant VocabularyModel::data(const QModelIndex & index, int role) const {
    if ((index.row() < 0 || index.row() >= rowCount()) || (role < -1 || role > SecDanskRole))
    {
        return QVariant();
    }
    if(role == -1)
    {
        role = index.column();
    }
    WaddenseaWord waddenseaWord = m_vocabulary[index.row()];
    if(role <= ScientificRole)
    {
        return waddenseaWord.word(role);
    }
    QChar section = waddenseaWord.word(role - 5).remove(WaddenseaWord::s_removeParanthesis).at(0).toUpper();
    if(section.isDigit()) return "0-9";
    else if(role == SecDeutschRole)
    {
        if(section == QChar(196)) return QChar('A');//ÄÖÜ durch AOU ersetzen
        else if(section == QChar(214)) return QChar('O');
        else if(section == QChar(220)) return QChar('U');
    }
    return section;
}

QVariant VocabularyModel::at(int row, int role)
{
    return(data(index(row, role), role));
}

QHash<int, QByteArray> VocabularyModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[DeutschRole      ] = "Deutsch";
    roles[EnglishRole      ] = "English";
    roles[NederlandsRole   ] = "Nederlands";
    roles[DanskRole        ] = "Dansk";
    roles[ScientificRole   ] = "Scientific";
    roles[SecDeutschRole   ] = "SecDeutsch";
    roles[SecEnglishRole   ] = "SecEnglish";
    roles[SecNederlandsRole] = "SecNederlands";
    roles[SecDanskRole     ] = "SecDansk";
    return roles;
}
