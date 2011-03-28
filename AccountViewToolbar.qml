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
    anchors.bottom: parent.bottom
    width: parent.width
    height: navigationBarImage.height

    ApplicationsModel {
        id: appModel
    }

    BorderImage {
        id: navigationBarImage
        width: parent.width
        verticalTileMode: BorderImage.Stretch
        source: "image://theme/navigationBar_l"
    }
    Item {
        anchors.fill: parent

      
        Item {
            id: accountSetting
            anchors.left: parent.left 
            anchors.top: parent.top
            height: container.height
            width: settingsIcon.width
            property string iconName: "image://theme/email/icns_export/icn_settings_up"

            Image {
                id: settingsIcon
                anchors.centerIn: parent
                source: accountSetting.iconName
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
                    accountSetting.iconName = "image://theme/email/icns_export/icn_settings_dn";
                }
                onReleased: {
                    accountSetting.iconName = "image://theme/email/icns_export/icn_settings_up";
                }
                onClicked: {
                    var cmd = "/usr/bin/meego-qml-launcher --app meego-ux-settings --opengl --fullscreen --cmd showPage --cdata \"Email\"";  //i18n ok
                    appModel.launch(cmd);
                }
            }
        }
        Image {
            id: division1
            anchors.left: accountSetting.right
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            source: "image://theme/email/div"
        }

        Image {
            id: division2
            anchors.right: refreshButton.left
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            source: "image://theme/email/div"
        }
        Item {
            id:refreshButton 
            anchors.right: parent.right
            anchors.top: parent.top
            height: container.height
            width: refreshImage.width
            Image {
                id: refreshImage
                anchors.centerIn: parent
                opacity: scene.refreshInProgress ? 0 : 1
                source: "image://theme/email/icns_export/icn_refresh_up"
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
                        emailAgent.accountsSync();
                        scene.refreshInProgress = true;
                    }
                }
            }
        }
    }
}
