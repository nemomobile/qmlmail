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
    id: sortMenuContent
    height: parent.height
    width: parent.width
    Item {
        id: sortTitle
        width: parent.width
        height: 50
        anchors.left: parent.left
        anchors.top: parent.top
        Text {
            text: sortLabel
            font.bold: true
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            color:theme_fontColorNormal
            font.pixelSize: theme_fontPixelSizeLarge
            horizontalAlignment: Text.AlignLeft
            elide: Text.ElideRight
        }
    }
    SortFilter {
        id: sortFilter
        anchors.top: sortTitle.bottom
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
}
