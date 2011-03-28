/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1

ListView {
    id: container
    spacing: 3.0
    clip: true
    delegate: Text {
        font.pixelSize: theme_fontPixelSizeLarge
        text: "<b>" + (index + 1) + "</b>: " + modelData
    }
}