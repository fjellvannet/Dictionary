#include "databasecreator.h"
QFileInfo DatabaseCreator::sqliteFileProject;
QFileInfo DatabaseCreator::sqliteFileSSD;

bool DatabaseCreator::prepareDatabase()
{
    sqliteFileProject.setFile("../Dictionary/buchmaal/buchmaal-database.sqlite");
    sqliteFileSSD.setFile(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + '/' + sqliteFileProject.fileName());
    if(!QSqlDatabase::database().isOpen()){
        //viktig: pass på at databasen ligger på SSD'en når du skal skrive i den. Ellers tar det 10x så lang tid å skrive databasen!
        //sqliteFileProject = QFileInfo("../Dictionary/bonytsk/bonytsk-vocabulary.sqlite");
        if(QDir().mkpath(sqliteFileSSD.absolutePath())) { //sqlite fila kan ikke lages, dersom dens mappe ikke eksisterer, så det er ikke vitsig å fortsette dersom mappa ikke kunne lages
            qDebug().noquote() << "Directory for database exists";
            if(sqliteFileProject.exists()){
                QFile(sqliteFileSSD.absoluteFilePath()).remove();//old file on SSD must be removed first.
                if(!QFile(sqliteFileProject.absoluteFilePath()).copy(sqliteFileSSD.absoluteFilePath()))
                    askToContinueDespiteError("Could not copy database file to SSD.");
            }
            QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");//not dbConnection
            db.setDatabaseName(sqliteFileSSD.absoluteFilePath()); //if the database file doesn't exist yet, it will create it
            if (!db.open()){
                qCritical().noquote() << (sqliteFileSSD.exists() ? db.lastError().text() :
                    "Could not create database file. (Path issue? not writable location?) " + sqliteFileSSD.absolutePath());
                return false;
            } else {
                qDebug() << "Successfully connected to database.";
            }
        }
        else qWarning().noquote() << "The AppData-Directory for updating the database could not be created, operation aborted.";
    }
    return true;
}

bool DatabaseCreator::finishEditingDatabase()
{
    if(QSqlDatabase::database().isOpen()) {
        QSqlQuery query;
        qDebug().noquote() << (query.exec("VACUUM") ? "successfully compressed database file" : "error compressing the database file");
        QSqlDatabase::database().close();
        QString backupFilePath = QString("%1/%2-old.%3").arg(sqliteFileProject.absolutePath(),
            sqliteFileProject.baseName(), sqliteFileProject.completeSuffix());
         //old backup file must be removed first, otherwise it is not possible to copy the current file to the old location.
        if(QFile(backupFilePath).exists()) if(!QFile(backupFilePath).remove())
            askToContinueDespiteError("Could not remove old backup-database - check write access.");
        if(!QFile(sqliteFileProject.absoluteFilePath()).rename(backupFilePath))
            askToContinueDespiteError("Could not copy current database-file - check write access.");
        if(!QFile(sqliteFileSSD.absoluteFilePath()).copy(sqliteFileProject.absoluteFilePath()))
            askToContinueDespiteError("Error copying sqlite file from SSD back to project.");
    }
    return true;
}

/*!
 * \brief DatabaseCreator::updateHeinzelliste updates the heinzelliste table in the bonytsk-vocabulary sqlite database
 */
