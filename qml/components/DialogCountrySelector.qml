import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import Nemo.Notifications 1.0;
import harbour.Telegrame 1.0;
import QtGraphicalEffects 1.0;
import "../components";

Dialog {
    id: dlgCountries;
    onDone: {
        if (result == DialogResult.Accepted) {
            //
        }
    }

    property string code  : "";
    property string flag  : "";
    property string name  : "";

    DialogHeader {
        id: headerDialCode;
        title: qsTr ("Select country/region");
        ExtraAnchors.topDock: parent;
    }
    TextField {
        id: inputFilter;
        placeholderText: qsTr ("Filter...");
        anchors {
            top: headerDialCode.bottom;
            margins: Theme.paddingSmall;
        }
        ExtraAnchors.horizontalFill: parent;

        readonly property string value : (text.trim ().toLowerCase ());
    }
    SilicaFlickable {
        clip: true;
        quickScroll: true;
        contentWidth: width;
        contentHeight: layoutCountries.height;
        anchors.top: inputFilter.bottom;
        ExtraAnchors.bottomDock: parent;

        ColumnContainer {
            id: layoutCountries;
            ExtraAnchors.topDock: parent;

            Repeater {
                model: TD_Global.countryCodes.list
                delegate: ListItem {
                    id: delegate;
                    visible: country.match (inputFilter.value);
                    highlighted: (dlgCountries.code === country.code);
                    implicitHeight: (layoutItem.height + layoutItem.anchors.margins * 2);
                    ExtraAnchors.horizontalFill: parent;
                    onClicked: {
                        dlgCountries.code = country.code
                        dlgCountries.name = country.name;
                        dlgCountries.flag = country.flag;
                    }

                    readonly property CountryCodesModelItem country : modelData;

                    RowContainer {
                        id: layoutItem;
                        spacing: Theme.paddingMedium;
                        anchors {
                            margins: Theme.paddingMedium;
                            verticalCenter: parent.verticalCenter;
                        }
                        ExtraAnchors.horizontalFill: parent;

                        Item {
                            implicitWidth: Theme.iconSizeMedium;
                            implicitHeight: Theme.iconSizeMedium;
                            anchors.verticalCenter: parent.verticalCenter;

                            Image {
                                cache: true;
                                source: delegate.country.flag;
                                fillMode: Image.PreserveAspectFit;
                                sourceSize: Qt.size (width, height);
                                asynchronous: true;
                                verticalAlignment: Image.AlignVCenter;
                                horizontalAlignment: Image.AlignHCenter;
                                anchors.fill: parent;
                            }
                        }
                        LabelFixed {
                            text: delegate.country.name;
                            anchors.verticalCenter: parent.verticalCenter;
                            Container.horizontalStretch: 1;
                        }
                        LabelFixed {
                            text: ("+" + delegate.country.code);
                            opacity: 0.65;
                            anchors.verticalCenter: parent.verticalCenter;
                        }
                    }
                }
            }
        }
        VerticalScrollDecorator { flickable: parent; }
    }
}
