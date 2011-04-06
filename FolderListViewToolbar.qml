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
    id: folderListViewToolbar
    anchors.bottom: parent.bottom
    width: parent.width
    height: navigationBarImage.height

    BorderImage {
        id: navigationBarImage
        width: parent.width
        source: "image://meegotheme/widgets/common/action-bar/action-bar-background"
    }
    Item {
        anchors.fill: parent

        ToolbarButton {
        id: composeButton
        anchors.left: parent.left
        anchors.top: parent.top
        iconName: "mail-compose"
            onClicked: {
                mailAttachmentModel.clear();
                folderListView.addApplicationPage(composer);
            }
        }
        Image {
            id: division1
            anchors.left: composeButton.right
            anchors.top: parent.top
            height: parent.height
            source: "image://theme/email/div"
        }

/*        ToolbarButton {
        id: editButton
        anchors.left: division1.right
        anchors.top: parent.top
        iconName: "mail-editlist"
            onClicked: {
            }
        }
        Image {
            anchors.left: editButton.right
            anchors.top: parent.top
            height: parent.height
            source: "image://theme/email/div"
        }
*/
        Image {
            id: division3
            anchors.right: refreshButton.left
            anchors.top: parent.top
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            source: "image://theme/email/div"
        }

        Item {
            id:refreshButton 
            anchors.right: parent.right
            anchors.top: parent.top
            height: refreshImage.height
            width: refreshImage.width
            Image {
                id: refreshImage
                anchors.centerIn: parent
                opacity: scene.refreshInProgress ? 0 : 1
                source: "image://meegotheme/icons/actionbar/view-sync"
            }

            Spinner {
                id: spinner
                anchors.centerIn: parent
                opacity: scene.refreshInProgress ? 1 : 0
                spinning: scene.refreshInProgress
                maxSpinTime: 3600000
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (scene.refreshInProgress == true)
                    {
                        emailAgent.cancelSync();
                        scene.refreshInProgress = false;
                    }
                    else
                    {
                        emailAgent.synchronize(scene.currentMailAccountId);
                        scene.refreshInProgress = true;
                    }
                }
            }
        }
    }
}
