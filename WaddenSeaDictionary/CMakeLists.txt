qt_add_library(DictLib
    STATIC
    WaddenSeaDictionary.qrc
    include/dictionarymodel.h
    include/vocabularylistmodel.h
    include/vocabularymodel.h
    src/dictionarymodel.cpp
    src/vocabularylistmodel.cpp
    src/vocabularymodel.cpp
)

#set_target_properties(DictLib PROPERTIES AUTOMOC ON)
target_link_libraries(DictLib PRIVATE Qt6::Quick)

include_directories(include)
