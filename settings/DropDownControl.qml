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
    id: root
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: 90
    anchors.rightMargin: 90
    property alias label: label.text
    property alias dataList: dropdown.dataList
    property alias selectedValue: dropdown.selectedValue

    signal selectionChanged (int index, variant data)

    Text {
        id: label
        height: 30
        font.pixelSize: theme_fontPixelSizeLarge
        font.italic: true
        color: "grey"
    }
    DropDown {
        id: dropdown
        onSelectionChanged: root.selectionChanged(index, data)
        delegateComponent: Component {
            Text {
                property variant data
                x: 15
                text: data
            }
        }
    }
}
