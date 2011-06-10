/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import QtQuick 1.0
import MeeGo.Components 0.1

Flickable {
    id: welcomeFlick
    clip: true
    anchors.fill: parent
    contentWidth: content.width
    contentHeight: content.height
    flickableDirection: Flickable.VerticalFlick

    Theme {
        id: theme
    }

    SaveRestoreState {
        id: welcomeSaveRestoreState
        onSaveRequired: {
            setValue("emailWelcomeScroll",welcomeFlick.contentY);
        }
    }

    Column {
        id: content
        width: settingsPage.width
        spacing: 20
        Item { width: 1; height: 20; }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: theme.fontPixelSizeMedium
            //color: "white"
            text: qsTr("Welcome to your email.")
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: theme.fontPixelSizeLarge
            //color: "white"
            text: qsTr("Set up your accounts")
        }
        WelcomeButtons {}
    }

    Component.onCompleted: {
        if(welcomeSaveRestoreState.restoreRequired) {
            welcomeFlick.contentY = welcomeSaveRestoreState.value("emailWelcomeScroll");
        }
    }
}
