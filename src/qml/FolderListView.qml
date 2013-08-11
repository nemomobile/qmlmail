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

Page {
    id: folderListContainer

    Component.onCompleted: {
        mailFolderListModel.setAccountKey (currentMailAccountId);
        window.currentFolderId = emailAgent.inboxFolderId(currentMailAccountId);
        //window.folderListViewTitle = currentAccountDisplayName + " Inbox";
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

    PageHeader {
        id: pageHeader
        color: "#0066ff"
        text: currentAccountDisplayName + " " + currentFolderName

        BusyIndicator {
            visible: window.refreshInProgress
            running: window.refreshInProgress
            anchors.right: parent.right
            anchors.rightMargin: UiConstants.DefaultMargin
            anchors.verticalCenter: parent.verticalCenter
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                pageStack.openDialog(Qt.resolvedUrl("FolderSelectionDialog.qml"))
            }
        }
    }

    ViewPlaceholder {
        text: qsTr ("No messages in this folder")
        enabled: messageListView.count == 0
    }

    ListView {
        id: messageListView
        anchors.top: pageHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true
        cacheBuffer: height
        model: messageListModel

        footer: Item {
            id: getMoreMessageRect
            height: 90
            width: messageListView.width
            visible: messageListView.count < folderServerCount

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

        delegate: ListDelegate {
            id: dinstance
            x: UiConstants.DefaultMargin
            width: ListView.view.width - UiConstants.DefaultMargin * 2

            titleText: senderDisplayName != "" ? senderDisplayName : senderEmailAddress
            titleWeight: readStatus ? Font.Normal : Font.Bold
            subtitleText:  subject

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
                pageStack.openDialog(Qt.resolvedUrl("MessageContextMenu.qml"))
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
            pageStack.openSheet(Qt.resolvedUrl("ComposerSheet.qml"))
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
    }
}
