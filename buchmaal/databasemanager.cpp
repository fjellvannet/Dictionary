#include "databasemanager.h"
#include "progressmanager.h"
#include "localsortkeygenerator.h"
#include <QtSql>

// Constants
const QStringList WORDLIST_COLUMNS = QStringList({"NO", "NO_type", "NO_add_query", "NO_comment",
                                                  "DE", "DE_type", "DE_add_query", "DE_comment", "DE_category",
                                                  "NO_sort", "NO_sect", "DE_sort", "DE_sect"});
const QVector<QPair<const char*, QStringList>> WORDLIST_INDICES = {{"i_NO", WORDLIST_COLUMNS.mid(0, 3)},
  {"s_NO", WORDLIST_COLUMNS.mid(8, 1)}, {"i_DE", WORDLIST_COLUMNS.mid(4, 3)}, {"s_DE", WORDLIST_COLUMNS.mid(10, 1)}
};
const QStringList WORDLIST_INFO_COLUMNS = QStringList({"LAST_UPDATED_LOCAL", "LAST_UPDATED_SERVER"});
const QStringList WORDLIST_INFO_DOWNLOAD_LINKS = QStringList({"https://www.heinzelnisse.info/",
                                                              "https://www.heinzelnisse.info/wiki/OldNews"});
#define DATABASE_FILENAME "buchmaal-database.sqlite"
#define DATABASE_FILENAME_RESOURCES ":/database/buchmaal-database.sqlite"
#define TABLE_WORDLIST "WORDLIST"
#define TABLE_WORDLIST_INFO "WORDLIST_INFO"
//#define WORDLIST_DOWNLOAD_LINK "http://ftp.uni-kl.de/pub/linux/knoppix-dvd/KNOPPIX_V8.6.1-2019-10-14-DE.iso"
#define WORDLIST_DOWNLOAD_LINK "https://www.heinzelnisse.info/Downloads/heinzelliste.js"
#define IS_SQL_SELECT_REGEX "^SELECT .*? FROM ."
#define MSG_TABLES_EXIST "tables exist"
#define SQL_TABLES_EXISTING "SELECT CASE WHEN COUNT(*) == 2 THEN '" MSG_TABLES_EXIST "' ELSE 'tables don''t exist' " \
  "END FROM SQLITE_MASTER WHERE TYPE = 'table' AND NAME IN ('" TABLE_WORDLIST "', '" TABLE_WORDLIST_INFO "')"
#define SQL_INSERT_INTO "INSERT INTO %1 VALUES(%2)"
#define SQL_SELECT "SELECT %1 FROM %2"
#define SQL_UPDATE "UPDATE %1 SET %2"
#define SQL_CREATE_INDEX "CREATE INDEX IF NOT EXISTS %1 ON %2 (%3)"
#define SQL_CREATE_TABLE "CREATE TABLE %1 (%2)"
#define SQL_DROP_INDEX "DROP INDEX IF EXISTS %1 ON %2"

#define REGEXP_FIND_WORDLIST_LAST_UPDATED "^<li> (?<lastUpdatedDate>\\d{2}\\.\\d{2}\\.\\d{4}) <ul>(\r|\n|\r\n)" \
  "<li> Update der Wörterliste </li>$"
#define ERROR_DOWNLOADING_WORDLIST_INFO "Error trying to check if the wordlist has been updated on the server. %1\n" \
  "The update mechanism will anyway try to download the newest wordlist."
#define ERROR_TABLES_NOT_CREATED "The table structure hasn't been initialized."
#define ERROR_NO_LAST_UPDATED_DATE "Couldn't extract the date when the wordlist was last updated."

#define BATCH_SIZE 1000
#define MAX_BATCH_SIZE 1000
#define RECORDS_TO_TOGGLE_INDEX 1000

#define PROGRESS_MANAGER_FORMAT_ALL_STATS "<td width='%1'><%percentage%></td>" \
  "<td width='%1'><sup><%done.unit-s%></sup>&frasl;<sub><%tot.unit-s%></sub><%unit-l%></td>\n" \
  "<td width='%1'><%speed%> <sup><%unit-l%></sup>&frasl;<sub>s</sub></td><td width='%1'><%estimateFormat%></td>"
