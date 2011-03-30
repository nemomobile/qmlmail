/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1

Column {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: 90
    anchors.rightMargin: 90
    property alias label: label.text
    property alias text: textentry.text
    property alias textInput: textentry.textInput
    property alias inputMethodHints: textentry.inputMethodHints
    property alias enabled: textentry.enabled
    property alias errorText: inlineNotification.text
    Text {
        id: label
        height: 30
        font.pixelSize: theme_fontPixelSizeLarge
        font.italic: true
        color: "grey"
    }
    TextEntry {
        id: textentry
        anchors.left: parent.left
        anchors.right: parent.right
    }
    InlineNotification {
        id: inlineNotification
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40
        visible: text.length > 0
    }
}
