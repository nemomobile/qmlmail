include(../common.pri)
TARGET = qmlmail
TEMPLATE = app
QT += qml quick webkit network

CONFIG += link_pkgconfig \
    mobility

packagesExist(mlite) {
    PKGCONFIG += mlite
    DEFINES += HAS_MLITE
} else {
    warning("mlite not available. Some functionality may not work as expected.")
}

packagesExist(qdeclarative5-boostable) {
    message("Building with qdeclarative5-boostable support")
    DEFINES += HAS_BOOSTER
    PKGCONFIG += qdeclarative5-boostable
} else {
    warning("qdeclarative5-boostable not available; startup times will be slower")
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
