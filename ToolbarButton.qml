/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

Item {
    id: container

    property string iconName: ""
    property alias rotating: imageRotation.running
    width: image.width
    height: image.height

    state: "up"

    signal clicked

    Image {
        id: image
        anchors.centerIn: parent

        source: "image://theme/email/" + iconName + "_" + container.state
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
        onPressed: {
            container.state = "dn"
        }
        onReleased: {
            container.state = "up"
        }

        onClicked: {
            container.clicked ();
        }
    }

    states: [
        State {
            name: "dn"
        },
        State {
            name: "up"
        }
    ]
}
