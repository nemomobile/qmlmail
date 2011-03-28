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
    id: container
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom

    height: navigationBar.height
    width: scene.content.width

    ListModel {
        id: toModel
    }

    ListModel {
        id: ccModel
    }

    ListModel {
        id: attachmentsModel
    }

    Component {
        id: verifyDelete
        ModalDialog {
            leftButtonText: qsTr("Yes")
            rightButtonText: qsTr("Cancel")
            dialogTitle: qsTr ("Delete Email")
            contentLoader.sourceComponent: DialogText {
                text: qsTr ("Are you sure you want to delete this email?")
            }

            onDialogClicked: {
                dialogLoader.sourceComponent = undefined;
                if(button == 1)
                {
                    emailAgent.deleteMessage (scene.mailId);
                    scene.previousApplicationPage();
                }
            }
        }
    }

    function deleteMessage()
    {
        emailAgent.deleteMessage (scene.mailId);
        scene.previousApplicationPage();
    }

    function setMessageDetails (composer, messageID, replyToAll) {
        var dateline = qsTr ("On %1 %2 wrote:\n").arg(messageListModel.timeStamp (messageID)).arg(messageListModel.mailSender (messageID));

        composer.quotedBody = dateline + messageListModel.quotedBody (messageID);
        attachmentsModel.clear();
        composer.attachmentsModel = attachmentsModel;
        toModel.clear();
        toModel.append({"name": "", "email": messageListModel.mailSender(messageID)});
        composer.toModel = toModel;


        if (replyToAll == true)
        {
            ccModel.clear();
            var recipients = new Array();
            recipients = messageListModel.recipients(messageID);
            var idx;
            for (idx = 0; idx < recipients.length; idx++)
                ccModel.append({"name": "", "email": recipients[idx]});
            composer.ccModel = ccModel;
        }
   
        // "Re:" is not supposed to be translated as per RFC 2822 section 3.6.5
        // Internet Message Format - http://www.faqs.org/rfcs/rfc2822.html
        //
        // "If this is done, only one instance of the literal string
        // "Re: " ought to be used since use of other strings or more
        // than one instance can lead to undesirable consequences."
        // Also see: http://www.chemie.fu-berlin.de/outerspace/netnews/son-of-1036.html#5.4
        // FIXME: Also need to only add Re: if it isn't already in the subject
        // to prevent "Re: Re: Re: Re: " subjects.
        composer.subject = "Re: " + messageListModel.subject (messageID);  //i18n ok
    }

    BorderImage {
        id: navigationBar
        width: parent.width
        source: "image://theme/navigationBar_l"
    }
    Item {
        anchors.fill: parent

        ToolbarButton {
            id: composeButton
            anchors.left: parent.left
            anchors.top: parent.top
            iconName: "icns_export/icn_compose"
            onClicked: {
                var newPage;

                scene.addApplicationPage (composer);
                newPage = scene.currentApplication;
                attachmentsModel.clear();
                newPage.composer.attachmentsModel = attachmentsModel;
            }
        }
        Item {
            id: replyAndForwardButtonsRow
            anchors.left: composeButton.right
            anchors.top: parent.top
            height: parent.height
            width: parent.width - (composeButton.width * 2)
            Row {
                spacing: (scene.content.width - (composeButton.width * 5) - (division1.width * 2)) / 4
                height: parent.height
                Image {
                    id: division1
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height
                    source: "image://theme/email/div"
                }
                ToolbarButton {
                    id:replyButton
                    iconName: "icns_export/icn_reply"
                    onClicked: {
                        var newPage;

                        scene.addApplicationPage (composer);
                        newPage = scene.currentApplication;
                        setMessageDetails (newPage.composer, scene.currentMessageIndex, false);
                    }
                }

                ToolbarButton {
                    id:replyallButton
                    iconName: "icns_export/icn_replyall"
                    onClicked: {
                        var newPage;

                        scene.addApplicationPage (composer);
                        newPage = scene.currentApplication;
                        setMessageDetails (newPage.composer, scene.currentMessageIndex, true);
                    }
                }

                ToolbarButton {
                    id:forwardButton
                    iconName: "icns_export/icn_forward"
                    onClicked: {
                        var newPage;

                        scene.addApplicationPage (composer);
                        newPage = scene.currentApplication;

                        newPage.composer.quotedBody = qsTr("-------- Forwarded Message --------") + messageListModel.quotedBody (scene.currentMessageIndex);
                        newPage.composer.subject = qsTr("[Fwd: %1]").arg(messageListModel.subject (scene.currentMessageIndex));
                        newPage.composer.attachmentsModel = mailAttachmentModel;
                    }
                }
            }
        }
        Image {
            id: division2
            anchors.right: deleteButton.left
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            source: "image://theme/email/div"
        }

        ToolbarButton {
            id: deleteButton

            anchors.right: parent.right
            anchors.top: parent.top
            iconName: "icns_export/icn_delete"

            onClicked: {
                if (emailAgent.confirmDeleteMail()) {
                    showModalDialog(verifyDelete);
                } else {
                    deleteMessage();
                }
            }
        }
    }
}
