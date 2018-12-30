#include "databasecreator.h"
QFileInfo DatabaseCreator::sqliteFileProject;
QFileInfo DatabaseCreator::sqliteFileSSD;

bool DatabaseCreator::prepareDatabase()
{
    sqliteFileProject.setFile("../Dictionary/bonytysk/bonytysk-database.sqlite");
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
bool DatabaseCreator::updateHeinzelliste(bool continueEditingAfterThisOperation, bool batchOperation, DatabaseCreator::SourceFileType fileType)
{
#define BATCH_EXEC 1
#define JSFILE 1
    const QString TABLENAME = "heinzelliste";
    qDebug().noquote() << "Update Heinzelliste, execution Mode:" << (batchOperation ? "Batch Execution" : "Single Line processing") <<
        (fileType == jsFile ? "js-sourcefile" : "csv-sourcefile");
    prepareDatabase();
    QSqlQuery query;
    if(!query.exec("DROP TABLE IF EXISTS " + TABLENAME)){
        qDebug().noquote() << query.lastQuery() << query.lastError() << "Dropping the old" << TABLENAME << "table did not work - sql-syntax?";//remove old table
    }
    //create table

    QString fileSuffix = fileType == jsFile ? "js" : "csv";

    QFile sourceFile("../Dictionary/bonytysk/" + TABLENAME + '.' + fileSuffix);
    if(!sourceFile.exists()) askToContinueDespiteError(sourceFile.fileName() + " does not exist.");
    if(!sourceFile.open(QIODevice::ReadOnly | QIODevice::Text)) askToContinueDespiteError("Error opening " + sourceFile.fileName() + " even though the file exists.");
    QTextStream textStream(&sourceFile);
    //csvStream.setCodec(QTextCodec::codecForName("UTF-8"));//wichtig, die Datei muss mit UTF-8 codiert sein
    QStringList columnNames = fileType == jsFile ? QStringList({"NO","NO_type","NO_add_query","NO_comment",
        "DE","DE_type","DE_add_query","DE_comment","DE_category"}) : textStream.readLine().split("\t");
    if(!query.exec(QString("CREATE TABLE IF NOT EXISTS %1 (%2 TEXT)").arg(TABLENAME, columnNames.join(" TEXT, ")))){
        qWarning().noquote() << query.lastQuery() << query.lastError();
        askToContinueDespiteError("Error creating table " + TABLENAME + " - sql-syntax?");
    }

    QString placeHolders(columnNames.length(), '?');
    for(int i = 1; i < placeHolders.length(); i += 2) placeHolders.insert(i,',');//creates "?,?,?...,?"
    query.prepare(QString("INSERT INTO %1 VALUES(%2)").arg(TABLENAME, placeHolders));

    QStringList fileLines;
    QString columnSeperator;
    if(fileType == jsFile) {
        QString fileReadAll = textStream.readAll().replace("\"", """");
        fileReadAll = fileReadAll.mid(fileReadAll.indexOf("HeinzelSearch.Config.hndb = [""") + 30);
        fileReadAll = fileReadAll.left(fileReadAll.lastIndexOf("\\n"""));//Be aware here - removes the last line shift as well, so I don't get empty lines
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
            for(int j = 0; j < columnNames.length(); j++){//går gjennom kolonner
                QVariantList currentColumnValues;
                bool lastUncopleteBatch = (i + BATCHSIZE) > fileValues.length();
                for(int k = 0; k < BATCHSIZE; k++){//går gjennom linjer i batchpakka
                    if(lastUncopleteBatch && (k+i) >= fileValues.length()) break;
                    QStringList& currentRowValues = fileValues[k+i];
                    if(currentRowValues.length() <= j){
                        currentColumnValues.append(QVariant(QVariant::String));
                    } else {//då må den være større eller lik v, så det må finnes en verdi
                        currentColumnValues.append(currentRowValues.at(j));
                    }
                }
                query.addBindValue(currentColumnValues);
            }
            query.execBatch();
            qDebug().noquote() << QTime(0,0,0,0).addMSecs(speed.elapsed()).toString("mm:ss") << "executed Batch" << i/1000 + 1 <<
                ", which took" << QTime(0,0,0,0).addMSecs(speed.elapsed() - batchStarted).toString("mm:ss:zzz");
            break;
        }
    } else {
        int rps = 0, record_count = 0, wholeseconds = 0;
        for(QString fileLine : fileLines)
        {
            rps++;
            QStringList heinzelColumns = fileLine.split(columnSeperator);
            int i = 0;
            int maxFirstLoop = qMin(columnNames.length(), heinzelColumns.length());
            for(; i < maxFirstLoop; ++i) query.addBindValue(heinzelColumns.at(i));
            for(; i < columnNames.length(); ++i) query.addBindValue(QVariant(QVariant::String));//if there are less columns in the line than in the table, fill with ""
            if(!query.exec()) askToContinueDespiteError("SQL error executing " + query.lastQuery() + " " + query.lastError().text());
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
    if(!query.exec("CREATE TABLE IF NOT EXISTS " + TABLENAME + " (Ver_Major INTEGER, Ver_Minor INTEGER, Ver_Patch INTEGER)")) everythingWorked = false;
    if(!query.exec(QString("INSERT INTO %1 VALUES (%2)").arg(TABLENAME, QString(TOSTRING(APP_VERSION_STR)).replace(QChar('.'), QChar(','))))) everythingWorked = false;
    qDebug() << query.lastQuery();
    if(!query.exec("SELECT * FROM " + TABLENAME)) everythingWorked = false;
    query.last();
    QStringList lastentry;
    for(int i = 0; i < 3; i++) lastentry << query.value(i).toString();
    qDebug().noquote() << lastentry;
    if(!continueEditingAfterThisOperation) finishEditingDatabase();
    return everythingWorked;
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

