#include "databasemanager.h"
#include "localsortkeygenerator.h"

DatabaseManager::DatabaseManager() {

}

QString DatabaseManager::downloadToString() {
  QNetworkAccessManager manager;
  if (!manager.networkAccessible()) throw "Network is not available";
  else if (!QSslSocket::supportsSsl()) throw "SSL libraries are not available";

  QNetworkReply* reply = manager.get(QNetworkRequest(DOWNLOAD_LINK));
  QEventLoop sleeper;
  QObject::connect(reply, &QNetworkReply::finished, &sleeper, &QEventLoop::quit);
  sleeper.exec();
  for(auto x : reply->rawHeaderPairs()) {
    qDebug() << x.first << x.second;
  }

  if (reply->error()) throw reply->errorString();
  return reply->readAll();
}

void DatabaseManager::openDatabaseConnection() {
  if (!DATABASE_FILE.exists()) {
    copyOrReplaceDatabaseFile(false);
  }
  if (!connectDatabase()) {
    copyOrReplaceDatabaseFile(true);
  }
}

bool DatabaseManager::connectDatabase() {
  QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
  db.setDatabaseName(DATABASE_FILE.absoluteFilePath());
  if (!db.open()) {
    qCritical().noquote() << db.lastError().text();
    return false;
  } else {
    qDebug().noquote() << "Successfully connected to database.";
    return true;
  }
}

bool DatabaseManager::copyOrReplaceDatabaseFile(bool overwrite) {
  qDebug() << DATABASE_FILE.absolutePath();
  if(QDir().mkpath(DATABASE_FILE.absolutePath())) {
    QFile f(DATABASE_FILE.absoluteFilePath());
    f.setPermissions(QFile::ReadOther | QFile::WriteOther);
    if (DATABASE_FILE.exists() && overwrite) { //remove existing database-file - copy doesn't overwrite
      if(!f.remove()) qWarning() << "Could not delete old database.";
    }
    if(QFile(":/database/buchmaal-database.sqlite").copy(DATABASE_FILE.absoluteFilePath())) {
      qDebug().noquote() << "Successfully copied database-file.";
      return true;
    } else {
      qWarning().noquote() << "Could not copy current version of database - check file permissions.";
    }
  } else {
    qCritical().noquote() << "The AppData-Directory for updating the database could not be created, operation aborted.";
  }
  return false;
}

bool DatabaseManager::updateWordList(bool skipHashCheck) {
  try {
    QString updatedWordListString = getUpdatedWordlist();
    QDateTime newDownloadTime = QDateTime::currentDateTime();
    QByteArray wordListSha512 = QCryptographicHash::hash(updatedWordListString.toUtf8(), QCryptographicHash::Sha512);
    if (directQuery(SQL_TABLES_EXISTING, ERROR_TABLES_NOT_CREATED) != MSG_TABLES_EXIST) {
      createTableStructure();
      skipHashCheck = true; // the new tables are empty - no need to check
    }
    if(!skipHashCheck) {
      QVariantList wordListInfo = directQuery(SQL_SELECT_WORDLIST_INFO).toList();
      if (wordListInfo.at(1) == updatedWordListString.length() && wordListInfo.at(2) == wordListSha512) {
        qDebug() << "The database is already up to date.";
        updateWordListInfo(&newDownloadTime);
        return true;
      }
    }
    QSet<QString> currentWordSet = getCurrentWordSet();
    QStringList updatedWordList = prepareRawWordList(&updatedWordListString);
    QSet<QString> updatedWordSet(updatedWordList.begin(), updatedWordList.end());

    QSet<QString> wordsToAdd = updatedWordSet.subtract(currentWordSet);
    insertNewWords(&wordsToAdd);

    updatedWordSet = QSet<QString>(updatedWordList.begin(), updatedWordList.end());
    QSet<QString> wordsToRemove = currentWordSet.subtract(updatedWordSet);
    deleteRemovedWords(&wordsToRemove);

    updateWordListInfo(&newDownloadTime, updatedWordListString.length(), &wordListSha512);
    qDebug() << "The database has been updated successfully.";
    return true;
  } catch (const char* s) {
    qWarning().noquote() << s << "Aborting updating wordlist.";
  } catch (QString s) {
    qWarning().noquote() << s << "Aborting updating wordlist.";
  }
  return false;
}

