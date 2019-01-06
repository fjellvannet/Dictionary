#ifndef DATABASECREATOR_H
#define DATABASECREATOR_H
#define STRINGIFY(x) #x //Disse trengs for å kunne skrive ut App-versjonen
#define TOSTRING(x) STRINGIFY(x)

#include <QSqlDatabase>
#include <QDir>
#include <QStandardPaths>
#include <QSqlError>
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QTextCodec>
#include <QSqlQuery>
#include <QElapsedTimer>
#include <QTime>
#include <QInputDialog>
#include <QApplication>
#include "localsortkeygenerator.h"

/*!
 * \brief The DatabaseCreator class is used to update the sqlite-vocabulary database for buchmaal
 */
class DatabaseCreator
{
public:
    enum SourceFileType{jsFile, csvFile};
    static bool updateHeinzelliste(bool continueEditingAfterThisOperation = false, bool batchOperation = false,
         bool optSortKeys = true, SourceFileType fileType = jsFile);
    static bool updateVersion(bool continueEditingAfterThisOperation = false);
private:
    static bool prepareDatabase();
    static bool finishEditingDatabase();
    static bool optimizeSortKeys(bool numberKeys = true);
    static bool askToContinueDespiteError(QString errorMessage);

    //viktig: pass på at databasen ligger på SSD'en når du skal skrive i den. Ellers tar det 10x så lang tid å skrive databasen!
    static QFileInfo sqliteFileProject; //for definition/intial value look in the beginning of databasecreator.cpp
    static QFileInfo sqliteFileSSD; //for definition/intial value look in the beginning of databasecreator.cpp
};
#endif // DATABASECREATOR_H
