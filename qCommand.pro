# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = qCommand

CONFIG += sailfishapp

PKGCONFIG += \
    sailfishsecrets

SOURCES += \
    src/qCommand.cpp \
    src/commandengine.cpp \
    src/completion.cpp \
    src/fingerterm.cpp \
    src/developer.cpp \
    src/secrets.cpp

DISTFILES += \
    qml/qCommand.qml \
    qml/cover/*.qml \
    qml/pages/*.qml \
    qml/src/*.qml \
    rpm/qCommand.spec \
    translations/*.ts \
    qCommand.desktop

SAILFISHAPP_ICONS = 86x86

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/*.ts

HEADERS += \
    src/commandengine.h \
    src/secrets.h \
    src/completion.h \
    src/fingerterm.h \
    src/developer.h
