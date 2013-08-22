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

    signal topicTriggered(int index)
    property alias currentTopic: listView.currentIndex
    property alias interactive: listView.interactive
    property alias model: listView.model

    PageHeader {
        id: pageHeader
        color: "#0066ff"
        text: "Mail"

        BusyIndicator {
            visible: window.refreshInProgress
            running: window.refreshInProgress
            anchors.right: parent.right
            anchors.rightMargin: UiConstants.DefaultMargin
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    ViewPlaceholder {
        text: "No accounts configured"
        enabled: listView.count == 0
    }

    ListView {
        id: listView
        anchors.top: pageHeader.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        clip: true
        model: mailAccountListModel

        onCurrentIndexChanged: container.topicTriggered(currentIndex)

        delegate: ListDelegate {
            id: accountItem
            x: UiConstants.DefaultMargin
            width: ListView.view.width - UiConstants.DefaultMargin * 2

            Component.onCompleted: {
                if (index == 0) {
                    window.currentAccountDisplayName = displayName;
                    window.currentMailAccountId = mailAccountId;
                }
            }

            titleText: emailAddress + " - " + displayName  //i18n ok

            CountBubble {
                id: unreadImage
                anchors.right: goToFolderListIcon.left 
                anchors.rightMargin:10 
                anchors.verticalCenter: parent.verticalCenter
                value: unreadCount
            }

            MoreIndicator {
                id: goToFolderListIcon
                anchors.right: parent.right
                anchors.rightMargin: UiConstants.DefaultMargin
                anchors.verticalCenter: parent.verticalCenter
            }

            onClicked: {
                listView.currentIndex = index;
                window.currentMailAccountId = mailAccountId;
                window.currentMailAccountIndex = index;
                window.currentAccountDisplayName = displayName;
                messageListModel.setAccountKey (mailAccountId);
                mailFolderListModel.setAccountKey(mailAccountId);
                window.folderListViewTitle = window.currentAccountDisplayName + " Inbox";
                window.currentFolderId = emailAgent.inboxFolderId(window.currentMailAccountId);
                window.currentFolderName = "Inbox";
                pageStack.push(Qt.resolvedUrl("FolderListView.qml"))
            }
        }
    }

    tools: ToolBarLayout {
        ToolIcon { iconId: "icon-m-toolbar-refresh"; onClicked: {
            if (window.refreshInProgress == true) {
                emailAgent.cancelSync();
                window.refreshInProgress = false;
            } else {
                emailAgent.accountsSync();
                window.refreshInProgress = true;
            }
        } }
    }
}