bool DatabaseCreator::updateHeinzelliste(bool continueEditingAfterThisOperation, bool batchOperation, bool optSortKeys, DatabaseCreator::SourceFileType fileType)
{
    const QString TABLENAME = "heinzelliste";
    qDebug().noquote() << "Update Heinzelliste, execution Mode:" << (batchOperation ? "Batch Execution" : "Single Line processing") <<
        (fileType == jsFile ? "js-sourcefile" : "csv-sourcefile");
    prepareDatabase();
    bool readHeinzelliste = true;
    if(readHeinzelliste) {
        QSqlQuery query;
        if(!query.exec("DROP TABLE IF EXISTS " + TABLENAME)){
            qDebug().noquote() << query.lastQuery() << query.lastError() << "Dropping the old" << TABLENAME << "table did not work - sql-syntax?";//remove old table
        }
        //create table

        QString fileSuffix = fileType == jsFile ? "js" : "csv";

        LocalSortKeyGenerator generator_no, generator_de;
        generator_de.addReplacePair(QString("ß").at(0), "ss");
        generator_no.addReplacePair(QString("æ").at(0), "Å");
        generator_no.addReplacePair(QString("ø").at(0), "Æ");
        generator_no.addReplacePair(QString("å").at(0), "Ø");

        QFile sourceFile("../Dictionary/buchmaal/" + TABLENAME + '.' + fileSuffix);
        if(!sourceFile.exists()) askToContinueDespiteError(sourceFile.fileName() + " does not exist.");
        if(!sourceFile.open(QIODevice::ReadOnly | QIODevice::Text)) askToContinueDespiteError("Error opening " + sourceFile.fileName() + " even though the file exists.");
        QTextStream textStream(&sourceFile);
        //csvStream.setCodec(QTextCodec::codecForName("UTF-8"));//wichtig, die Datei muss mit UTF-8 codiert sein
        QStringList columnNames = fileType == jsFile ? QStringList({"NO","NO_type","NO_add_query","NO_comment", "NO_sort","NO_sect",
            "DE","DE_type","DE_add_query","DE_comment","DE_category","DE_sort","DE_sect"}) : textStream.readLine().split("\t");
        if(!query.exec(QString("CREATE TABLE IF NOT EXISTS %1 (%2)").arg(TABLENAME, columnNames.join(", ")))){
            qWarning().noquote() << query.lastQuery() << query.lastError();
            askToContinueDespiteError("Error creating table " + TABLENAME + " - sql-syntax?");
        }
        QStringList columnNamesInsert = QStringList(columnNames);
        //move NO_sort and NO_sect to the end, so that i
        for(int i = 0; i < 2; ++i) columnNamesInsert.move(4, columnNamesInsert.length() - 3);
        QString placeHolders(columnNames.length(), '?');
        for(int i = 1; i < placeHolders.length(); i += 2) placeHolders.insert(i,',');//creates "?,?,?...,?"
        query.prepare(QString("INSERT INTO %1 (%2) VALUES(%3)").arg(TABLENAME, columnNamesInsert.join(", "), placeHolders));

        QStringList fileLines;
        QString columnSeperator;
        if(fileType == jsFile) {
            QString fileReadAll = textStream.readAll().replace("\\\"", "\"");;
            fileReadAll = fileReadAll.mid(fileReadAll.indexOf("HeinzelSearch.Config.hndb = [""") + 30);
            fileReadAll = fileReadAll.left(fileReadAll.lastIndexOf("\\n"""));//Be aware here - removes the last line shift as well, so the empty lines are cut off
            fileLines = fileReadAll.split("\\n");
            columnSeperator = "\\t";
        } else {
            fileLines = textStream.readAll().split("\n");
            columnSeperator = "\t";
        }

        QElapsedTimer speed;
        speed.start();

        if(batchOperation) {
            QVector<QStringList> fileValues;
            for(QString fileLine: fileLines) fileValues.append(fileLine.split(columnSeperator));
            const int BATCHSIZE = 1000;
            for(int i = 0; i < fileValues.length(); i+=BATCHSIZE) {// går gjennom batchpakker
                int batchStarted = speed.elapsed();
                bool lastUncopleteBatch = (i + BATCHSIZE) > fileValues.length();
                QVariantList no_batch_words, de_batch_words;
                for(int j = 0; j < columnNames.length() - 4; j++){//går gjennom kolonner
                    QVariantList currentColumnValues;
                    for(int k = 0; k < BATCHSIZE; k++){//går gjennom linjer i batchpakka
                        if(lastUncopleteBatch && (k+i) >= fileValues.length()) break;
                        QStringList& currentRowValues = fileValues[k+i];
                        if(currentRowValues.length() <= j){
                            currentColumnValues.append(QVariant());
                        } else {//då må den være større eller lik v, så det må finnes en verdi
                            currentColumnValues.append(currentRowValues.at(j));
                        }
                    }
                    if(j == 0) no_batch_words = currentColumnValues;
                    else if(j == 4) de_batch_words = currentColumnValues;
                    query.addBindValue(currentColumnValues);
                }
                QVariantList NO_sort, NO_sect, DE_sort, DE_sect;
                for(QVariant no_word: no_batch_words) {
                    QPair<QString, QChar> no_sort = generator_no.sortKey(no_word.toString());
                    NO_sort << no_sort.first;
                    NO_sect << no_sort.second;
                }
                for(QVariant de_word: de_batch_words) {
                    QPair<QString, QChar> de_sort = generator_de.sortKey(de_word.toString());
                    DE_sort << de_sort.first;
                    DE_sect << de_sort.second;
                }
                query.addBindValue(NO_sort);
                query.addBindValue(NO_sect);
                query.addBindValue(DE_sort);
                query.addBindValue(DE_sect);
                query.execBatch();
                qDebug().noquote() << QTime(0,0,0,0).addMSecs(speed.elapsed()).toString("mm:ss") << "executed Batch" << i/1000 + 1 <<
                    ", which took" << QTime(0,0,0,0).addMSecs(speed.elapsed() - batchStarted).toString("mm:ss:zzz");
            }
        } else {
            int rps = 0, record_count = 0, wholeseconds = 0;
            for(QString fileLine : fileLines)
            {
                rps++;
                QStringList heinzelColumns = fileLine.split(columnSeperator);
                if(heinzelColumns.length() < 5) continue;
                int i = 0;
                int maxFirstLoop = qMin(columnNames.length() - 4, heinzelColumns.length());
                QVariantList bindValues;
                for(; i < maxFirstLoop; ++i) query.addBindValue(heinzelColumns.at(i));
                for(; i < columnNames.length() - 4; ++i) query.addBindValue(QVariant());//if there are less columns in the line than in the table, fill with ""
                QPair<QString, QChar> no_sort = generator_no.sortKey(heinzelColumns.at(0));
                QPair<QString, QChar> de_sort = generator_de.sortKey(heinzelColumns.at(4));
                query.addBindValue(no_sort.first);
                query.addBindValue(no_sort.second);
                query.addBindValue(de_sort.first);
                query.addBindValue(de_sort.second);
                if(!query.exec()) askToContinueDespiteError("SQL error executing " + query.lastQuery() + " " + query.lastError().text());
                if(rps == 1000) break;
                if(speed.elapsed() / 1000 > wholeseconds) {
                    wholeseconds++;
                    record_count += rps;
                    qDebug().noquote() << QTime(0,0,0,0).addMSecs(speed.elapsed()).toString("mm:ss") << rps << "records per second," <<
                        record_count / wholeseconds << "average records per second," << record_count << "total records," << heinzelColumns;
                    rps = 0;
                }
            }
        }
        query.exec("SELECT * FROM " + TABLENAME);

        query.last();
        QStringList lastentry;
        for(int i = 0; i < columnNames.length(); i++) lastentry << query.value(i).toString();
        qDebug() << lastentry;
        query.exec("CREATE INDEX i_NO ON " + TABLENAME + "(NO, NO_type, NO_add_query)");
        query.exec("CREATE INDEX s_NO ON " + TABLENAME + "(NO_sort)");
        query.exec("CREATE INDEX i_DE ON " + TABLENAME + "(DE, DE_type, DE_add_query)");
        query.exec("CREATE INDEX s_DE ON " + TABLENAME + "(DE_sort)");
    }
    if(optSortKeys) optimizeSortKeys();
    if(!continueEditingAfterThisOperation) finishEditingDatabase();
    return true;
}

