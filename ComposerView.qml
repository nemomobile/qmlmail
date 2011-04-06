/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1
import MeeGo.App.Email 0.1

Item {
    id: composerViewContainer

    property alias composer: composer
    parent: composerPage.content
    width: scene.content.width
    height: parent.height

    ListModel {
        id: toRecipients
    }

    ListModel {
        id: ccRecipients
    }

    ListModel {
        id: bccRecipients
    }

    ListModel {
        id: attachments
    }

    Composer {
        id: composer

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: composerViewToolbar.top

        toModel: toRecipients
        ccModel: ccRecipients
        bccModel: bccRecipients
        attachmentsModel: mailAttachmentModel
        accountsModel: mailAccountListModel
    }

    BorderImage {
        id: composerViewToolbar

        width: parent.width
        anchors.bottom: parent.bottom
        source: "image://theme/navigationBar_l"

        ToolbarButton {
            id: sendButton

            anchors.left: parent.left
            anchors.top: parent.top

            iconName: "mail-send"

            onClicked: {
                var i;
                var message;

                console.log ("Send email");

                composer.completeEmailAddresses ();

                message = messageComponent.createObject (composer);
                message.setFrom (composer.fromEmail);

                console.log ("From: " + composer.fromEmail);

                var to = new Array ();
                for (i = 0; i < composer.toModel.count; i++) {
                    to[i] = composer.toModel.get (i).email;
                    console.log (" to: " + to[i]);
                }
                message.setTo (to);

                var cc = new Array ();
                for (i = 0; i < composer.ccModel.count; i++) {
                    cc[i] = composer.ccModel.get (i).email;
                    console.log (" cc: " + cc[i]);
                }
                message.setCc (cc);

                var bcc = new Array ();
                for (i = 0; i < composer.bccModel.count; i++) {
                    bcc[i] = composer.bccModel.get (i).email;
                    console.log (" bcc: " + bcc[i]);
                }
                message.setBcc (bcc);

                var att = new Array ();
                for (i = 0; i < composer.attachmentsModel.count; i++) {
                    att[i] = composer.attachmentsModel.get (i).uri;
                    console.log (" attachment: " + att[i]);
                }
                message.setAttachments (att);

                console.log ("Subject: " + composer.subject);
                message.setSubject (composer.subject);

                console.log ("Priority: " + composer.priority);
                message.setPriority (composer.priority);

                console.log (composer.body);
                message.setBody (composer.body);

                message.send ();
                scene.previousApplicationPage ();
            }
        }

        ToolbarDivider {
            id: division1
            anchors.left: sendButton.right
            height: parent.height
        }

        /*ToolbarButton {
            id: saveButton

            anchors.left: division1.right
            anchors.top: parent.top

            iconName: "document-save"

            onClicked: {
                console.log ("Save email");
            }
        }

        ToolbarDivider {
            id: division2
            anchors.left: saveButton.right
            height: parent.height
        }*/

        ToolbarDivider {
            id: division3
            anchors.right: cancelButton.left
            height: parent.height
        }

        ToolbarButton {
            id: cancelButton

            anchors.right: parent.right
            anchors.top: parent.top

            iconName: "edit-delete"

            onClicked: {
                showModalDialog (verifyCancel);
            }
        }
    }

    Component {
        id: messageComponent

        EmailMessage {
            id: emailMessage
        }
    }

    Component {
        id: verifyCancel
        ModalDialog {
            leftButtonText: qsTr ("Yes")
            rightButtonText: qsTr ("Cancel")
            dialogTitle: qsTr ("Discard Email")
            contentLoader.sourceComponent: DialogText {
                text: qsTr ("Are you sure you want to discard this unsent email?")
            }

            onDialogClicked: {
                dialogLoader.sourceComponent = undefined;
                if (button == 1) {
                    scene.previousApplicationPage ();
                }
            }
        }
    }
}
