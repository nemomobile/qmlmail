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
    id: root
    property variant overlay: null

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
                anchors.margins: 20
                spacing: 10
                Label {
                    font.weight: Font.Bold
                    text: qsTr("Account details")
                }
                Label {
                    text: qsTr("Account: %1").arg(emailAccount.description)
                }
                Label {
                    text: qsTr("Name: %1").arg(emailAccount.name)
                }
                Label {
                    text: qsTr("Email address: %1").arg(emailAccount.address)
                }
                Item {
                    width: 1
                    height: 20
                }
                Label {
                    text: qsTr("Receiving:")
                }
                Label {
                    text: qsTr("Server type: %1").arg(Settings.serviceName(emailAccount.recvType))
                }
                Label {
                    text: qsTr("Server address: %1").arg(emailAccount.recvServer)
                }
                Label {
                    text: qsTr("Port: %1").arg(emailAccount.recvPort)
                }
                Label {
                    text: qsTr("Security: %1").arg(Settings.encryptionName(emailAccount.recvSecurity))
                }
                Label {
                    text: qsTr("Username: %1").arg(emailAccount.recvUsername)
                }
                Item {
                    width: 1
                    height: 20
                }
                Label {
                    text: qsTr("Sending:")
                }
                Label {
                    text: qsTr("Server address: %1").arg(emailAccount.sendServer)
                }
                Label {
                    text: qsTr("Port: %1").arg(emailAccount.sendPort)
                }
                Label {
                    text: qsTr("Authentication: %1").arg(Settings.authenticationName(emailAccount.sendAuth))
                }
                Label {
                    text: qsTr("Security: %1").arg(Settings.encryptionName(emailAccount.sendSecurity))
                }
                Label {
                    text: qsTr("Username: %1").arg(emailAccount.sendUsername)
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
    Component {
        id: errorDialog
        ModalDialog {
            property variant settingsPage
            property string errorMessage
            property int errorCode
            rightButtonText: qsTr("OK")
            dialogTitle: qsTr("Error")
            contentLoader.sourceComponent: DialogText {
                text: qsTr("Error %1: %2").arg(errorCode).arg(errorMessage)
            }
            onDialogClicked: {
                dialogLoader.sourceComponent = undefined;
                settingsPage.state = "ManualScreen";
                loader.item.message = qsTr("Sorry, we can't automatically set up your account. Please fill in account details:");
            }
        }
    }

    // spinner overlay
    TopItem { id: topItem }
    Component {
        id: spinnerComponent
        Item {
            anchors.fill: parent
            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: 0.7
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                y: parent.height / 4
                font.pixelSize: theme_fontPixelSizeLarge
                color: "white"
                text: qsTr("Testing account configuration...")
            }
            Spinner {
                id: spinner
                spinning: true
                maxSpinTime: 3600000
            }
            MouseArea {
                anchors.fill: parent
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
            id: next
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 200
            height: 45
            anchors.margins: 10
            //color: "white"
            title: qsTr("Next")
            onClicked: {
                emailAccount.save();
                emailAccount.test();
                overlay = spinnerComponent.createObject(root);
                overlay.parent = topItem.topItem;
            }
            Connections {
                target: emailAccount
                onTestSucceeded: {
                    spinnerComponent.destroy();
                    settingsPage.state = "ConfirmScreen";
                }
                onTestFailed: {
                    spinnerComponent.destroy();
                    showModalDialog(errorDialog);
                    dialogLoader.item.settingsPage = settingsPage;
                    dialogLoader.item.errorMessage = emailAccount.errorMessage;
                    dialogLoader.item.errorCode = emailAccount.errorCode;
                    emailAccount.remove();
                }
            }
        }
        Button {
            anchors.left: next.right
            anchors.verticalCenter: parent.verticalCenter
            width: 200
            height: 45
            anchors.margins: 10
            //color: "white"
            title: qsTr("Manual Edit")
            onClicked: {
                    settingsPage.state = "ManualScreen";
                    loader.item.message = qsTr("Please fill in account details:");
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
