/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1
import MeeGo.Settings 0.1

Item {
    anchors.fill: parent
    Rectangle {
        anchors.fill: parent
        color: "#eaf6fb"
    }
    Flickable {
        clip: true
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: buttonBar.top
        contentWidth: content.width
        contentHeight: content.height
        flickableDirection: Flickable.VerticalFlick
        Item {
            width: settingsPage.width
            ControlGroup {
                id: content
                children: [
                Item { width: 1; height: 20; },
                TextControl {
                    label: qsTr("Account description:")
                    text: emailAccount.description
                    enabled: false
                    // hide this field for "other" type accounts
                    visible: emailAccount.preset != 0
                },
                TextControl {
                    label: qsTr("Your name:")
                    text: emailAccount.name
                    textInput.onTextChanged: emailAccount.name = text
                },
                TextControl {
                    label: qsTr("Email address:")
                    text: emailAccount.address
                    inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhEmailCharactersOnly
                    textInput.onTextChanged: emailAccount.address = text
                },
                PasswordControl {
                    label: qsTr("Password:")
                    text: emailAccount.password
                    textInput.onTextChanged: emailAccount.password = text
                },
                Item { width: 1; height: 40; }
                ]
            }
        }
    }
    Component {
        id: verifyCancel
        ModalDialog {
            property variant settingsPage
            leftButtonText: qsTr ("Yes")
            rightButtonText: qsTr ("No")
            dialogTitle: qsTr ("Discard changes")
            contentLoader.sourceComponent: DialogText {
                text: qsTr ("You have made changes to your settings, are you sure you want to cancel?")
            }

            onDialogClicked: {
                dialogLoader.sourceComponent = undefined;
                if (button == 1) {
                    settingsPage.state = settingsPage.getHomescreen();
                }
            }
        }
    }

    //FIXME use standard action bar here
    Rectangle {
        id: buttonBar
        anchors.bottom: parent.bottom
        width: parent.width
        height: 70
        color: "grey"
        Button {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 200
            height: 45
            anchors.margins: 10
            //color: "white"
            title: qsTr("Next")
            onClicked: {
                emailAccount.applyPreset();
                if (emailAccount.preset != 0) {
                    settingsPage.state = "DetailsScreen";
                } else {
                    settingsPage.state = "ManualScreen";
                    loader.item.message = qsTr("Please fill in account details:");
                }
            }
        }
        Button {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 200
            height: 45
            anchors.margins: 10
            //color: "white"
            title: qsTr("Cancel")
            onClicked: {
                showModalDialog(verifyCancel);
                dialogLoader.item.settingsPage = settingsPage;
            }
        }
    }
}
