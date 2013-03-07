/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import QtQuick 1.1
import com.nokia.meego 1.2
import com.nokia.extras 1.1
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

        delegate: MouseArea {
            id: accountItem
            width: parent.width
            height: UiConstants.ListItemHeightDefault

            Component.onCompleted: {
                if (index == 0) {
                    window.currentAccountDisplayName = displayName;
                    window.currentMailAccountId = mailAccountId;
                }
            }

            Label {
                height: parent.height
                anchors.left: parent.left
                anchors.leftMargin: UiConstants.DefaultMargin
                anchors.right: unreadImage.left
                anchors.rightMargin: UiConstants.DefaultMargin
                verticalAlignment: Text.AlignVCenter
                text: emailAddress + " - " + displayName  //i18n ok
                elide: Text.ElideRight
            }

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
                window.folderListViewTitle = window.currentAccountDisplayName + " " + mailFolderListModel.inboxFolderName();
                window.currentFolderId = mailFolderListModel.inboxFolderId();
                window.currentFolderName = mailFolderListModel.inboxFolderName();
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
