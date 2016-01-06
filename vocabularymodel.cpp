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

#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QTextCodec>

WaddenseaWord::WaddenseaWord()
{
}

QString WaddenseaWord::word(int role)
{
    return at(role);
}

bool WaddenseaWord::fillFromCsvLine(QString csvLine)
{
    QStringList wordInAllLanguages = csvLine.split("\";\"");
    if(wordInAllLanguages.count() == 5)
    {
        wordInAllLanguages[3] = wordInAllLanguages[3];
        wordInAllLanguages[4] = wordInAllLanguages[4].remove(QRegExp("(\"?;*)$"));//die letzten " und gegebenenfalls folgende ; wegschneiden
    }
    else if(wordInAllLanguages.count() == 4)
    {
        wordInAllLanguages[3] = wordInAllLanguages[3].remove(QRegExp("(\"?;*)$")); //die letzten " und gegebenenfalls folgende ; wegschneiden
        wordInAllLanguages.append("");
    }
    else
    {
        return false;
    }
    wordInAllLanguages[0] = wordInAllLanguages[0].mid(1); //vordersten " wegschneiden
    clear();
    append(wordInAllLanguages);
    return true;
}

VocabularyModel::VocabularyModel(QObject *parent)
    : QAbstractTableModel(parent)
{
}

bool VocabularyModel::fillModelFromCsv(QString csvPath)
{
    QFile file(csvPath);
    file.open(QIODevice::ReadOnly | QIODevice::Text);
    qDebug() << "csv Wörterbuchdatei " << (file.exists() ? "existiert" : "existiert nicht");
    QTextStream csvStream(&file);
    csvStream.setCodec(QTextCodec::codecForName("UTF-8"));//wichtig, die Datei muss mit UTF-8 codiert sein
    QList<WaddenseaWord> vocabulary;
    qDebug() << csvStream.readLine(); //in der ersten Zeile stehen die Sprachennamen - die sollen nicht ins Model
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
    beginInsertRows(QModelIndex(), 0, vocabulary.count() - 1);
    m_vocabulary = vocabulary;
    endInsertRows();
    return true;
}

int VocabularyModel::rowCount(const QModelIndex & parent) const {
    Q_UNUSED(parent);
    return m_vocabulary.count();
}

int VocabularyModel::columnCount(const QModelIndex & parent) const
{
    Q_UNUSED(parent);
    return 5;
}

QVariant VocabularyModel::data(const QModelIndex & index, int role) const {
    if ((index.row() < 0 || index.row() >= m_vocabulary.count()) && (role >= 0 && role <= ScientificRole))
        return QVariant();
    WaddenseaWord waddenseaWord = m_vocabulary[index.row()];
    return waddenseaWord.word(role);
}

QHash<int, QByteArray> VocabularyModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[DeutschRole   ] = "Deutsch";
    roles[EnglishRole   ] = "English";
    roles[NederlandsRole] = "Nederlands";
    roles[DanskRole     ] = "Dansk";
    roles[ScientificRole] = "Scientific";
    return roles;
}