#define PROGRESS_MANAGER_FORMAT_INDETERMINATE_DONE_SPEED "\n<td width='%6'><%done.unit-l%></td>" \
  "<td width='%6'><%speed%> <sup><%unit-l%></sup>&frasl;<sub>s</sub></td>"

DatabaseManager::DatabaseManager(QObject* parent): QObject(parent) {
  try {
    wordListUpdateLocal = directQuery(QString(SQL_SELECT).arg(TABLE_WORDLIST, WORDLIST_COLUMNS.at(0)),
                                      tr(ERROR_NO_LAST_UPDATED_DATE)).toDateTime();
  } catch (QString s) {
    qWarning().noquote() << s;
  }
  connect(this, &DatabaseManager::startWordListUpdate, this, &DatabaseManager::executeWordListUpdate,
          Qt::ConnectionType::QueuedConnection);
}

bool DatabaseManager::openDatabaseConnection() {
  const QFileInfo databaseFile = QFileInfo(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) +
                                           "/" + DATABASE_FILENAME);
  if (!databaseFile.exists()) {
    copyOrReplaceDatabaseFile(databaseFile, false);
  }
  bool connectionSuccessful = connectDatabase(databaseFile);
  if (!connectionSuccessful) {
    copyOrReplaceDatabaseFile(databaseFile, true);
    connectionSuccessful = connectDatabase(databaseFile);
  }
  return connectionSuccessful;
}

bool DatabaseManager::connectDatabase(const QFileInfo& databaseFile) {
  QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
  db.setDatabaseName(databaseFile.absoluteFilePath());
  bool connectionSuccessful = db.open();
  if (connectionSuccessful) {
    qCritical().noquote() << db.lastError().text();
  } else {
    qDebug().noquote() << "Successfully connected to database.";
  }
  return connectionSuccessful;
}

