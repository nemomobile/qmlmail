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
    id: container

    Connections {
        target: messageListModel
        onMessageDownloadCompleted: {
            window.mailHtmlBody = messageListModel.htmlBody(window.currentMessageIndex);
        }
    }

    Flickable {
        id: flick
        anchors.fill: parent

        contentWidth: childrenRect.width
        contentHeight: contentItem.childrenRect.height

        Rectangle {
            id: fromRect
            width: flick.width
            height: 43

            Row {
                spacing: 5
                height: 43
                anchors.left: parent.left
                anchors.leftMargin: 3
                anchors.topMargin: 1
                Label {
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
            width: flick.width
            height: 43

            Row {
                spacing: 5
                height: 43
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: 3
                Label {
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
            width: flick.width
            anchors.topMargin: 1
            clip: true
            height: 43

            Row {
                spacing: 5
                height: 43
                anchors.left: parent.left
                anchors.leftMargin: 3
                Label {
                    id: subjectLabel
                    text: qsTr("Subject:")
                    anchors.verticalCenter: parent.verticalCenter
                }
                Label {
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
            width: flick.width
            height: 41
            opacity: (window.numberOfMailAttachments > 0) ? 1 : 0
            AttachmentView {
                height: parent.height
                width: parent.width
                model: mailAttachmentModel

                onAttachmentSelected: {
                    var dialog = pageStack.openDialog(Qt.resolvedUrl("AttachmentDownloadDialog.qml"))
                    dialog.uri = uri;
                }
            }
        }

        TextArea {
            id: edit
            anchors.top: (window.numberOfMailAttachments > 0) ? attachmentRect.bottom : subjectRect.bottom
            anchors.topMargin: UiConstants.DefaultMargin
            anchors.left: parent.left
            anchors.leftMargin: UiConstants.DefaultMargin
            width: flick.width - (UiConstants.DefaultMargin * 2)
            wrapMode: TextEdit.Wrap
            readOnly: true
            text: window.mailBody
        }

    }

    ScrollDecorator {
        flickableItem: flick
    }

    tools: ToolBarLayout {
        ToolIcon { iconId: "toolbar-back"; onClicked: { pageStack.pop(); }  }
        ToolIcon { iconId: "toolbar-view-menu" ; onClicked: pageStack.openDialog(Qt.resolvedUrl("MessageContextMenu.qml")) }
    }
}
