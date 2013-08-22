import QtQuick 2.0
import com.nokia.meego 2.0

Menu {
    id: contextMenu

    MenuLayout {
        MenuItem {
            text: qsTr("Reply")
            onClicked: {
                var composer = pageStack.openSheet(Qt.resolvedUrl("ComposerSheet.qml"))
                composer.setMessageDetails(window.currentMessageIndex, false);
                composer.setReplyFocus();
            }
        }
        MenuItem {
            text: qsTr("Reply to all")
            onClicked: {
                var composer = pageStack.openSheet(Qt.resolvedUrl("ComposerSheet.qml"))
                composer.setMessageDetails( window.currentMessageIndex, true);
                composer.setReplyFocus();
            }
        }
        MenuItem {
            text: qsTr("Forward")
            onClicked: {
                var composer = pageStack.openSheet(Qt.resolvedUrl("ComposerSheet.qml"))

                var htmlBodyText = messageListModel.htmlBody(window.currentMessageIndex);
                if (htmlBodyText != "") {
                    window.composeInTextMode = false;
                    composer.setQuotedHtmlBody(qsTr("-------- Forwarded Message --------"), htmlBodyText)
                } else {
                    window.composeInTextMode = true;
                    composer.quotedBody = "\n" + qsTr("-------- Forwarded Message --------") + messageListModel.quotedBody (window.currentMessageIndex);
                }

                composer.subject = qsTr("[Fwd: %1]").arg(messageListModel.subject (window.currentMessageIndex));
                window.mailAttachments = messageListModel.attachments(window.currentMessageIndex);
                mailAttachmentModel.init();
                composer.attachmentsModel = mailAttachmentModel;
                composer.setReplyFocus();
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