/*!
 * \brief DatabaseCreator::updateVersion, burde kalles hver gang databasen oppdateres, og egentlig også når versjonsnummeret til appen endres.
 * \param bool continueEditingAfterThisOperation avgjør, om databasen lukkes igjen etter denne operasjonen (eller om den blir åpen, dersom flere
 * oppdateringer skal gjennomføres gir det jo mening
 * \return returnerer om
 */
bool DatabaseCreator::updateVersion(bool continueEditingAfterThisOperation)
{
    prepareDatabase();
    const QString TABLENAME = "version";
    QSqlQuery query;
    bool everythingWorked = true;
    if(!query.exec("DROP TABLE IF EXISTS " + TABLENAME)) everythingWorked = false;
    if(!query.exec("CREATE TABLE IF NOT EXISTS " + TABLENAME + " (Ver_Major INTEGER, Ver_Minor INTEGER, Ver_Patch INTEGER, DB_date TEXT)")) everythingWorked = false;
    if(!query.exec(QString("INSERT INTO %1 VALUES (%2)").arg(TABLENAME, QString(TOSTRING(APP_VERSION_STR)).replace(QChar('.'), QChar(',')) + ",DATETIME('now')"))) everythingWorked = false;
    qDebug() << query.lastQuery();
    if(!query.exec("SELECT * FROM " + TABLENAME)) everythingWorked = false;
    query.last();
    QStringList lastentry;
    for(int i = 0; i < 4; i++) lastentry << query.value(i).toString();
    qDebug().noquote() << lastentry;
    if(!continueEditingAfterThisOperation) finishEditingDatabase();
    return everythingWorked;
}

