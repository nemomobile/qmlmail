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
    id: folderListViewToolbar
    anchors.bottom: parent.bottom
    width: parent.width
    height: navigationBarImage.height

    property bool inEditMode: false
    property Item folderListContainer

    signal editModeBegin();
    signal editModeEnd();

    BorderImage {
        id: navigationBarImage
        width: parent.width
        source: "image://themedimage/widgets/common/action-bar/action-bar-background"
    }
    Item {
        anchors.fill: parent

        opacity: inEditMode == false ? 1 : 0

        ToolbarButton {
        id: editButton
        anchors.left: division1.right
        anchors.top: parent.top
        iconName: "mail-editlist"
            onClicked: {
                folderListViewToolbar.editModeBegin();
                inEditMode = true;
            }
        }
        Image {
            anchors.left: editButton.right
            anchors.top: parent.top
            height: parent.height
            source: "image://theme/email/div"
        }

        Image {
            id: division3
            anchors.right: refreshButton.left
            anchors.top: parent.top
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            source: "image://theme/email/div"
        }

    Item {
        anchors.fill: parent
        opacity: inEditMode == true ? 1 : 0

        property int selectedFolderId

        ContextMenu {
            id: folderSelectionMenu

            title: qsTr("Choose folder:")

            property bool scrollInFolderList: false

            content: ListView {
                id: listView
//                anchors.left: parent.left
//                anchors.top: goToFolder.bottom
                height: {
                    var realHeight = window.width;
                    if (window.orientation == 1 || window.orientation == 3)
                    {
                       realHeight = window.height;
                    }
                    var maxHeight = 50 * (1 + mailFolderListModel.numberOfFolders());
                    if (maxHeight > (realHeight - 170))
                    {
                        folderSelectionMenu.scrollInFolderList = true;
                        return (realHeight - 170);
                    }
                    else
                        return maxHeight;
                }

                width: 300
                spacing: 1
                interactive: folderSelectionMenu.scrollInFolderList
                clip: true

                model: mailFolderListModel

                delegate: Item {
                    id: folderItem
                    width: parent.width
                    height: 50

                    Image {
                        width: parent.width
                        source: "image://theme/email/divider_l"
                    }

                    Text {
                        id: folderLabel
                        height: 50
                        text:  folderName
                        font.pixelSize: theme.fontPixelSizeLarge
                        color:theme.fontColorNormal
                        anchors.left: parent.left
                        anchors.leftMargin: 15
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            messageListModel.moveSelectedMessageIds(folderId);
                            folderListContainer.numOfSelectedMessages = 0;
                            folderSelectionMenu.hide();
                        }
                    }
                }
            }
        }

        // Go polymorphic and design pattern-y.  Here we implement the
        // Strategy design pattern.  The two strategies are "move" and
        // "delete" selected messages.
        QtObject {
            id: messageMover

            function run() {
                folderSelectionMenu.setPosition(
                            moveAction.x + moveAction.width / 2,
                            mapToItem(window, window.width / 2,
                                      moveAction.y + moveAction.height).y)
                folderSelectionMenu.show()
            }
        }

        ModalMessageBox {
            id: deleteConfirm
            acceptButtonText: qsTr("Yes")
            cancelButtonText: qsTr("No")
            title: qsTr("Confirm Email Delete")
            text: qsTr("Are you sure you want to delete these mails?")
            onAccepted: {
                messageListModel.deleteSelectedMessageIds();
                folderListContainer.numOfSelectedMessages = 0;
            }
        }


        QtObject {
            id: messageDeleter

            function run() {
                deleteConfirm.show()
            }
        }

        // Separator left of the exit button on the far right.
        Image {
            id: separator
            anchors.right: exitEditModeButton.left
            anchors.top: parent.top
            height: parent.height
            source: "image://theme/email/div"
        }

        Item {
            // FIX ME:  use the old icon until UX design team provide new ones.
            id: exitEditModeButton
            anchors.right: parent.right
            anchors.top: parent.top
            width: 65
            height:55
            property string iconName: "image://theme/email/icns_export/icn_can_edit_up"

            Image {
                id: settingsIcon
                anchors.centerIn: exitEditModeButton
                source: exitEditModeButton.iconName
                width: 48
                height: 48
                NumberAnimation on rotation {
                    id: imageRotation
                    running: false
                    from: 0; to: 360
                    loops: Animation.Infinite;
                    duration: 2400
                }
            }

            MouseArea {
                anchors.fill: parent
                onPressed : {
                    exitEditModeButton.iconName = "image://theme/email/icns_export/icn_can_edit_dn";
                }
                onReleased: {
                    exitEditModeButton.iconName = "image://theme/email/icns_export/icn_can_edit_up";
                }
                onClicked: {
                    folderListViewToolbar.editModeEnd();
                    inEditMode = false;
                }
            }
        }
    }
  }
}
