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

Column {
    id: header

    property alias subject: subjectEntry.text
    property int fromEmail: 0

    spacing: UiConstants.DefaultMargin

    property alias toModel: toRecipients.model
    property variant ccModel
    property variant bccModel // stubs so we don't get errors
    property alias attachmentsModel: attachmentBar.model
    property EmailAccountListModel accountsModel
    property variant emailAccountList: []
    property int priority: EmailMessage.NormalPriority

    focus: true

    /*
    ModalContextMenu {
        id: ctxAttachmentMenuAction
        property int indexTapAndHeld: -1

        content:  ActionMenu {
            id: ctxAttachment
            model: [ qsTr("Delete") ]
            onTriggered:{
                header.attachmentsModel.remove(ctxAttachmentMenuAction.indexTapAndHeld)
                ctxAttachmentMenuAction.hide()
            }
        }
    }
*/

    function completeEmailAddresses () {
        toRecipients.complete ();
    }

    Connections {
        target: mailAccountListModel
        onAccountsAdded: {
            emailAccountList = accountsModel.allEmailAddresses();
            if (window.currentMailAccountIndex == -1)
            {
                window.currentMailAccountIndex = 0;
                fromEmail = 0
                accountSelectorDialog.selectedIndex = 0;
            }
        }
    }

    Component.onCompleted: {
        emailAccountList = accountsModel.allEmailAddresses();
        fromEmail = window.currentMailAccountIndex;
        console.log(emailAccountList)
    }

    // EmailAccountListModel doesn't seem to be a real ListModel
    // We need to convert it to one to set it in the DropDown
    onAccountsModelChanged: {
        emailAccountList = accountsModel.allEmailAddresses();
        fromEmail = window.currentMailAccountIndex;
    }

    Button {
        id: accountSelector
        text: emailAccountList[fromEmail]
        iconSource: "image://theme/icon-m-toolbar-send-sms"
        anchors.left: parent.left
        anchors.right: parent.right

        onClicked: {
            accountSelectorDialog.open();
        }

        SelectionDialog {
            id: accountSelectorDialog
            model: emailAccountList
            titleText: qsTr("Select account")

            Component.onCompleted: {
                selectedIndex = window.currentMailAccountIndex;;
            }

            onSelectedIndexChanged: {
                fromEmail = selectedIndex
            }
        }
    }

    EmailRecipientEntry {
        id: toRecipients
        width: parent.width
    }

    // TODO: CC/BCC needs working into the UI somehow.

    TextField {
        id: subjectEntry
        width: parent.width

        placeholderText: qsTr ("Enter subject here")
    }

/*
        Image {
            id: priorityButton
            source: "image://theme/email/btn_priority_up"
            height: parent.height
            fillMode: Image.PreserveAspectFit

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    var map = mapToItem(topItem.topItem, mouseX, mouseY);
                    priorityContextMenu.setPosition(map.x, map.y)

                    if (priority == EmailMessage.NormalPriority)
                        priorityContextMenu.content[0].selectedIndex = 1   // model[1]
                    else if (priority == EmailMessage.LowPriority)
                        priorityContextMenu.content[0].selectedIndex = 2   // model[2]
                    else
                        priorityContextMenu.content[0].selectedIndex = 0   // model[0]

                    console.log("Priority context menu selected index: " + priorityContextMenu.content[0].selectedIndex)

                    priorityContextMenu.show()
                }
            }

            ContextMenu {
                id: priorityContextMenu

                content: ActionMenu {
                    id: actionMenu

                    property string lowText:    qsTr("Low Priority")
                    property string normalText: qsTr("Normal Priority")
                    property string highText:   qsTr("High Priority")

                    model: [ highText, normalText, lowText ]
                    payload: [ EmailMessage.HighPriority,
                        EmailMessage.NormalPriority,
                        EmailMessage.LowPriority ]

                    highlightSelectedItem: true

                    onTriggered: {
                        priority = payload[index]

                        console.log("Message priority set to: " + priority)

                        priorityContextMenu.hide()
                    }
                }
            }
        }
*/

    AttachmentView {
        id: attachmentBar
        width: parent.width - 20
        height: 41
        opacity: (model.count > 0) ? 1 : 0

        onAttachmentSelected:{

            ctxAttachmentMenuAction.x=mX
            ctxAttachmentMenuAction.y=mY
            ctxAttachmentMenuAction.indexTapAndHeld= mIndex
            ctxAttachmentMenuAction.show()
        }
    }
}