bool DatabaseCreator::optimizeSortKeys(bool numberKeys)
{
    //find perfect length of sortkeys, so that no more than the necessary information is saved
    const QString TABLENAME = "heinzelliste";
    QSqlQuery query;
    QVector<QPair<QString, QString>> replaceSortKeysNO, replaceSortKeysDE;
    query.exec("SELECT DISTINCT NO_sort FROM " + TABLENAME + " ORDER BY NO_sort");
    QString lastShortedKey = "";
    while(query.next()) {
        QString current = query.value(0).toString();
        for(int i = lastShortedKey.length(); i >= 0; --i) {
            if(current.left(i) == lastShortedKey.left(i)) {
                lastShortedKey = current.left(i + 1);
                break;
            }
        }
        replaceSortKeysNO.append(QPair<QString, QString>(lastShortedKey, current));
    }
    query.exec("SELECT DISTINCT DE_sort FROM " + TABLENAME + " ORDER BY DE_sort");
    lastShortedKey = "";
    while(query.next()) {
        QString current = query.value(0).toString();
        for(int i = lastShortedKey.length(); i >= 0; --i) {
            if(current.left(i) == lastShortedKey.left(i)) {
                lastShortedKey = current.left(i + 1);
                break;
            }
        }
        replaceSortKeysDE.append(QPair<QString, QString>(lastShortedKey, current));
    }
    int i = 0, rps = 0, record_count = 0, wholeseconds = 0;
    QElapsedTimer speed;
    speed.start();
    for(QPair<QString, QString> replaceSortKey: replaceSortKeysNO) {
        rps++;
        query.prepare("UPDATE heinzelliste SET NO_sort = ? WHERE NO_sort = ?");
        query.addBindValue(numberKeys ? QVariant(i) : replaceSortKey.first);
        query.addBindValue(replaceSortKey.second);
        if(!query.exec()) askToContinueDespiteError("SQL error executing " + query.lastQuery() + " " + query.lastError().text());
        if(speed.elapsed() / 1000 > wholeseconds) {
            wholeseconds++;
            record_count += rps;
            qDebug().noquote() << QTime(0,0,0,0).addMSecs(speed.elapsed()).toString("mm:ss") << rps << "records per second," <<
                record_count / wholeseconds << "average records per second," << record_count << "total records";
            rps = 0;
        }
        i++;
    }
    qDebug() << "Ferdig med å komprimere søkeindeksen til norsk";
    speed.restart();
    i = 0; rps = 0; record_count = 0; wholeseconds = 0;
    for(QPair<QString, QString> replaceSortKey: replaceSortKeysDE) {
        rps++;
        query.prepare("UPDATE heinzelliste SET DE_sort = ? WHERE DE_sort = ?");
        query.addBindValue(numberKeys ? QVariant(i) : replaceSortKey.first);
        query.addBindValue(replaceSortKey.second);
        if(!query.exec()) askToContinueDespiteError("SQL error executing " + query.lastQuery() + " " + query.lastError().text());
        if(speed.elapsed() / 1000 > wholeseconds) {
            wholeseconds++;
            record_count += rps;
            qDebug().noquote() << QTime(0,0,0,0).addMSecs(speed.elapsed()).toString("mm:ss") << rps << "records per second," <<
                record_count / wholeseconds << "average records per second," << record_count << "total records";
            rps = 0;
        }
        i++;
    }
    qDebug() << "Ferdig med å komprimere søkeindeksen til tysk";
    return true;
    /*//finner makslengden av SortKey som trengs, men denne koden er nå blitt overflodig
    query.first();
    QString last = query.value(0).toString();
    int minSortKeyLength = 0;
    while(query.next()){
        QString next = query.value(0).toString();
        int minLength = qMin(last.length(), next.length());
        if(minSortKeyLength < minLength) {
            if(last.left(minLength) != next.left(minLength)) {
                //gå bakover
                for(int i = minLength; i > minSortKeyLength; --i) {
                    if(last.left(i) == next.left(i)) {
                        minSortKeyLength = i + 1;
                        break;
                    }
                }
            }
        }
        last = next;
    }
    qDebug() << minSortKeyLength;*/
}
/*!
 * \brief DatabaseCreator::askToContinueDespiteError
 * \return true if the user wants to continue, false if not
 */
bool DatabaseCreator::askToContinueDespiteError(QString errorMessage)
{
    bool continueApp = QInputDialog::getText(nullptr, QApplication::applicationName(), errorMessage + "\nDo yo want to continue despite the error? (y/n)").toLower().startsWith("y");
    qWarning().noquote() << errorMessage << (continueApp ? "Continue running application despite error." : "Execution canceled, exited application.");
    if(!continueApp) std::exit(0);
    return !continueApp;
}
