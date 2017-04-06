// Rebuild completely if you want to change the language, otherwise nothing will happen.
//#include "appinfo_de.h"
#include "appinfo_en.h"
#if WADDEN_SEA_DICTIONARY
//#include "appinfo_da.h"
//#include "appinfo_nl.h"
#endif

#ifndef APPINFO_H
#define APPINFO_H

#define VER_FILEVERSION             APP_VERSION_NR
#define STRINGIFY(x) #x //Diese Makrodefinition ist notwendig, da man sonst den #-Operator, der x in einen String mit \0 am Ende verwandelt nicht verwenden darf
#define TOSTRING(x) STRINGIFY(x)
#define VER_FILEVERSION_STR         TOSTRING(APP_VERSION_STR)

#define VER_PRODUCTVERSION          VER_FILEVERSION
#define VER_PRODUCTVERSION_STR      VER_FILEVERSION_STR

#define VER_COMPANYNAME_STR         TOSTRING(APP_DEVELOPER)
#define VER_LEGALTRADEMARKS1_STR    "All Rights Reserved"
#define VER_LEGALTRADEMARKS2_STR    VER_LEGALTRADEMARKS1_STR
#define VER_LEGALCOPYRIGHT_STR      TOSTRING(Copyright \xA9 2017 APP_DEVELOPER)
#define VER_COMPANYDOMAIN_STR       "https://github.com/fjellvannet/Dictionary"

#endif // APPINFO_H
