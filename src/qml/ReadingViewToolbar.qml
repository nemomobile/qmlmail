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

Item {
    id: container

    height: navigationBar.height
    width: window.content.width

    property int buttonWidth: (parent.width - 4) / 5

    ListModel {
        id: toModel
    }

    ListModel {
        id: ccModel
    }

    ListModel {
        id: attachmentsModel
    }

    ModalDialog {
        id:verifyDelete
        showCancelButton: true
        showAcceptButton: true
        acceptButtonText: qsTr("OK")
        cancelButtonText: qsTr("Cancel")
        title: qsTr ("Delete Email")
        content: Item {
            id:confirmMsg
            anchors.fill: parent
            anchors.margins: 10

            Text {
                text: qsTr ("Are you sure you want to delete this email?")
                color:theme.fontColorNormal
                font.pixelSize: theme.fontPixelSizeLarge
                wrapMode: Text.Wrap
            }
        }
        onAccepted: {
            emailAgent.deleteMessage (window.mailId);
            window.popPage();
        }
    }

    function deleteMessage()
    {
        emailAgent.deleteMessage (window.mailId);
        window.popPage();
    }

    BorderImage {
        id: navigationBar
        width: parent.width
        source: "image://themedimage/widgets/common/action-bar/action-bar-background"
    }
    Item  {
        anchors.left: parent.left
        width: parent.width

        Item {
            id: composeButton
            width: (parent.width - 4) / 5

            ToolbarButton {
                anchors.horizontalCenter: composeButton.horizontalCenter
                iconName: "mail-compose"
                onClicked: {
                    var newPage;
                    window.composeInTextMode = true;    // default to text mode.
                    window.addPage (composer);
                    newPage = window.pageStack.currentPage;
                    attachmentsModel.clear();
                    newPage.composer.attachmentsModel = attachmentsModel;
                }
            }
        }
        Image {
            id: separator1
            anchors.left: composeButton.right
            source: "image://themedimage/widgets/common/action-bar/action-bar-separator"
        }

        Item {
            id: replyButton
            anchors.left: separator1.right
            width: (parent.width - 4) / 5
            ToolbarButton {
                anchors.horizontalCenter: replyButton.horizontalCenter
                iconName: "mail-reply"
                onClicked: {
                    var newPage;
                    window.addPage (composer);
                    newPage = window.pageStack.currentPage;
                    newPage.composer.setMessageDetails(window.currentMessageIndex, false);
                    newPage.composer.setReplyFocus();
		}
	    }
        }

        Image {
            id: separator2
            anchors.left: replyButton.right
            source: "image://themedimage/widgets/common/action-bar/action-bar-separator"
        }

        Item {
            id:replyallButton
            anchors.left: separator2.right
            width: (parent.width - 4) / 5
            ToolbarButton {
                anchors.horizontalCenter: replyallButton.horizontalCenter
                iconName: "mail-reply-all"
                onClicked: {
                    var newPage;
                    window.addPage (composer);
                    newPage = window.pageStack.currentPage;
                    newPage.composer.setMessageDetails(window.currentMessageIndex, true);
                    newPage.composer.setReplyFocus();
                }
            }
        }

        Image {
            id: separator3
            anchors.left: replyallButton.right
            source: "image://themedimage/widgets/common/action-bar/action-bar-separator"
        }

        Item {
            id:forwardButton
            anchors.left: separator3.right
            width: (parent.width - 4) / 5
            ToolbarButton {
                anchors.horizontalCenter: forwardButton.horizontalCenter
                iconName: "mail-forward"
                onClicked: {
                    var newPage;
                    window.addPage (composer);
                    newPage = window.pageStack.currentPage;

                    if (window.mailHtmlBody != "")
                    {
                        window.composeInTextMode = false;
                        newPage.composer.setQuotedHtmlBody(qsTr("-------- Forwarded Message --------"), window.mailHtmlBody)
                    }
                    else
                    {
                        window.composeInTextMode = true;
                        newPage.composer.quotedBody = "\n" + qsTr("-------- Forwarded Message --------") + 
                                                messageListModel.quotedBody (window.currentMessageIndex);
                    }

                    newPage.composer.subject = qsTr("[Fwd: %1]").arg(messageListModel.subject (window.currentMessageIndex));
                    newPage.composer.attachmentsModel = mailAttachmentModel;
                    newPage.composer.setReplyFocus();
                }
            }
        }

        Image {
            id: separator4
            anchors.left: forwardButton.right
            source: "image://themedimage/widgets/common/action-bar/action-bar-separator"
        }

        Item {
            id: deleteButton
            anchors.left: separator4.right
            width: (parent.width - 4) / 5
            ToolbarButton {
                anchors.horizontalCenter: deleteButton.horizontalCenter
                iconName: "edit-delete"

                onClicked: {
                    if (emailAgent.confirmDeleteMail()) {
                        verifyDelete.show();
                    } else {
                        deleteMessage();
                    }
                }
            }
        }
    }
}
