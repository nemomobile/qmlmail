include(../common.pri)
TARGET = meegoemail
TEMPLATE = lib

CONFIG += link_pkgconfig \
    mobility

PKGCONFIG += qmfmessageserver \
    qmfclient

OBJECTS_DIR = .obj
MOC_DIR = .moc

SOURCES += \
    emailaccountlistmodel.cpp \
    emailmessagelistmodel.cpp \
    folderlistmodel.cpp

INSTALL_HEADERS += \
    emailaccountlistmodel.h \
    emailmessagelistmodel.h \
    folderlistmodel.h

HEADERS += \
    $$INSTALL_HEADERS

target.path = $$[QT_INSTALL_LIBS]
INSTALLS += target

headers.files += $$INSTALL_HEADERS
headers.path += $$INSTALL_ROOT/usr/include/meegoemail
INSTALLS += headers

pkgconfig.files += meegoemail.pc
pkgconfig.path += $$[QT_INSTALL_LIBS]/pkgconfig
INSTALLS += pkgconfig