bool DatabaseManager::deleteRemovedWords(QSet<QString>* wordsToRemove) {
  QVector<QVector<QStringRef>> removeWords;
  splitWordLines(&removeWords, wordsToRemove);
  QSqlQuery query(QString("DELETE FROM WORDLIST WHERE %1=?").arg(WORDLIST_COLUMNS.mid(0, 9).join("=? AND ")));

  QElapsedTimer speed;
  speed.start();
  for(int i = 0; i < removeWords.length(); i += BATCHSIZE) { // går gjennom batchpakker
    int batchStarted = speed.elapsed();
    bool lastUncopleteBatch = (i + BATCHSIZE) > removeWords.length();
    QVariantList no_batch_words, de_batch_words;
    for(int j = 0; j < WORDLIST_COLUMNS.length() - 4; j++) { //går gjennom kolonner
      QVariantList currentColumnValues;
      for(int k = 0; k < BATCHSIZE; k++) { //går gjennom linjer i batchpakka
        if(lastUncopleteBatch && (k + i) >= removeWords.length()) break;
        QVector<QStringRef>* currentRowValues = &removeWords[k + i];
        if(currentRowValues->length() <= j) {
          currentColumnValues.append(QVariant());
        } else { // då må den være større eller lik j, så det må finnes en verdi
          currentColumnValues.append(currentRowValues->at(j).toString());
        }
      }
      query.addBindValue(currentColumnValues);
    }
    if (!query.execBatch()) throw QString("Couldn't remove updated words from database " % query.lastError().text());
    qDebug().noquote() << QTime(0, 0, 0, 0).addMSecs(speed.elapsed()).toString("mm:ss")
                       << "Deleting updated words, executed Batch"
                       << QString::number(i / BATCHSIZE + 1) + ", which took"
                       << QTime(0, 0, 0, 0).addMSecs(speed.elapsed() - batchStarted).toString("mm:ss:zzz");
  }
  return true;
}

QSet<QString> DatabaseManager::getCurrentWordSet() {
  QSqlQuery query;
  query.setForwardOnly(true);
  QSet<QString> currentWordList;
  currentWordList.reserve(50000);
  bool success = query.exec(SQL_SELECT_WORDLIST.arg(WORDLIST_COLUMNS.mid(0, 9).join(", ")));
  if (success) {
    query.first();
    while (query.isValid()) {
      QString line;
      line += query.value(0).toString();
      for (int i = 1; i < 9; ++i) {
        line += QString('\t' % query.value(i).toString());
      }
      currentWordList.insert(line);
      query.next();
    }
  } else throw QString("Couldn't retrieve data from wordlist-table. " % query.lastError().text());
  return currentWordList;
}

bool DatabaseManager::updateWordListInfo(QDateTime* lastUpdatedTimestamp, int length, QByteArray* sha512Hash) {
  QSqlQuery query;
  if (sha512Hash == nullptr) {
    query.prepare(SQL_UPDATE_INFO.arg(QString(WORDLIST_INFO_COLUMNS.at(0) % "=?")));
  } else {
    query.prepare(SQL_UPDATE_INFO.arg(QString(WORDLIST_INFO_COLUMNS.join("=?, ") % "=?")));
    query.bindValue(1, length);
    query.bindValue(2, *sha512Hash);
  }
  query.bindValue(0, *lastUpdatedTimestamp);
  bool success = query.exec();
  if (!success) throw QString("Couldn't update wordlist-information in database. " % query.lastError().text());
  return success;
}

QVariant DatabaseManager::directQuery(QString sqlSelect, QString errorMessage) {
  QSqlQuery query;
  if(!QRegularExpression("^SELECT .*? FROM .", QRegularExpression::CaseInsensitiveOption).match(sqlSelect).hasMatch()) {
    throw "The query is no SELECT-SQL-clause";
  }
  if(!query.exec(sqlSelect)) throw QString(errorMessage % ' ' % query.lastError().text());
  query.first();
  QList<QVariant> results;
  int i = 0;
  QVariant currentResult = query.value(i);
  while (currentResult.isValid()) {
    results.append(currentResult);
    currentResult = query.value(++i);
  }
  return i <= 1 ? results.last() : results;
}

