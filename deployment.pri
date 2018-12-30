#unix:!android {
#    isEmpty(target.path) {
#        qnx {
#            target.path = /tmp/$${TARGET}/bin
#        } else {
#            target.path = /opt/$${TARGET}/bin
#        }
#        export(target.path)
#    }
#    INSTALLS += target
#}

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

export(INSTALLS)
