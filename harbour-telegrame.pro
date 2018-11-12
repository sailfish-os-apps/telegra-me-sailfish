
TARGET = harbour-telegrame

TEMPLATE = app

CONFIG += c++11

QT += core network gui qml quick multimedia

MOC_DIR     = _moc
OBJECTS_DIR = _obj
RCC_DIR     = _rcc

CONFIG += link_pkgconfig

PKGCONFIG += sailfishapp
PKGCONFIG += tdlibjson
PKGCONFIG += nemonotifications-qt5
PKGCONFIG += mlite5

INCLUDEPATH += \
    /usr/include \
    /usr/include/sailfishapp \
    $$PWD/libQtQmlTricks \
    $$PWD/libQtQmlTricks/core/macros \
    $$PWD/libQtQmlTricks/core/models \
    $$PWD/libQtQmlTricks/gui/containers \
    $$PWD/libQtQmlTricks/gui/helpers \
    $$PWD/src

SOURCES += \
    $$PWD/src/harbour-telegrame.cpp \
    $$PWD/src/QtTdLibJsonWrapper.cpp \
    $$PWD/src/QtTdLibEnums.cpp \
    $$PWD/libQtQmlTricks/gui/containers/QQuickAbstractContainerBase.cpp \
    $$PWD/libQtQmlTricks/gui/containers/QQuickColumnContainer.cpp \
    $$PWD/libQtQmlTricks/gui/containers/QQuickContainerAttachedObject.cpp \
    $$PWD/libQtQmlTricks/gui/containers/QQuickGridContainer.cpp \
    $$PWD/libQtQmlTricks/gui/containers/QQuickRowContainer.cpp \
    $$PWD/libQtQmlTricks/gui/helpers/QQuickExtraAnchors.cpp \
    $$PWD/libQtQmlTricks/QtQmlTricks.cpp \
    src/QtTdLibCommon.cpp \
    src/QtTdLibConnection.cpp \
    src/QtTdLibGlobal.cpp \
    src/QtTdLibAuth.cpp \
    src/QtTdLibChat.cpp \
    src/QtTdLibContent.cpp \
    src/QtTdLibFile.cpp \
    src/QtTdLibMessage.cpp \
    src/QtTdLibUser.cpp

HEADERS += \
    $$PWD/src/QtTdLibJsonWrapper.h \
    $$PWD/src/QtTdLibEnums.h \
    $$PWD/libQtQmlTricks/core/macros/QmlEnumHelpers.h \
    $$PWD/libQtQmlTricks/core/macros/QmlPropertyHelpers.h \
    $$PWD/libQtQmlTricks/core/models/QQmlObjectListModel.h \
    $$PWD/libQtQmlTricks/gui/containers/QQmlContainerEnums.h \
    $$PWD/libQtQmlTricks/gui/containers/QQuickAbstractContainerBase.h \
    $$PWD/libQtQmlTricks/gui/containers/QQuickColumnContainer.h \
    $$PWD/libQtQmlTricks/gui/containers/QQuickContainerAttachedObject.h \
    $$PWD/libQtQmlTricks/gui/containers/QQuickGridContainer.h \
    $$PWD/libQtQmlTricks/gui/containers/QQuickRowContainer.h \
    $$PWD/libQtQmlTricks/gui/helpers/QQuickExtraAnchors.h \
    $$PWD/libQtQmlTricks/QtQmlTricks.h \
    src/QtTdLibCommon.h \
    src/QtTdLibConnection.h \
    src/QtTdLibGlobal.h \
    src/QtTdLibAuth.h \
    src/QtTdLibChat.h \
    src/QtTdLibContent.h \
    src/QtTdLibFile.h \
    src/QtTdLibMessage.h \
    src/QtTdLibUser.h

RESOURCES += \
    $$PWD/qml.qrc \
    flags.qrc

OTHER_FILES += \
    $$PWD/$${TARGET}.desktop \
    $$PWD/icons/86x86/$${TARGET}.png \
    $$PWD/icons/108x108/$${TARGET}.png \
    $$PWD/icons/128x128/$${TARGET}.png \
    $$PWD/icons/172x172/$${TARGET}.png \
    $$PWD/rpm/$${TARGET}.yaml

target.files  = $${TARGET}
target.path   = /usr/bin
desktop.files = $$PWD/$${TARGET}.desktop
desktop.path  = /usr/share/applications
icon86.files  = $$PWD/icons/86x86/$${TARGET}.png
icon86.path   = /usr/share/icons/hicolor/86x86/apps
icon108.files = $$PWD/icons/108x108/$${TARGET}.png
icon108.path  = /usr/share/icons/hicolor/108x108/apps
icon128.files = $$PWD/icons/128x128/$${TARGET}.png
icon128.path  = /usr/share/icons/hicolor/128x128/apps
icon256.files = $$PWD/icons/256x256/$${TARGET}.png
icon256.path  = /usr/share/icons/hicolor/256x256/apps
INSTALLS     += target desktop icon86 icon108 icon128 icon256
