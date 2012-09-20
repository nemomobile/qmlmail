import QtQuick 1.1
import com.nokia.meego 1.2

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
                if (htmlBodyText != "") {
                    window.composeInTextMode = false;
                    newPage.composer.setQuotedHtmlBody(qsTr("-------- Forwarded Message --------"), htmlBodyText)
                } else {
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
                if (window.mailReadFlag) {
                    emailAgent.markMessageAsUnread (window.mailId);
                    window.mailReadFlag = 0;
                } else {
                    emailAgent.markMessageAsRead (window.mailId);
                    window.mailReadFlag = 1;
                }
            }
        }
    }
}