bool DatabaseManager::insertNewWords(QSet<QString>* wordsToAdd) {
  LocalSortKeyGenerator generator_no, generator_de;
  generator_de.addReplacePair(QString("ß").at(0), "ss");
  generator_no.addReplacePair(QString("æ").at(0), "Å");
  generator_no.addReplacePair(QString("ø").at(0), "Æ");
  generator_no.addReplacePair(QString("å").at(0), "Ø");

  QString placeholders = QString(QString("?, ").repeated(WORDLIST_COLUMNS.length() - 1) % '?');
  QSqlQuery query(QString("INSERT INTO WORDLIST (%1) VALUES(%2)").arg(WORDLIST_COLUMNS.join(", ")).arg(placeholders));

  QElapsedTimer speed;
  speed.start();
  QVector<QVector<QStringRef>> insertWords;
  splitWordLines(&insertWords, wordsToAdd);
  bool lastUncopleteBatch;

  for(int i = 0; i < insertWords.length(); i += BATCHSIZE) { // går gjennom batchpakker
    int batchStarted = speed.elapsed();
    lastUncopleteBatch = (i + BATCHSIZE) > insertWords.length();
    QVariantList no_batch_words, de_batch_words;
    for(int j = 0; j < WORDLIST_COLUMNS.length() - 4; j++) { //går gjennom kolonner
      QVariantList currentColumnValues;
      for(int k = 0; k < BATCHSIZE; k++) { //går gjennom linjer i batchpakka
        if(lastUncopleteBatch && (k + i) >= insertWords.length()) break;
        QVector<QStringRef>* currentRowValues = &insertWords[k + i];
        if(currentRowValues->length() <= j) {
          currentColumnValues.append(QVariant());
        } else { // då må den være større eller lik j, så det må finnes en verdi
          currentColumnValues.append(currentRowValues->at(j).toString());
        }
      }
      if(j == 0) no_batch_words = currentColumnValues;
      else if(j == 4) de_batch_words = currentColumnValues;
      query.addBindValue(currentColumnValues);
    }
    QVariantList NO_sort, NO_sect, DE_sort, DE_sect;
    for(QVariant no_word : no_batch_words) {
      QPair<QString, QChar> no_sort = generator_no.sortKey(no_word.toString());
      NO_sort << no_sort.first;
      NO_sect << no_sort.second;
    }
    for(QVariant de_word : de_batch_words) {
      QPair<QString, QChar> de_sort = generator_de.sortKey(de_word.toString());
      DE_sort << de_sort.first;
      DE_sect << de_sort.second;
    }
    query.addBindValue(NO_sort);
    query.addBindValue(NO_sect);
    query.addBindValue(DE_sort);
    query.addBindValue(DE_sect);
    if (!query.execBatch()) throw QString("Couldn't insert new words into database " % query.lastError().text());
    if (!lastUncopleteBatch) {
      qDebug().noquote() << QTime(0, 0, 0, 0).addMSecs(speed.elapsed()).toString("mm:ss")
                         << "Inserting new words, executed Batch"
                         << QString::number(i / BATCHSIZE + 1) + ", which took"
                         << QTime(0, 0, 0, 0).addMSecs(speed.elapsed() - batchStarted).toString("mm:ss:zzz");
    }
  }
  return true;
}

bool DatabaseManager::splitWordLines(QVector<QVector<QStringRef>>* result, QSet<QString>* wordLines) {
  result->reserve(wordLines->size());
  for (QSet<QString>::iterator wordLine = wordLines->begin(); wordLine != wordLines->end(); ++wordLine) {
    result->append(wordLine->splitRef("\t"));
  }
  return true;
}

QStringList DatabaseManager::prepareRawWordList(QString* rawWordList) {
  return rawWordList->replace("\\\"", "\"").left(rawWordList->lastIndexOf("\\t\\n"""))
         .midRef(rawWordList->indexOf("HeinzelSearch.Config.hndb = [""") + 30).toString()
         .replace("\\t", "\t").split("\t\\n");
}

bool DatabaseManager::createTableStructure() {
  qDebug().noquote() << "Table structure has not been initialized, creating table structure.";
  QSqlQuery query;
  bool success = query.exec(SQL_CREATE_WORDLIST_INFO) && query.exec(SQL_CREATE_WORDLIST) &&
                 query.exec(SQL_INSERT_INITIAL_WORDLIST_INFO);
  if (!success) throw QString("Couldn't create table structure " % query.lastError().text());
  return success;
}

QString DatabaseManager::getUpdatedWordlist() {
  QFile sourceFile("../Dictionary/buchmaal/heinzelliste.js");
  if(!sourceFile.exists()) throw sourceFile.fileName() + " does not exist.";
  if(!sourceFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
    throw "Error opening " + sourceFile.fileName() + " even though the file exists.";
  }
  QTextStream textStream(&sourceFile);
  return textStream.readAll();
}
