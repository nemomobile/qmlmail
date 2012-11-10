include(../common.pri)
TARGET = qmlmail
TEMPLATE = app
QT += declarative webkit network

CONFIG += link_pkgconfig \
    mobility

PKGCONFIG += qmfmessageserver \
    qmfclient

packagesExist(mlite) {
    PKGCONFIG += mlite
    DEFINES += HAS_MLITE
} else {
    warning("mlite not available. Some functionality may not work as expected.")
}

OBJECTS_DIR = .obj
MOC_DIR = .moc
RESOURCES += res.qrc

QML_FILES = qml/*.qml

OTHER_FILES += $${QML_FILES}

SOURCES += \
    main.cpp

target.path = /usr/bin
INSTALLS += target
