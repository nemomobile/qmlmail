/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1
import MeeGo.App.Email 0.1

Item {
    id: container

    FolderListModel {
        id: mailFolderListModel
    }

    property int topicHeight: 25
    signal topicTriggered(int index)
    property alias currentTopic: listView.currentIndex
    property alias interactive: listView.interactive
    property alias model: listView.model
    property string currentFolderName: ""
    property variant currentFolderId: ""

    ListView {
        id: listView
        anchors.fill: parent

        onCurrentIndexChanged: container.topicTriggered(currentIndex)

        model: mailFolderListModel
        highlight: Rectangle {
            width: listView.width;
            height: container.topicHeight;
            color: "#281832"
        }
        highlightMoveDuration: 1
        delegate: Item {
            id: contentItem
            width: container.width
            height: container.topicHeight

            Image {
                anchors.fill: parent
                source: "image://theme/email/filter-background"
            }

            Text {
                id: contentLabel
                height: container.topicHeight
                width: container.width - 50
                text:  folderName
                font.pixelSize: theme_fontPixelSizeMedium
                color: theme_fontColorHighlight
                anchors.left: parent.left
                anchors.leftMargin: 10
                verticalAlignment: Text.AlignVCenter
            }
            Text {
                height: container.topicHeight
                font.pixelSize: theme_fontPixelSizeMedium
                text: folderUnreadCount
                anchors.left: contentLabel.right
                anchors.right: parent.right
                color: theme_fontColorHighlight
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
                opacity: folderUnreadCount ? 1 : 0
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    currentFolderName = folderName;
                    currentFolderId = folderId;
                    listView.currentIndex = index;
                }
            }
        }
    }
}
