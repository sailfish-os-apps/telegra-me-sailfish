import QtQuick 2.6;
import QtQmlTricks 3.0;
import Sailfish.Silica 1.0;
import harbour.Telegrame 1.0;
import "../components";

Page {
    id: page;
    allowedOrientations: Orientation.All;

    SilicaListView {
        id: flickerContacts;
        anchors.fill: parent;
        model: TD_Global.sortedContactsList;
        section {
            property: "firstName";
            criteria: ViewSection.FirstCharacter;
            delegate: SectionHeader {
                text: section;
            }
        }
        header: Item {
            implicitHeight: headerContacts.height;
            ExtraAnchors.horizontalFill: parent;
        }
        delegate: ListItem {
            id: delegateContact;
            ExtraAnchors.horizontalFill: parent;
            onClicked: {
                pageStack.push (compoPageUserInfo, {
                                    "userItem" : userItem,
                                });
            }

            readonly property TD_User userItem : modelData;

            RowContainer {
                id: layout;
                spacing: Theme.paddingMedium;
                anchors {
                    margins: Theme.paddingMedium;
                    verticalCenter: parent.verticalCenter;
                }
                ExtraAnchors.horizontalFill: parent;

                DelegateAvatar {
                    id: ico;
                    size: Theme.iconSizeMedium;
                    fileItem: (delegateContact.userItem && delegateContact.userItem.profilePhoto
                               ? delegateContact.userItem.profilePhoto.big
                               : null);
                    anchors.verticalCenter: parent.verticalCenter;
                }
                LabelFixed {
                    id: lbl;
                    text: (delegateContact.userItem ? delegateContact.userItem.firstName + " " + delegateContact.userItem.lastName : "");
                    anchors.verticalCenter: parent.verticalCenter;
                    Container.horizontalStretch: 1;
                }
            }
        }

        PullDownMenu {
            id: pulleyTop;

            MenuItem {
                text: qsTr ("Add contact...");
                onClicked: {
                    pageStack.push (compoDlgNewContact, { });
                }

                Component {
                    id: compoDlgNewContact;

                    Dialog {
                        id: dlgNewContact;
                        onDone: {
                            if (result === DialogResult.Accepted) {
                                TD_Global.send ({
                                                    "@type"    : "importContacts",
                                                    "contacts" : [
                                                        {

                                                            "@type"        : "contact",
                                                            "first_name"   : inputContactFirstName.text.trim (),
                                                            "last_name"    : inputContactLastName.text.trim (),
                                                            "phone_number" : inputContactPhoneNumber.text.trim (),
                                                        }
                                                    ]
                                                });
                            }
                            else { }
                        }

                        ColumnContainer {
                            spacing: Theme.paddingSmall;
                            ExtraAnchors.topDock: parent;

                            DialogHeader {
                                implicitHeight: (dlgNewContact.isPortrait ? Theme.itemSizeLarge : Theme.itemSizeSmall);
                                ExtraAnchors.horizontalFill: parent;
                            }
                            Item {
                                ExtraAnchors.horizontalFill: parent;
                                Container.forcedHeight: Theme.paddingLarge;
                            }
                            LabelFixed {
                                text: qsTr ("Add contact");
                                color: Theme.highlightColor;
                                font {
                                    family: Theme.fontFamilyHeading;
                                    pixelSize: Theme.fontSizeLarge;
                                }
                                anchors.margins: Theme.paddingLarge;
                                ExtraAnchors.horizontalFill: parent;
                            }
                            Item {
                                ExtraAnchors.horizontalFill: parent;
                                Container.forcedHeight: Theme.paddingLarge;
                            }
                            TextField {
                                id: inputContactFirstName;
                                label: qsTr ("First name");
                                placeholderText: label;
                                ExtraAnchors.horizontalFill: parent;
                            }
                            TextField {
                                id: inputContactLastName;
                                label: qsTr ("Last name");
                                placeholderText: label;
                                ExtraAnchors.horizontalFill: parent;
                            }
                            TextField {
                                id: inputContactPhoneNumber;
                                label: qsTr ("Phone number");
                                inputMethodHints: Qt.ImhDialableCharactersOnly;
                                placeholderText: label;
                                ExtraAnchors.horizontalFill: parent;
                            }
                        }
                    }
                }
            }
        }
    }
    VerticalScrollDecorator {
        flickable: flickerContacts;
    }
    PanelFixed {
        id: headerContacts;
        opacity: (pulleyTop.active ? 0.65 : 1.0);
        implicitHeight: (title.height + title.anchors.margins * 2);
        anchors.topMargin: Math.max (-flickerContacts.contentY - height, 0);
        ExtraAnchors.topDock: parent;

        Rectangle {
            color: Theme.rgba (Theme.secondaryHighlightColor, 0.65);
            visible: flickerContacts.atYBeginning;
            implicitHeight: Theme.paddingSmall;
            ExtraAnchors.topDock: parent;
        }
        LabelFixed {
            id: title;
            text: qsTr ("All contacts");
            color: Theme.highlightColor;
            font {
                family: Theme.fontFamilyHeading;
                pixelSize: Theme.fontSizeLarge;
            }
            anchors {
                right: parent.right
                margins: Theme.paddingLarge;
                verticalCenter: parent.verticalCenter;
            }
        }
    }
}
