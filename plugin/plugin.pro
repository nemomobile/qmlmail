include (../common.pri)
TEMPLATE = lib
TARGET = Email

QT += declarative webkit network
CONFIG += qt \
    plugin \
    link_pkgconfig \
    mobility

PKGCONFIG += qmfmessageserver\
    qmfclient

packagesExist(mlite) {
    PKGCONFIG += mlite
    DEFINES += HAS_MLITE
} else {
    warning("mlite not available. Some functionality may not work as expected.")
}

INCLUDEPATH += ../lib
LIBS += -L../lib -lmeegoemail

TARGET = $$qtLibraryTarget($$TARGET)
DESTDIR = $$TARGET
OBJECTS_DIR = .obj
MOC_DIR = .moc

#Input
SOURCES += components.cpp emailagent.cpp emailmessage.cpp emailaccountsettingsmodel.cpp emailaccount.cpp htmlfield.cpp
HEADERS += components.h  emailagent.h emailmessage.h emailaccountsettingsmodel.h emailaccount.h htmlfield.h

qmldir.files += $$TARGET
qmldir.path += $$[QT_INSTALL_IMPORTS]/MeeGo/App
INSTALLS += qmldir
