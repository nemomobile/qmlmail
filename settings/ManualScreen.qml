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
import "settings.js" as Settings

Item {
    property string message
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
            Column {
                id: content
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 10
                Item { width: 1; height: 20; }
                Text {
                    font.pixelSize: theme_fontPixelSizeLarge
                    font.weight: Font.Bold
                    text: message
                }
                ControlGroup {
                    title: qsTr("Receiving settings")
                    subtitle: qsTr("You may need to contact your email provider for these settings.")
                    children: [
                        Item { width: 1; height: 1; },   // spacer
                        DropDownControl {
                            label: qsTr("Server type")
                            dataList: Settings.serviceModel
                            selectedValue: Settings.serviceName(emailAccount.recvType)
                            onSelectionChanged: emailAccount.recvType = Settings.serviceCode(data)
                        },
                        TextControl {
                            label: qsTr("Server address")
                            text: emailAccount.recvServer
                            inputMethodHints: Qt.ImhNoAutoUppercase
                            textInput.onTextChanged: emailAccount.recvServer = text
                        },
                        TextControl {
                            label: qsTr("Port")
                            text: emailAccount.recvPort
                            inputMethodHints: Qt.ImhDigitsOnly
                            textInput.onTextChanged: emailAccount.recvPort = text
                        },
                        DropDownControl {
                            label: qsTr("Security")
                            dataList: Settings.encryptionModel
                            selectedValue: Settings.encryptionName(emailAccount.recvSecurity)
                            onSelectionChanged: emailAccount.recvSecurity = Settings.encryptionCode(data)
                        },
                        TextControl {
                            label: qsTr("Username")
                            text: emailAccount.recvUsername
                            inputMethodHints: Qt.ImhNoAutoUppercase
                            textInput.onTextChanged: emailAccount.recvUsername = text
                        },
                        PasswordControl {
                            label: qsTr("Password")
                            text: emailAccount.recvPassword
                            textInput.onTextChanged: emailAccount.recvPassword = text
                        },
                        Item { width: 1; height: 1; }   // spacer
                    ]
                }
                ControlGroup {
                    title: qsTr("Sending settings")
                    subtitle: qsTr("You may need to contact your email provider for these settings.")
                    children: [
                        Item { width: 1; height: 1; },   // spacer
                        TextControl {
                            label: qsTr("Server address")
                            text: emailAccount.sendServer
                            inputMethodHints: Qt.ImhNoAutoUppercase
                            textInput.onTextChanged: emailAccount.sendServer = text
                        },
                        TextControl {
                            label: qsTr("Port")
                            text: emailAccount.sendPort
                            inputMethodHints: Qt.ImhDigitsOnly
                            textInput.onTextChanged: emailAccount.sendPort = text
                        },
                        DropDownControl {
                            label: qsTr("Authentication")
                            dataList: Settings.authenticationModel
                            selectedValue: Settings.authenticationName(emailAccount.sendAuth)
                            onSelectionChanged: emailAccount.sendAuth = Settings.authenticationCode(data)
                        },
                        DropDownControl {
                            label: qsTr("Security")
                            dataList: Settings.encryptionModel
                            selectedValue: Settings.encryptionName(emailAccount.sendSecurity)
                            onSelectionChanged: emailAccount.sendSecurity = Settings.encryptionCode(data)
                        },
                        TextControl {
                            label: qsTr("Username")
                            text: emailAccount.sendUsername
                            inputMethodHints: Qt.ImhNoAutoUppercase
                            textInput.onTextChanged: emailAccount.sendUsername = text
                        },
                        PasswordControl {
                            label: qsTr("Password")
                            text: emailAccount.sendPassword
                            textInput.onTextChanged: emailAccount.sendPassword = text
                        },
                        Item { width: 1; height: 1; }   // spacer
                    ]
                }
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
                    settingsPage.state = settingsPage.getHomescreen()
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
            onClicked: settingsPage.state = "DetailsScreen"
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
