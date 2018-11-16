
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
    $$PWD/src/QtTdLibCommon.cpp \
    $$PWD/src/QtTdLibConnection.cpp \
    $$PWD/src/QtTdLibGlobal.cpp \
    $$PWD/src/QtTdLibAuth.cpp \
    $$PWD/src/QtTdLibChat.cpp \
    $$PWD/src/QtTdLibContent.cpp \
    $$PWD/src/QtTdLibFile.cpp \
    $$PWD/src/QtTdLibMessage.cpp \
    $$PWD/src/QtTdLibUser.cpp \
    $$PWD/src/TextFormatter.cpp

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
    $$PWD/src/QtTdLibCommon.h \
    $$PWD/src/QtTdLibConnection.h \
    $$PWD/src/QtTdLibGlobal.h \
    $$PWD/src/QtTdLibAuth.h \
    $$PWD/src/QtTdLibChat.h \
    $$PWD/src/QtTdLibContent.h \
    $$PWD/src/QtTdLibFile.h \
    $$PWD/src/QtTdLibMessage.h \
    $$PWD/src/QtTdLibUser.h \
    $$PWD/src/TextFormatter.h

RESOURCES += \
    $$PWD/qml.qrc \
    $$PWD/flags.qrc \
    $$PWD/icons.qrc \
    $$PWD/symbols.qrc \
    $$PWD/images.qrc

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
