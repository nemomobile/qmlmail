/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import QtQuick 1.1
import com.nokia.meego 1.1
import org.nemomobile.email 0.1

Column {
    id: header

    property alias subject: subjectEntry.text
    property int fromEmail: 0

    property alias toModel: toRecipients.model
    property variant ccModel
    property variant bccModel // stubs so we don't get errors
    property alias attachmentsModel: attachmentBar.model
    property EmailAccountListModel accountsModel
    property variant emailAccountList: []
    property int priority: EmailMessage.NormalPriority

    focus: true

    spacing: 5

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
        onAccountAdded: {
            emailAccountList = accountsModel.getAllEmailAddresses();
            if (window.currentMailAccountIndex == -1)
            {
                window.currentMailAccountIndex = 0;
                fromEmail = 0
                accountSelectorDialog.selectedIndex = 0;
            }
        }
    }

    Component.onCompleted: {
        emailAccountList = accountsModel.getAllEmailAddresses();
        fromEmail = window.currentMailAccountIndex;
        console.log(emailAccountList)
    }

    // EmailAccountListModel doesn't seem to be a real ListModel
    // We need to convert it to one to set it in the DropDown
    onAccountsModelChanged: {
        emailAccountList = accountsModel.getAllEmailAddresses();
        fromEmail = window.currentMailAccountIndex;
    }

    Row {
        width: parent.width
        anchors.left: fromLabel.right
        height: 50
        spacing: UiConstants.DefaultMargin
        z: 1000

    Text {
        id: fromLabel
        text: qsTr ("From:")
        height: 50

        verticalAlignment: Text.AlignVCenter
    }

        Button {
            id: accountSelector
            text: emailAccountList[fromEmail]
            anchors.verticalCenter: parent.verticalCenter
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
    }

    Row {
        //: The "to" recipient label.
        property string toLabel: qsTr("To")

        width: parent.width

        spacing: 5

        // Expand to fill the height correctly
        height: toRecipients.height

        EmailRecipientEntry {
            id: toRecipients

            defaultText: parent.toLabel
            width: parent.width - toAddButton.width - 20 - spacing
        }

        AddRecipient {
            id: toAddButton
            label: parent.toLabel
            recipients: toRecipients
        }
    }

    // TODO: CC/BCC needs working into the UI somehow.

    TextField {
        id: subjectEntry
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: UiConstants.DefaultMargin

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

