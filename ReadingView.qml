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
import QtWebKit 1.0

/*
            actionMenuModel : window.mailReadFlag ? [qsTr("Mark as unread")] : [qsTr("Mark as read")]
            actionMenuPayload: [0]

            onActionMenuTriggered: {
                if (selectedItem == 0) {
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
                toolbar: ReadingViewBottomBar {
                    progressBarText: reading.progressBarText
                    progressBarVisible: reading.progressBarVisible
                    progressBarPercentage: reading.progressBarPercentage
                }
*/


Page {
    id: container

    property string progressBarText: ""
    property bool progressBarVisible: false
    property real progressBarPercentage: 0
    property string uri;
    property bool downloadInProgress: false
    property bool openFlag: false
    property string saveLabel: qsTr("Save")
    property string openLabel: qsTr("Open")
    property string musicLabel: qsTr("Music")
    property string videoLabel: qsTr("Video")
    property string pictureLabel: qsTr("Picture")

    // @todo Remove if these are no longer relevant.
    property string attachmentSavedLabel: qsTr("Attachment saved.")
    property string downloadingAttachmentLabel: qsTr("Downloading Attachment...")
    property string downloadingContentLabel: qsTr("Downloading Content...")

    // Placeholder strings for I18n purposes.

    //: Message displayed when downloading an attachment.  Arg 1 is the name of the attachment.
    property string savingAttachmentLabel: qsTr("Saving %1")

    //: Attachment has been saved message, where arg 1 is the name of the attachment.
    property string attachmentHasBeenSavedLabel: qsTr("%1 saved")

    Connections {
        target: messageListModel
        onMessageDownloadCompleted: {
            window.mailHtmlBody = messageListModel.htmlBody(window.currentMessageIndex);
        }
    }

    Dialog {
        id: unsupportedFileFormat
        title: qsTr ("Warning")
        content: Item {
            anchors.fill: parent
            anchors.margins: 10
            Text {
                text: qsTr("File format is not supported.");
                color: theme.fontColorNormal
                wrapMode: Text.Wrap
            }
        }

        onAccepted: {}
    } 

/*
    ContextMenu {
        id: attachmentContextMenu
        property alias model: attachmentActionMenu.model
        content: ActionMenu {
            id: attachmentActionMenu
        onTriggered: {
            attachmentContextMenu.hide();
            if (index == 0)  // open attachment
            {
                openFlag = true;
                emailAgent.downloadAttachment(messageListModel.messageId(window.currentMessageIndex), uri);
            }
            else if (index == 1) // Save attachment
            {
                openFlag = false;
                emailAgent.downloadAttachment(messageListModel.messageId(window.currentMessageIndex), uri);
            }
        }
        Connections {
            target: emailAgent
            onAttachmentDownloadStarted: {
                downloadInProgress = true;
                progressBarText = downloadingAttachmentLabel;
                progressBarVisible = true;
            }

            onProgressUpdate: {
                progressBarPercentage = percent;
            }

            onAttachmentDownloadCompleted: {
                progressBarVisible = false;
                downloadInProgress = false;
                if (openFlag == true)
                {
                   var status = emailAgent.openAttachment(uri);
                   if (status == false)
                   {
                       unsupportedFileFormat.show();
                   }
                }
            }

        }
        }
    }  // end of attachmentContextMenu
*/

    Rectangle {
        id: fromRect
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width
        height: 43
        Image {
            anchors.fill: parent
            fillMode: Image.Tile
            source: "image://theme/email/bg_email details_l"
        }
        Row {
            spacing: 5
            height: 43
            anchors.left: parent.left
            anchors.leftMargin: 3
            anchors.topMargin: 1
            Text {
                width: subjectLabel.width
                text: qsTr("From:")
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignRight
            }
            EmailAddress {
                anchors.verticalCenter: parent.verticalCenter
                added: false
                emailAddress: window.mailSender
            }
        }
    }

    Rectangle {
        id: toRect
        anchors.top: fromRect.bottom
        anchors.topMargin: 1
        anchors.left: parent.left
        width: parent.width
        height: 43
        Image {
            anchors.fill: parent
            fillMode: Image.Tile
            source: "image://theme/email/bg_email details_l"
        }
        Row {
            spacing: 5
            height: 43
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 3
            Text {
                width: subjectLabel.width
                id: toLabel
                text: qsTr("To:")
                horizontalAlignment: Text.AlignRight
                anchors.verticalCenter: parent.verticalCenter
            }
            EmailAddress {
                //FIX ME: There is more then one mail Recipient
                anchors.verticalCenter: parent.verticalCenter
                emailAddress: mailRecipients[0]
            }
        }
    }

    Rectangle {
        id: subjectRect
        anchors.top: toRect.bottom
        anchors.left: parent.left
        width: parent.width
        anchors.topMargin: 1
        clip: true
        height: 43
        Image {
            anchors.fill: parent
            fillMode: Image.Tile
	    source: "image://theme/email/bg_email details_l"
        }
        Row {
            spacing: 5
            height: 43
            anchors.left: parent.left
            anchors.leftMargin: 3
            Text {
                id: subjectLabel
                text: qsTr("Subject:")
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                width: subjectRect.width - subjectLabel.width - 10
                text: window.mailSubject
                anchors.verticalCenter: parent.verticalCenter
                elide: Text.ElideRight
            }
        }
    }

    Rectangle {
        id: attachmentRect
        anchors.top: subjectRect.bottom
        anchors.topMargin: 1
        anchors.left: parent.left
        anchors.right: parent.right
        width: parent.width
        height: 41
        opacity: (window.numberOfMailAttachments > 0) ? 1 : 0
        AttachmentView {
            height: parent.height
            width: parent.width
            model: mailAttachmentModel

            onAttachmentSelected: {
                container.uri = uri;
                attachmentContextMenu.model = [openLabel, saveLabel];
                attachmentContextMenu.setPosition(mX, mY);
                attachmentContextMenu.show();
            }
        }
    }

    Rectangle {
        id: bodyTextArea
        anchors.top: (window.numberOfMailAttachments > 0) ? attachmentRect.bottom : subjectRect.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        border.width: 1
        border.color: "black"
        color: "white"
        Flickable {
            id: flick
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 2
            width: parent.width
            height: parent.height

            property variant centerPoint

            contentWidth: {
                return edit.paintedWidth;
            }
            contentHeight:  {
                return edit.paintedHeight;
            }
            clip: true
         
            function ensureVisible(r)
            {
                if (contentX >= r.x)
                    contentX = r.x;
                else if (contentX+width <= r.x+r.width)
                    contentX = r.x+r.width-width;
                if (contentY >= r.y)
                    contentY = r.y;
                else if (contentY+height <= r.y+r.height)
                    contentY = r.y+r.height-height;
            }

            TextEdit {
                id: edit
                anchors.left: parent.left
                anchors.leftMargin: 5
                width: flick.width
                height: flick.height
                focus: true
                wrapMode: TextEdit.Wrap
                //textFormat: TextEdit.RichText
                readOnly: true
                onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)
                text: window.mailBody
//                visible:  (window.mailHtmlBody == "")
            }

        }
    }

    tools: ToolBarLayout {
        ToolIcon { iconId: "toolbar-back"; onClicked: { pageStack.pop(); }  }
    }
}
