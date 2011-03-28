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

Window {
    id: scene

//    color: "black"

    EmailAccountListModel {
        id: accountsList
    }

    ListModel {
        id: toList

        ListElement { name: "iain"; email: "iain@iain.com" }
        ListElement { name: "test"; email: "test@example.com" }
        ListElement { name: ""; email: "iain@in.2032.the.world.will.self-destruct.com" }
    }

    ListModel {
        id: ccList
    }

    ListModel {
        id: bccList
    }

    ListModel {
        id: attachmentsList
    }

    Composer {
        parent: scene.content
        anchors.fill: parent

        toModel: toList
        ccModel: ccList
        bccModel: bccList
        attachmentsModel: attachmentsList
        accountsModel: accountsList

        subject: "RE:A Test Email"
    }
}