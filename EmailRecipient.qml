/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1

BorderImage {
    id: container

    property alias model: repeater.model
    property Item addEmailItem : null
    property bool editable: true

    border.top: 10
    border.bottom: 10
    border.left: 10
    border.right: 10
    clip: true

    height: {
        if (flow.height < 40) {
            return 50;
        } else {
            return flow.height + 20;
        }
    }
    source: "image://theme/email/frm_textfield_l"

    function addEmailAddress (name, email) {
        if (email != "") {
            model.append ({"name": name, "email": email});
        }
    }

    function complete () {
        if (addEmailItem != null) {
            console.log ("Adding email: " + addEmailItem.text);
            addEmailAddress ("", addEmailItem.text);
        }
    }

    Connections {
        target: addEmailItem
        onAddEmail: {
            if (email == "") {
                addEmailItem.destroy ();
                addEmailItem = null;
            } else {
                // FIXME: We need to do a look up here to get the name
                // from the addressbook
                addEmailAddress ("", email);
                addEmailItem.destroy ();
                addEmailItem = null;
            }
        }
    }

    MouseArea {
        anchors.fill: parent

        onClicked: {
            if (editable == false) {
                return ;
            }

            // Take focus
            //focusScope.focus = true;

            addEmailItem = addEmailComponent.createObject (container);
            addEmailItem.slideIn ();
        }
    }

    Flow {
        id: flow
        x: 10
        y: 10
        width: parent.width - 20

        anchors.verticalCenter: parent.verticalCenter
        spacing: 3

        Repeater {
            id: repeater

            delegate: EmailAddress {
                emailAddress: email
                givenName: name
            }
        }
    }

    Component {
        id: addEmailComponent

        // FIXME: Ask Nick/Darren about having an OK/Cancel thing here
        Item {
            id: addEmailDialog
            anchors.fill: parent

            property alias text: textEntry.text

            signal addEmail (string email)

            function slideIn () {
                textEntry.width = width;
                textEntry.textInput.focus = true;
                textEntry.textInput.cursorPosition = 0
            }

            MouseArea {
                anchors.fill: parent
                onPressed: {
                    textEntry.textInput.focus = true;
                    textEntry.textInput.cursorPosition = 0
                }
            }

            TextEntry {
                id: textEntry
                width: 0
                height: parent.height

                defaultText: qsTr ("Type a name or an email address")
                Behavior on width {
                    NumberAnimation {
                        duration: 100
                    }
                }

                Connections {
                    target: textEntry.textInput
                    onFocusChanged: {
                        console.log ("Focus changed: " + focus);
                        if (focus == false && addEmailItem != null) {
                            if (addEmailItem.text != "") {
                                console.log ("Adding email address by focus change: " + addEmailItem.text);
                                addEmailAddress ("", addEmailItem.text);
                                addEmailItem.destroy ();
                                addEmailItem = null;
                            }
                        }
                    }
                }
            }

            Keys.onReturnPressed: {
                console.log ("Return");
                addEmailDialog.addEmail (textEntry.text);
            }

            Keys.onEscapePressed: {
                addEmailDialog.addEmail ("");
            }
        }
    }
}
