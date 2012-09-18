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

    function setMessageDetails (composer, messageID, replyToAll) {
        var dateline = qsTr ("On %1 %2 wrote:").arg(messageListModel.timeStamp (messageID)).arg(messageListModel.mailSender (messageID));

        var htmlBodyText = messageListModel.htmlBody(window.currentMessageIndex);
        if (htmlBodyText != "")
        {
            // set the composer to edit in html mode
            window.composeInTextMode = false;
            composer.setQuotedHtmlBody(dateline,htmlBodyText)
        }
        else
        {
            window.composeInTextMode = true;
            composer.quotedBody = "\n" + dateline + "\n" + messageListModel.quotedBody (messageID); //i18n ok
        }

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

    function isDraftFolder()
    {
        return false;
//        return folderListView.pageTitle.indexOf( qsTr("Drafts") ) != -1 ;
    }

    Sheet {
        id: verifyDelete
        acceptButtonText: qsTr ("Yes")
        rejectButtonText: qsTr ("Cancel")
        title: qsTr ("Delete Email")
        content: Text {
            text: qsTr ("Are you sure you want to delete this email?")
        }

        onAccepted: { emailAgent.deleteMessage (window.mailId) }
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
                    setMessageDetails (newPage.composer, window.currentMessageIndex, false);
                    newPage.composer.setReplyFocus();
                }
            }
            MenuItem {
                text: qsTr("Reply to all")
                onClicked: {
                    var newPage;
                    window.addPage (composer);
                    newPage = window.pageStack.currentPage;
                    setMessageDetails (newPage.composer, window.currentMessageIndex, true);
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
                        verifyDelete.open();
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
                color:theme.fontColorNormal
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

            Item {
                id: fromLine
                anchors.top: parent.top
                anchors.left: parent.left
                width: parent.width
                height: UiConstants.ListItemHeightSmall / 2

                Text {
                    id: senderText
                    anchors.left: parent.left
                    anchors.leftMargin: UiConstants.DefaultMargin
                    width: (parent.width * 2) / 3
                    text: senderDisplayName != "" ? senderDisplayName : senderEmailAddress
                    font.bold: readStatus ? false : true
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                    elide: Text.ElideRight
                }
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: UiConstants.DefaultMargin
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                    text: Qt.formatDate(qDateTime);
                }
            }
            Item {
                id: subjectLine
                anchors.top: fromLine.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: UiConstants.DefaultMargin
                anchors.rightMargin: UiConstants.DefaultMargin
                height: theme.listBackgroundPixelHeightTwo / 2

                Text {
                    id: subjectText
                    text: subject
                    anchors.left: parent.left
                    anchors.right: parent.right
                    elide: Text.ElideRight
                }

                // TODO: attachments icon, logic:
                // opacity: numberOfAttachments ? 1 : 0
            }

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
                contextMenu.show();
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
        ToolIcon { iconId: "toolbar-view-menu" ; onClicked: colorMenu.open(); }
    }
}
