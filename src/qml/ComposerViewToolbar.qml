/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */


import QtQuick 2.0
import com.nokia.meego 2.0
import org.nemomobile.email 0.1

BorderImage {
    id: composerViewToolbar

    width: parent.width
    height: sendButton.height
    anchors.bottom: parent.bottom
    source: "image://theme/navigationBar_l"

    ToolbarButton {
        id: saveButton

        anchors.left: division1.right
        anchors.top: parent.top

        iconName: "document-save"

        onClicked: {

            var i;
            var message;

            composer.completeEmailAddresses ();

            //if this is a draft e-mail, the old draft needs to be deleted
            emailAgent.deleteMessage (window.mailId)

            message = messageComponent.createObject (composer);
            message.setFrom (mailAccountListModel.emailAddress(composer.fromEmail));

            var to = new Array ();
            for (i = 0; i < composer.toModel.count; i++) {
                to[i] = composer.toModel.get (i).email;
            }


            message.setTo (to);

            var cc = new Array ();
            for (i = 0; i < composer.ccModel.count; i++) {
                cc[i] = composer.ccModel.get (i).email;
            }
            message.setCc (cc);

            var bcc = new Array ();
            for (i = 0; i < composer.bccModel.count; i++) {
                bcc[i] = composer.bccModel.get (i).email;
            }
            message.setBcc (bcc);

            var att = new Array ();
            for (i = 0; i < composer.attachmentsModel.count; i++) {
                att[i] = composer.attachmentsModel.get (i).uri;
            }
            message.setAttachments (att);

            message.setSubject (composer.subject);
            message.setPriority (composer.priority);
            if (window.composeInTextMode)
                message.setBody (composer.textBody, true);
            else
                message.setBody (composer.htmlBody, false);


            message.saveDraft ();
            window.popPage ();
        }
    }

    ToolbarDivider {
        id: division2
        anchors.left: saveButton.right
        height: parent.height
    }

    ToolbarButton {
        id: addAttachmentButton
        anchors.left: division2.right
        iconName: "mail-addattachment"

        Component {
            id: addAttachment

            AppPage {
                id: addAttachmentPage
                //: Attach a file (e.g. music, video, photo) to the document being composed.
                pageTitle: qsTr("Attach a file")

                PageBackground {
                    contents: AddAttachmentView {
                        attachments: composer.attachmentsModel
                    }
                    toolbar: AddAttachmentToolbar {
                        id: toolbar
                        width: parent.width
                        anchors.bottom: parent.bottom
                        onOkay: {
                            window.popPage ();
                        }
                    }
                }
            }
        }

        onClicked: {
            window.addPage(addAttachment)
        }
    }

    ToolbarDivider {
        id: division3
        anchors.left: addAttachmentButton.right
        height: parent.height
    }

    ModalMessageBox {
        id: verifyCancel
        acceptButtonText: qsTr ("Yes")
        cancelButtonText: qsTr ("Cancel")
        title: qsTr ("Discard Email")
        text: qsTr ("Are you sure you want to discard this unsent email?")
        onAccepted: { window.popPage () }
    }
}
