/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1

DropDown {
    id: dropDown

//    property alias emailAddress: dropDown.selectedVal

    property string emailAddress:""
    delegateComponent: accountDelegate

    signal emailChanged (string emailAddress)

    Component {
        id: accountDelegate

        Text {
            id:listVal

            property variant data

            x: 15
            text: {
                // If the user don't specify a Description for an account,
                // QMF sets the displayName to the same as emailAddress. 
                // In this case, we just want to show the emailAddress only.
                if (data.displayName == data.emailAddress)
                    return data.emailAddress;
                else
                    qsTr("%1 <%2>").arg(data.displayName).arg(data.emailAddress)
            }
            anchors.verticalCenter: parent.verticalCenter
            color: theme_fontColorNormal
            font.pointSize: theme_fontPixelSizeLarge
            font.bold: false
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            wrapMode: Text.WordWrap
        }
    }

    onSelectionChanged: {
        console.log ("Selection index: " + index);
        console.log ("Selection changed: " + data.emailAddress);
        dropDown.emailChanged (data.emailAddress);
    }
}
