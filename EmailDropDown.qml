/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.App.Email 0.1

//Model used for this Drop Down is a StringList Model
//Reset the "dataModel" with appropriate values to make this work
Item {
    id:dropDown

    height: 53

    property int clickCount:0
    property int selectedIndex:0
    property string selectedVal
    property string selectedText
    property bool suppress: true
    property Component delegateComponent: null

    signal selectionChanged

    property alias dataListRect: dataListRect
    //Set this property with the appropriate values
    property EmailAccountListModel dataModel

    function dataListTriggered() {
        dataListRect.state = (dataListRect.state == "") ? "shown" : "";
    }

    onDataModelChanged: {
        // FIXME: How do you get a row from the dataModel?
        // .get(0) doesn't work either
        //selectedText = dataModel[0].emailAddress;
    }

    Item {
        id: outerBox
        width: parent.width
        height: parent.height

        Image {
            id: leftIcon
            anchors.left: parent.left
            anchors.top: parent.top
            width:20
            smooth: true
            source:"image://theme/dropdown_white_50px_1"
        }

        Image {
            id: rightIcon
            anchors.top: parent.top
            anchors.right: parent.right
            smooth: true
            source:"image://theme/dropdown_white_50px_3"
        }

        Image {
            id: centerIcon
            source: "image://theme/dropdown_white_60px_2"
            anchors.top: parent.top
            anchors.left: leftIcon.right
            anchors.right: rightIcon.left
            smooth: true
        }

        Text {
            id: inputVal
            text: selectedText
            anchors.fill: parent
            color: theme_fontColorNormal
            font.pixelSize: theme_fontPixelSizeLarge
            font.bold: false
            anchors.leftMargin: 15
            verticalAlignment: Text.AlignVCenter

            wrapMode: Text.WordWrap
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                clickCount++;
                dropDown.dataListTriggered();
                console.log("Drop down clicked");
            }
        }

        Column {
            id:dataListRect
            anchors.top: parent.top
            width: parent.width
            height: listmodel.height + 33
            opacity: 0

            BorderImage {
                source: "image://theme/dropdown_white_pressed_1"
                border.top: 7
                width: parent.width
            }

            BorderImage {
                source: "image://theme/dropdown_white_pressed_2"
                height: listmodel.height + 20
                width: parent.width

                ListView {
                    id: listmodel
                    width: parent.width
                    height: {
                    if (count == 1) {
                            // FIXME: When there is only one item, we use the
                            // asset for the top row of the dropdown but this
                            // has no "bottom"
                            // We need a new asset for a single item dropdown
                            return theme_fontPixelSizeLarge;
                        } else {
                            return count * theme_fontPixelSizeLarge;
                        }
                    }
                    model: dataModel
                    spacing: 0
                    focus: true
                    highlightFollowsCurrentItem: false
                    delegate: Item {
                        id: itemHolder
                        x: 15
                        width: parent.width

                        Component.onCompleted: {
                            if (dropDown.delegateComponent) {
                                var element = dropDown.delegateComponent.createObject (itemHolder);
                                element.data = model;
                                itemHolder.height = element.height;
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                clickCount++;
                                selectedVal = emailAddress;
                                selectedIndex = index;
                                selectedText = qsTr("%1 (%2)").arg(displayName).arg(emailAddress);
                                listmodel.currentIndex = index;
                                dataListRect.state = "";

                                dropDown.selectionChanged ();
                            }
                        }
                    }
                }
            }

            BorderImage {
                source: "image://theme/dropdown_white_pressed_3"
                width: parent.width
            }

            states: [
                State {
                    name: "shown"
                    PropertyChanges {
                        target: dataListRect
                        opacity: 1
                    }
                }
            ]

            transitions: [
                Transition {
                    NumberAnimation {
                        properties: "opacity"
                        duration: 200
                    }
                }
            ]
        }
    } //end of dropdown image
}