bool DatabaseManager::copyOrReplaceDatabaseFile(const QFileInfo& databaseFile, bool overwrite) {
  if(QDir().mkpath(databaseFile.absolutePath())) {
    QFile f(databaseFile.absoluteFilePath());
    f.setPermissions(QFile::ReadOther | QFile::WriteOther);
    if (databaseFile.exists() && overwrite) { //remove existing database-file - copy doesn't overwrite
      if(!f.remove()) qWarning() << "Could not delete old database.";
    }
    if(QFile(DATABASE_FILENAME_RESOURCES).copy(databaseFile.absoluteFilePath())) {
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

QVariant DatabaseManager::directQuery(QString sqlSelect, QString errorMessage) {
  QSqlQuery query;
  if(!QRegularExpression(IS_SQL_SELECT_REGEX, QRegularExpression::CaseInsensitiveOption).match(sqlSelect).hasMatch()) {
    throw tr("The query is no SELECT-SQL-clause");
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

bool DatabaseManager::executeWordListUpdate() {
  QPair<bool, QString> updateResult = updateWordList();
  if (updateResult.first) {
    qDebug().noquote() << updateResult.second;
  } else {
    qWarning().noquote() << updateResult.second;
  }
  emit wordListUpdateCompleted(updateResult.second);
  return updateResult.first;
}

QPair<bool, QString> DatabaseManager::updateWordList() {
  try {
    QSqlDatabase::database().close();
    ProgressManager progressManager;
    prepareProgressManager(progressManager);
    QDateTime wordListUpdateServer = getWordListUpdatedOnServer(progressManager);
    if (wordListUpdateLocal.isValid() && wordListUpdateServer.isValid() && wordListUpdateLocal > wordListUpdateServer) {
      updateWordListInfo(QDateTime::currentDateTime());
      return QPair(true, tr("The wordlist is up to date, last updated on the server: %1").arg(
                     wordListUpdateServer.date().toString(Qt::DefaultLocaleShortDate)));
    } // update is necessary - either one of the dates wasn't defined, or there is a newer version on the server
    QString updatedWordListString(progressManager.download(QUrl(WORDLIST_DOWNLOAD_LINK),
                                                           tr("Downloading updated wordlist")));
    QDateTime newDownloadTime = QDateTime::currentDateTime();
    if (directQuery(SQL_TABLES_EXISTING, ERROR_TABLES_NOT_CREATED) != MSG_TABLES_EXIST) {
      createTableStructure(progressManager);
    }
    progressManager.setCurrentStep(tr("Preparing to update wordlist."));
    QSet<QString> currentWordSet = getCurrentWordSet();
    QStringList updatedWordList = prepareRawWordList(updatedWordListString);
    QSet<QString> updatedWordSet(updatedWordList.begin(), updatedWordList.end());

    QSet<QString> wordsToAdd = updatedWordSet.subtract(currentWordSet);
    updatedWordSet = QSet<QString>(updatedWordList.begin(), updatedWordList.end());
    QSet<QString> wordsToRemove = currentWordSet.subtract(updatedWordSet);

    updateWordListInDatabase(progressManager, wordsToAdd, wordsToRemove);
    updateWordListInfo(newDownloadTime, wordListUpdateServer);
    return QPair(true, wordListUpdateCompletedMessage(wordsToAdd.size(), wordsToRemove.size()));
  } catch (QString s) {
    if (s == ProgressManager::OPERATION_CANCELLED_BY_USER) {
      return QPair(false, tr("Updating the wordlist has been cancelled by the user."));
    } else {
      return QPair(false, tr("Error updating wordlist. %1 The operation has been aborted.").arg(s));
    }
  }
}

QDateTime DatabaseManager::getWordListUpdatedOnServer(ProgressManager& progressManager) {
  progressManager.setCurrentStep(tr("Checking if wordlist update is necessary."));
  QRegularExpression findLastUpdatedDate(REGEXP_FIND_WORDLIST_LAST_UPDATED, QRegularExpression::MultilineOption |
                                         QRegularExpression::DontCaptureOption);
  for (QString downloadLink : WORDLIST_INFO_DOWNLOAD_LINKS) {
    try {
      QRegularExpressionMatch matchServerDate = findLastUpdatedDate.match(progressManager.download(QUrl(downloadLink)));
      if (matchServerDate.hasMatch()) {
        return QDateTime::fromString(matchServerDate.captured("lastUpdatedDate"), "dd.MM.yyyy");
      }
    } catch (QString s) {
      qWarning().noquote() << tr(ERROR_DOWNLOADING_WORDLIST_INFO).arg(s);
    }
  }
  return QDateTime();
}

void DatabaseManager::deleteRemovedWords(ProgressManager& progressManager, QSet<QString>& wordsToRemove) {
  progressManager.setCurrentStep(tr("Removing updated words from the database"));
  QVector<QVector<QStringView>> removeWords;
  splitWordLines(removeWords, wordsToRemove);
  QSqlQuery query(QString("DELETE FROM WORDLIST WHERE %1=?").arg(WORDLIST_COLUMNS.mid(0, 9).join("=? AND ")));

  for(int i = 0; i < removeWords.length(); i += BATCH_SIZE) { // går gjennom batchpakker
    bool lastUncopleteBatch = (i + BATCH_SIZE) > removeWords.length();
    QVariantList no_batch_words, de_batch_words;
    int k;
    for(int j = 0; j < WORDLIST_COLUMNS.length() - 4; j++) { //går gjennom kolonner
      QVariantList currentColumnValues;
      for(k = 0; k < BATCH_SIZE; k++) { //går gjennom linjer i batchpakka
        if(lastUncopleteBatch && (k + i) >= removeWords.length()) break;
        QVector<QStringView>* currentRowValues = &removeWords[k + i];
        if(currentRowValues->length() <= j) {
          currentColumnValues.append(QVariant());
        } else { // då må den være større eller lik j, så det må finnes en verdi
          currentColumnValues.append(currentRowValues->at(j).toString());
        }
      }
      query.addBindValue(currentColumnValues);
    }
    if (!query.execBatch()) throw QString("Couldn't remove updated words from database " % query.lastError().text());
    progressManager.emitCurrentStepProgress(k + i, removeWords.length());
  }
}

QSet<QString> DatabaseManager::getCurrentWordSet() {
  QSqlQuery query;
  query.setForwardOnly(true);
  QSet<QString> currentWordSet;
  currentWordSet.reserve(50000);
  bool success = query.exec(QString(SQL_SELECT).arg(WORDLIST_COLUMNS.mid(0, 9).join(", "), TABLE_WORDLIST));
  if (success) {
    query.first();
    while (query.isValid()) {
      QString line = query.value(0).toString();
      for (int i = 1; i < 9; ++i) {
        line.append(QString('\t' % query.value(i).toString()));
      }
      currentWordSet.insert(line);
      query.next();
    }
  } else throw QString("Couldn't retrieve data from wordlist-table. " % query.lastError().text());
  return currentWordSet;
}

bool DatabaseManager::updateWordListInfo(QDateTime wordListUpdateLocal, QDateTime wordListUpdateServer) {
  QSqlQuery query;
  if (!wordListUpdateServer.isValid()) {
    query.prepare(QString(SQL_UPDATE).arg(TABLE_WORDLIST_INFO, WORDLIST_INFO_COLUMNS.at(0) + "=?"));
  } else {
    query.prepare(QString(SQL_UPDATE).arg(TABLE_WORDLIST_INFO, WORDLIST_INFO_COLUMNS.join("=?, ") + "=?"));
    query.bindValue(1, wordListUpdateServer);
  }
  query.bindValue(0, wordListUpdateLocal);
  bool success = query.exec();
  if (!success) throw QString(tr("Couldn't update wordlist-information in database.") % " " % query.lastError().text());
  else this->wordListUpdateLocal = wordListUpdateLocal;
  return success;
}

void DatabaseManager::insertNewWords(ProgressManager& progressManager, QSet<QString>& wordsToAdd) {
  LocalSortKeyGenerator generator_no, generator_de;
  generator_de.addReplacePair(QString("ß").at(0), "ss");
  generator_no.addReplacePair(QString("æ").at(0), "Å");
  generator_no.addReplacePair(QString("ø").at(0), "Æ");
  generator_no.addReplacePair(QString("å").at(0), "Ø");

  QSqlQuery query(QString(SQL_INSERT_INTO).arg(TABLE_WORDLIST,
                                               QString("?, ").repeated(WORDLIST_COLUMNS.length() - 1) + '?'));
  progressManager.setCurrentStep(tr("Inserting %n new words into the database", "", wordsToAdd.size()), tr("words"));

  QVector<QVector<QStringView>> insertWords;
  splitWordLines(insertWords, wordsToAdd);
  bool lastUncopleteBatch;

  for(int i = 0; i < insertWords.length(); i += BATCH_SIZE) { // går gjennom batchpakker
    lastUncopleteBatch = (i + BATCH_SIZE) > insertWords.length();
    QVariantList no_batch_words, de_batch_words;
    for(int j = 0; j < WORDLIST_COLUMNS.length() - 4; j++) { //går gjennom kolonner
      QVariantList currentColumnValues;
      for(int k = 0; k < BATCH_SIZE; k++) { //går gjennom linjer i batchpakka
        if(lastUncopleteBatch && (k + i) >= insertWords.length()) break;
        QVector<QStringView>& currentRowValues = insertWords[k + i];
        if(currentRowValues.length() <= j) {
          currentColumnValues.append(QVariant());
        } else { // då må den være større eller lik j, så det må finnes en verdi
          currentColumnValues.append(currentRowValues.at(j).toString());
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
    progressManager.emitCurrentStepProgress(i + no_batch_words.length(), insertWords.length());
  }
}

bool DatabaseManager::splitWordLines(QVector<QVector<QStringView>>& result, QSet<QString>& wordLines) {
  result.reserve(wordLines.size());
  for (QSet<QString>::iterator wordLine = wordLines.begin(); wordLine != wordLines.end(); ++wordLine) {
    result.append(wordLine->splitRef("\t"));
  }
  return true;
}

void DatabaseManager::updateWordListInDatabase(ProgressManager& progressManager, QSet<QString>& wordsToAdd,
                                               QSet<QString>& wordsToRemove) {
  QSqlQuery query;
  if (wordsToAdd.size() + wordsToRemove.size() < RECORDS_TO_TOGGLE_INDEX) {
    progressManager.setCurrentStep(tr("Updating wordlist database"));
    deleteRemovedWords(progressManager, wordsToRemove);
    insertNewWords(progressManager, wordsToAdd);
  } else {
    for (const QPair<const char*, QStringList> index : WORDLIST_INDICES) {
      query.exec(QString(SQL_DROP_INDEX).arg(index.first));
    }
    deleteRemovedWords(progressManager, wordsToRemove);
    insertNewWords(progressManager, wordsToAdd);
    progressManager.setCurrentStep(tr("Adding indices to make search faster"), tr("indices", "", WORDLIST_INDICES.size()));
    qint8 i = 0;
    for (const QPair<const char*, QStringList> index : WORDLIST_INDICES) {
      query.exec(QString(SQL_CREATE_INDEX).arg(index.first, index.second.join(", ")));
      progressManager.emitCurrentStepProgress(++i, WORDLIST_INDICES.length());
    }
  }
  progressManager.setCurrentStep(tr("Compressing the wordlist-database-file"));
  query.exec("VACUUM");
}

QStringList DatabaseManager::prepareRawWordList(QString& rawWordList) {
  return rawWordList.replace(QLatin1String("\\\""), QLatin1String("\""))
         .left(rawWordList.lastIndexOf(QLatin1String("\\t\\n""")))
         .mid(rawWordList.indexOf(QLatin1String("HeinzelSearch.Config.hndb = [""")) + 30).toString()
         .replace(QLatin1String("\\t"), QLatin1String("\t")).split(QLatin1String("\t\\n"));
}

bool DatabaseManager::createTableStructure(ProgressManager& progressManager) {
  progressManager.setCurrentStep(tr("Creating table structure for wordlist-database"));
  QSqlQuery query;
  const QString SQL_CREATE_WORDLIST_TABLE = QString(SQL_CREATE_TABLE)
                                            .arg(TABLE_WORDLIST, WORDLIST_COLUMNS.join(" TEXT, ") + " TEXT");
  const QString SQL_CREATE_WORDLIST_INFO_TABLE = QString(SQL_CREATE_TABLE)
                                                 .arg(TABLE_WORDLIST_INFO, WORDLIST_INFO_COLUMNS.join(" TEXT, ") + " TEXT");
  const QString SQL_INSERT_INITIAL_VALUES_INTO_WORDLIST_INFO = QString(SQL_INSERT_INTO)
                                                               .arg(TABLE_WORDLIST_INFO, "NULL" + QString(", NULL").repeated(WORDLIST_INFO_COLUMNS.length() - 1));
  bool success = query.exec(SQL_CREATE_WORDLIST_TABLE) && query.exec(SQL_CREATE_WORDLIST_INFO_TABLE) &&
                 query.exec(SQL_INSERT_INITIAL_VALUES_INTO_WORDLIST_INFO);
  if (!success) throw QString(tr("Couldn't create table structure ") % query.lastError().text());
  return success;
}

QString DatabaseManager::getUpdatedWordlist() {
  QFile sourceFile("../Dictionary/buchmaal/heinzelliste.js");
  if(!sourceFile.exists()) throw QString(sourceFile.fileName() % " does not exist.");
  if(!sourceFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
    throw "Error opening " + sourceFile.fileName() + " even though the file exists.";
  }
  QTextStream textStream(&sourceFile);
  return textStream.readAll();
}

void DatabaseManager::prepareProgressManager(ProgressManager& progressManager) {
  progressManager.setFormat(QLatin1String(PROGRESS_MANAGER_FORMAT_ALL_STATS),
                            QLatin1String(PROGRESS_MANAGER_FORMAT_INDETERMINATE_DONE_SPEED));
  connect(&progressManager, &ProgressManager::sendCurrentStepProgress,
          this, &DatabaseManager::sendCurrentStepProgress);
  connect(&progressManager, &ProgressManager::sendCurrentStep, this, &DatabaseManager::sendCurrentStep);
  connect(this, &DatabaseManager::cancelWordListUpdate, &progressManager, &ProgressManager::cancelOperation);
}

QString DatabaseManager::wordListUpdateCompletedMessage(int insertedWords, int removedWords) {
  QString wordListUpdateCompletedMsg(tr("The wordlist has been successfully updated."));
  if (insertedWords) wordListUpdateCompletedMsg.append(tr("%n word(s) were inserted", "", insertedWords));
  if (insertedWords && !removedWords) wordListUpdateCompletedMsg.append(".");
  else if (insertedWords && removedWords) wordListUpdateCompletedMsg.append(" and ");
  if (removedWords) wordListUpdateCompletedMsg.append(tr("%n updated word(s) were removed.", "", removedWords));
  return wordListUpdateCompletedMsg;
}
