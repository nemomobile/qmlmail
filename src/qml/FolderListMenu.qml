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

Item {
    id: folderListMenu
    property bool scrollInFolderList: false    

    height: {
        var realHeight = window.width;
        if (window.orientation == 1 || window.orientation == 3)
        {
           realHeight = window.height;
        }

        //Unfortunately item heights have been hard-coded. In this situation,
        //this is the appropriate fix for bug https://bugs.meego.com/show_bug.cgi?id=19151
        //var maxHeight = 50 * (5 + mailFolderListModel.numberOfFolders());
        var maxHeight = sort.height + sortFilter.height
        + createFolder.height + renameFolder.height + deleteFolder.height +
        goToFolder.height + (50 * mailFolderListModel.numberOfFolders())

        if (maxHeight > (realHeight - 170))
        {
            scrollInFolderList = true;
            return (realHeight - 170);
        }
        else
            return maxHeight;
    }
    
    width: Math.max(sortTitle.width, goToFolderTitle.width, createFolderLabel.width + createButton.width) + 30

    Item {
        id: sort
        height: 50
        anchors.left: parent.left
        anchors.top: parent.top
        Text {
            id: sortTitle
            text: sortLabel
            font.bold: true
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            color:theme.fontColorNormal
            font.pixelSize: theme.fontPixelSizeLarge
            horizontalAlignment: Text.AlignLeft
            elide: Text.ElideRight
        }
    }

    SortFilter {
        id: sortFilter
        anchors.top: sort.bottom
        anchors.left: parent.left
        width: parent.width
        height: 50 * 3
        topics: [
            topicDate,
            topicSender,
            topicSubject
        ]
        onTopicTriggered: {
            if (index == 0)
            {
                messageListModel.sortByDate(folderListView.dateSortKey);
                folderListView.dateSortKey = folderListView.dateSortKey ? 0 : 1;
                folderListView.senderSortKey = 1;
                folderListView.subjectSortKey = 1;
            }
            else if (index == 1)
            {
                messageListModel.sortBySender(folderListView.senderSortKey);
                folderListView.senderSortKey = folderListView.senderSortKey ? 0 : 1;
                folderListView.dateSortKey = 1;
                folderListView.subjectSortKey = 1;
            }
            else if (index == 2)
            {
                messageListModel.sortBySubject(folderListView.subjectSortKey);
                folderListView.subjectSortKey = folderListView.subjectSortKey ? 0 : 1;
                folderListView.dateSortKey = 1;
                folderListView.senderSortKey = 1;
            }
            folderListView.closeMenu()
        }
    }

    Image {
        id: sortDivider
        anchors.top: sortFilter.bottom
        width: parent.width
        source: "image://theme/email/divider_l"
    }

    Item {
        id: createFolder
        height: 50

        property string createNewFolder: qsTr("Create new folder")

        anchors.top:  sortDivider.bottom
        anchors.left: parent.left
        anchors.right:  parent.right

        Text {
            id: createFolderLabel
            height: 50
            anchors.left: parent.left
            anchors.leftMargin: 10
            text: parent.createNewFolder
            verticalAlignment: Text.AlignVCenter

            font.bold: true
            color:theme.fontColorNormal
            font.pixelSize: theme.fontPixelSizeLarge
            horizontalAlignment: Text.AlignLeft
            elide: Text.ElideRight
        }

        Image {
            id: createButton
            anchors.top: createFolderLabel.top
            anchors.bottom: createFolderLabel.bottom
            anchors.right: parent.right
            anchors.rightMargin: 5
            source: "image://theme/email/btn_addperson"
            fillMode: Image.PreserveAspectFit
        }

        Sheet {
            id: createFolderDialog

            property string untitledFolder: qsTr("Untitled Folder")

            acceptButtonText: qsTr("Create")
            rejectButtonText: qsTr("Cancel")
            title: createFolder.createNewFolder

            content: TextField {
                id: folderNameEntry

                anchors.centerIn: parent
                //: Default custom e-mail folder name.
                text: createFolderDialog.untitledFolder
            }

            onAccepted: {
                emailAgent.createFolder(folderNameEntry.text,
                                        window.currentMailAccountId,
                                        window.currentFolderId);
            }
        }

        MouseArea {
            anchors.fill: parent

            onClicked: {
                createFolderDialog.open()
                folderListView.closeMenu();
            }
        }
    }

    Text {
        id: renameFolder

        property string label: qsTr("Rename folder")

        text: label

        height: 50
        anchors.top: createFolder.bottom
        anchors.left: parent.left
        anchors.leftMargin: 10
        verticalAlignment: Text.AlignVCenter

        font.bold: true
        color:theme.fontColorNormal
        font.pixelSize: theme.fontPixelSizeLarge
        horizontalAlignment: Text.AlignLeft
        elide: Text.ElideRight

        Sheet {
            id: renameFolderDialog

            acceptButtonText: qsTr("Rename")
            rejectButtonText: qsTr("Cancel")
            title: renameFolder.label

            content: TextField {
                id: renameEntry

                anchors.centerIn: parent

                //: Default custom e-mail folder name.
                text: window.currentFolderName
            }

            onAccepted: {
                // This will only work on user created folders.
                emailAgent.renameFolder(window.currentFolderId,
                                        renameEntry.text)

                // @todo Only set currentFolderName when it has been changed on the server.
                window.currentFolderName = renameEntry.text
            }
        }

        MouseArea {
            anchors.fill: parent

            onClicked: {
                renameFolderDialog.open()
                folderListView.closeMenu();
            }
        }
    }

    Text {
        id: deleteFolder

        property string label: qsTr("Delete folder")

        text: label

        height: 50
        anchors.top: renameFolder.bottom
        anchors.left: parent.left
        anchors.leftMargin: 10
        verticalAlignment: Text.AlignVCenter

        font.bold: true
        color:theme.fontColorNormal
        font.pixelSize: theme.fontPixelSizeLarge
        horizontalAlignment: Text.AlignLeft
        elide: Text.ElideRight

        Sheet {
            id: deleteFolderDialog

            acceptButtonText: qsTr("Yes")
            rejectButtonText: qsTr("Cancel")

            title: deleteFolder.label

            Text {
                // TODO: margins
                anchors.fill: parent
                text: qsTr("Are you sure you want to delete the folder \"%1\" and all emails inside ?").arg(window.currentFolderName)
            }


            onAccepted: {
                // This will only work on user created folders.
                emailAgent.deleteFolder(window.currentFolderId);

                // Switch to the INBOX.
                window.currentFolderId = emailAgent.inboxFolderId(window.currentMailAccountId);
                window.currentFolderName = mailFolderListModel.inboxFolderName();
                window.folderListViewTitle = currentAccountDisplayName + " " + window.currentFolderName;
                folderListView.closeMenu();
                messageListModel.setFolderKey(window.currentFolderId);
                folderList=null;
                window.switchBook(folderList);
            }
        }

        MouseArea {
            anchors.fill: parent

            onClicked: {
                deleteFolderDialog.open();
                folderListView.closeMenu();
            }
        }
    }

    Image {
        id: deleteFolderDivider
        anchors.top: deleteFolder.bottom
        width: parent.width
        source: "image://theme/email/divider_l"
    }

    Item {
        id: goToFolder
        height: 50
        anchors.left: parent.left
        anchors.top: deleteFolderDivider.bottom
        Text {
            id: goToFolderTitle
            text: window.goToFolderLabel
            font.bold: true
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            color:theme.fontColorNormal
            font.pixelSize: theme.fontPixelSizeLarge
            horizontalAlignment: Text.AlignLeft
            elide: Text.ElideRight
        }
    }

}
