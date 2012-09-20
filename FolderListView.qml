/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import QtQuick 1.1
import com.nokia.meego 1.2
import org.nemomobile.email 0.1

Page {
    id: folderListContainer

    Component.onCompleted: {
        mailFolderListModel.setAccountKey (currentMailAccountId);
        window.currentFolderId = mailFolderListModel.inboxFolderId();
        //window.folderListViewTitle = currentAccountDisplayName + " " + mailFolderListModel.inboxFolderName();
        folderServerCount = mailFolderListModel.folderServerCount(window.currentFolderId);
        gettingMoreMessages = false;
    }

    property int dateSortKey: 1
    property int senderSortKey: 1
    property int subjectSortKey: 1
    property string chooseFolder: qsTr("Choose folder:")
    property string attachments: qsTr("Attachments")
    property bool gettingMoreMessages: false
    property bool inSelectMode: false
    property int numOfSelectedMessages: 0
    property int folderServerCount: 0

    Connections {
        target: emailAgent
        onSyncCompleted: {
            gettingMoreMessages = false;
        }
        onError: {
            gettingMoreMessages = false;
        }
        onRetrievalCompleted: {
            gettingMoreMessages = false;
        }
    }

    ListModel {
        id: toModel
    }

    ListModel {
        id: ccModel
    }

    ListModel {
        id: attachmentsModel
    }

    function isDraftFolder()
    {
        return false;
//        return folderListView.pageTitle.indexOf( qsTr("Drafts") ) != -1 ;
    }

    Menu {
        id: contextMenu

        MenuLayout {
            MenuItem {
                text: qsTr("Reply")
                onClicked: {
                    var newPage;
                    window.addPage (composer);
                    newPage = window.pageStack.currentPage;
                    newPage.composer.setMessageDetails(window.currentMessageIndex, false);
                    newPage.composer.setReplyFocus();
                }
            }
            MenuItem {
                text: qsTr("Reply to all")
                onClicked: {
                    var newPage;
                    window.addPage (composer);
                    newPage = window.pageStack.currentPage;
                    newPage.composer.setMessageDetails( window.currentMessageIndex, true);
                    newPage.composer.setReplyFocus();
                }
            }
            MenuItem {
                text: qsTr("Forward")
                onClicked: {
                    var newPage;
                    window.addPage (composer);
                    newPage = window.pageStack.currentPage;

                    var htmlBodyText = messageListModel.htmlBody(window.currentMessageIndex);
                    if (htmlBodyText != "")
                    {
                        window.composeInTextMode = false;
                        newPage.composer.setQuotedHtmlBody(qsTr("-------- Forwarded Message --------"), htmlBodyText)

                    }
                    else
                    {
                        window.composeInTextMode = true;
                        newPage.composer.quotedBody = "\n" + qsTr("-------- Forwarded Message --------") + messageListModel.quotedBody (window.currentMessageIndex);
                    }

                    newPage.composer.subject = qsTr("[Fwd: %1]").arg(messageListModel.subject (window.currentMessageIndex));
                    window.mailAttachments = messageListModel.attachments(window.currentMessageIndex);
                    mailAttachmentModel.init();
                    newPage.composer.attachmentsModel = mailAttachmentModel;
                    newPage.composer.setReplyFocus();
                }
            }
            MenuItem {
                text: qsTr("Delete")
                onClicked: {
                    if ( emailAgent.confirmDeleteMail())
                        pageStack.openDialog(Qt.resolvedUrl("ConfirmDeleteDialog.qml"))
                    else
                        emailAgent.deleteMessage (window.mailId);
                }
            }
            MenuItem {
                text: qsTr("Toggle read") // readStatus to set text?
                onClicked: {
                    if (window.mailReadFlag)
                    {
                        emailAgent.markMessageAsUnread (window.mailId);
                        window.mailReadFlag = 0;
                    }
                    else
                    {
                        emailAgent.markMessageAsRead (window.mailId);
                        window.mailReadFlag = 1;
                    }
                }
            }
        }
    }

    PageHeader {
        id: pageHeader
        color: "#0066ff"
        text: currentAccountDisplayName + " " + mailFolderListModel.inboxFolderName()
    }

    ListView {
        id: messageListView
        anchors.top: pageHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true

        Item {
            id: emptyMailboxView
            opacity: messageListView.count > 0 ? 0 : 1
            Text {
                id: noMessageText
                text: qsTr ("There are no messages in this folder.")
                anchors.centerIn: emptyMailboxView
                elide: Text.ElideRight
            }
        }

        model: messageListModel

        footer: Item {
            id: getMoreMessageRect
            height: 90
            width: parent.width
            visible: {
                if (messageListView.count < folderServerCount)
                    return true;
                else
                    return false;
            }
            Button {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                height: 45
                width: 300
                text: {
                     if(gettingMoreMessages)
                         return  qsTr("Getting more messages")
                     else
                         return  qsTr("Get more messages")
                }
                onClicked: {
                    gettingMoreMessages = true;
                    emailAgent.getMoreMessages(window.currentFolderId);
                }
            }
        }

        delegate: MouseArea {
            id: dinstance
            height: UiConstants.ListItemHeightSmall
            width: parent.width

            Text {
                id: senderText
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: UiConstants.DefaultMargin
                width: (parent.width * 2) / 3
                height: UiConstants.ListItemHeightSmall / 2
                text: senderDisplayName != "" ? senderDisplayName : senderEmailAddress
                font.bold: readStatus ? false : true
                anchors.bottomMargin: 4
                elide: Text.ElideRight
            }
            Text {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.rightMargin: UiConstants.DefaultMargin
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                text: Qt.formatDate(qDateTime);
            }
            Text {
                id: subjectText
                text: subject
                anchors.top: senderText.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: UiConstants.DefaultMargin
                anchors.rightMargin: UiConstants.DefaultMargin
                height: theme.listBackgroundPixelHeightTwo / 2
                elide: Text.ElideRight
            }

            // TODO: attachments icon, logic:
            // opacity: numberOfAttachments ? 1 : 0

            onClicked: {
                if (inSelectMode)
                {
                    if (selected)
                    {
                        messageListModel.deSelectMessage(index);
                        --folderListContainer.numOfSelectedMessages;
                    }
                    else
                    {
                        messageListModel.selectMessage(index);
                        ++folderListContainer.numOfSelectedMessages;
                    }
                }
                else
                {
                    window.mailId = messageId;
                    window.mailSubject = subject;
                    window.mailSender = sender;
                    window.mailTimeStamp = timeStamp;
                    window.mailBody = body;
                    window.mailQuotedBody = quotedBody;
                    window.mailHtmlBody = htmlBody;
                    window.mailAttachments = listOfAttachments;
                    window.numberOfMailAttachments = numberOfAttachments;
                    window.mailRecipients = recipients;
                    toListModel.init();
                    window.mailCc = cc;
                    ccListModel.init();
                    window.mailBcc = bcc;
                    bccListModel.init();
                    window.currentMessageIndex = index;
                    mailAttachmentModel.init();
                    emailAgent.markMessageAsRead (messageId);
                    window.mailReadFlag = true;

                    if ( isDraftFolder() )
                    {   window.editableDraft= true
        window.addPage(composer);
                    }
                    else
                        pageStack.push(Qt.resolvedUrl("ReadingView.qml"))

                }
            }
            onPressAndHold: {
                if (inSelectMode)
                    return;
                window.mailId = messageId;
                window.mailReadFlag = readStatus;
                window.currentMessageIndex = index;
                contextMenu.open();
            }
        }

        ScrollDecorator {
            flickableItem: parent
        }
    }

    tools: ToolBarLayout {
        ToolIcon { iconId: "toolbar-back"; onClicked: { pageStack.pop(); }  }
        ToolIcon { iconId: "toolbar-add"; onClicked: {
            mailAttachmentModel.clear();
            window.composeInTextMode = true;
            pageStack.push(Qt.resolvedUrl("ComposerView.qml"))
        } }
        ToolIcon { iconId: "icon-m-toolbar-refresh"; onClicked: {
            // TODO: a spinner in the PageHeader would be neat
            if (window.refreshInProgress == true) {
                emailAgent.cancelSync();
                window.refreshInProgress = false;
            } else {
                emailAgent.synchronize(window.currentMailAccountId);
                window.refreshInProgress = true;
            }
        } }
        ToolIcon { iconId: "toolbar-view-menu" ; onClicked: colorMenu.open(); }
    }
}
