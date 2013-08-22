/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import QtQuick 2.0
import com.nokia.meego 2.0

Column {
    id: background

    property alias model: repeater.model
    property alias text: input.text

    function complete () {
        if (text != "") {
            background.model.append ({name:"", email:text});
        }
    }

    TextField {
        id: recipientListLabel
        placeholderText: "To:"
        width: parent.width

        visible: input.text == "" && repeater.model.count == 0
    }

    Flickable {
        id: flickable

        width: parent.width
        contentWidth: width
        contentHeight: recipientEntry.height
        height: recipientEntry.height < 75 ? recipientEntry.height : 75

        interactive: recipientEntry.height > 75
        clip: true

        function ensureVisible (rY, rHeight) {
            if (contentY >= rY)
                contentY = rY;
            else if (contentY + height <= rY + rHeight)
                contentY = rY + rHeight - height;

            if (contentY > height) {
                contentY = 0;
            }
        }

        MouseArea {
            id: recipientEntry

            width: parent.width
            height: flow.height

            onClicked: {
                input.visible = true;
                input.forceActiveFocus();
                input.width =input.font.pixelSize
            }

            Flow {
                id: flow

                width: parent.width
                spacing: 10

                Repeater {
                    id: repeater

                    EmailAddress {
                        emailAddress: email
                        givenName: name
                        onClicked: {
                            var i;

                            // this will delete the first instance.
                            for (i = 0; i < repeater.model.count; i++) {
                                if (repeater.model.get(i).email == emailAddress) {
                                    repeater.model.remove(i);
                                    break;
                                }
                            }
                        }
                    }
                }

                Item {
                    id: padding

                    width: input.width
                    height: 35

                    TextInput {
                        id: input
                        visible: false

                        anchors.verticalCenter: parent.verticalCenter
                        inputMethodHints: Qt.ImhEmailCharactersOnly | Qt.ImhNoAutoUppercase

                        function addEmailAddress () {
                            if (text != "") {
                                background.model.append ({name:"", email:text});
                                text = "";
                                flickable.ensureVisible (parent.y, parent.height);
                            }
                        }

                        Keys.onSpacePressed: {
                            addEmailAddress ();
                            event.accepted = true;
                        }

                        Keys.onReturnPressed: {
                            addEmailAddress ();
                            event.accepted = true;
                        }

                        Keys.onPressed: {
                            if (event.key == Qt.Key_Backspace) {
                                if (text == "") {
                                    var count = background.model.count;
                                    if (count != 0) {
                                        background.model.remove (count - 1);
                                        event.accepted = true;
                                    }
                                }
                            } else if (event.key == Qt.Key_Comma || event.key == Qt.Key_Semicolon) {
                                addEmailAddress ();
                                event.accepted = true;
                            }
                            width= text.length * font.pixelSize
                            flickable.ensureVisible (parent.y, parent.height);
                        }
                    }
                }
            }
        }
    }
}

