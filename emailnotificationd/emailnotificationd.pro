include(../common.pri)
TEMPLATE = app 
TARGET = emailnotificationd

CONFIG += console \
          link_pkgconfig
PKGCONFIG += qmfclient \
             mlite

target.path += $$INSTALL_ROOT/usr/bin/

desktop.files += emailnotificationd.desktop
desktop.path += $$INSTALL_ROOT/etc/xdg/autostart/

SOURCES += main.cpp \
           notificationapp.cpp

HEADERS += notificationapp.h

#INSTALLS += target desktop

TRANSLATIONS += *.qml settings/*.qml settings/*.js

