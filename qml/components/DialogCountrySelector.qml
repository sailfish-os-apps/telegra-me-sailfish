import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import Nemo.Notifications 1.0;
import harbour.Telegrame 1.0;
import QtGraphicalEffects 1.0;
import "../components/InternationalPhoneCodes.js" as InternationalPhoneCodes;
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

    readonly property var countriesModel : {
        var ret = ([]);
        for (var i = 0; i < InternationalPhoneCodes.allCountries.length; ++i) {
            var tmp  = InternationalPhoneCodes.allCountries [i];
            ret.push ({
                          "name" : tmp [0].replace (/\s+\(.+\)/, ""),
                          "iso2" : tmp [1],
                          "code" : tmp [2],
                          "flag" : "qrc:///RegionFlags/png/%1.png".arg (tmp [1].toUpperCase ()),
                      });
        }
        return ret;
    }

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
                model: countriesModel; // use now TD_Global.countryCodes.list
                delegate: ListItem {
                    visible: (modelData ["name"].toLowerCase ().indexOf (inputFilter.value) >= 0 || modelData ["code"].indexOf (inputFilter.value) >= 0);
                    highlighted: (dlgCountries.code === modelData ["code"]);
                    implicitHeight: (layoutItem.height + layoutItem.anchors.margins * 2);
                    ExtraAnchors.horizontalFill: parent;
                    onClicked: {
                        dlgCountries.code = modelData ["code"];
                        dlgCountries.name = modelData ["name"];
                        dlgCountries.flag = modelData ["flag"];
                    }

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
                                source: modelData ["flag"];
                                fillMode: Image.PreserveAspectFit;
                                sourceSize: Qt.size (width, height);
                                asynchronous: false;
                                verticalAlignment: Image.AlignVCenter;
                                horizontalAlignment: Image.AlignHCenter;
                                anchors.fill: parent;
                            }
                        }
                        LabelFixed {
                            text: modelData ["name"];
                            anchors.verticalCenter: parent.verticalCenter;
                            Container.horizontalStretch: 1;
                        }
                        LabelFixed {
                            text: ("+" + modelData ["code"]);
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
