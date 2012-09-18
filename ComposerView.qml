/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import QtQuick 1.1
import com.nokia.meego 1.1
import org.nemomobile.email 0.1

Page {
    id: composerPage

    Component.onCompleted: {

        if (window.editableDraft)
        {                    
            composerView.composer.textBody= window.mailBody
            composerView.composer.subject= window.mailSubject

            var idx;
            composerView.composer.toModel.clear();
            for (idx = 0; idx < window.mailRecipients.length; idx++)
                composerView.composer.toModel.append({"name": "", "email": window.mailRecipients[idx]});

            composerView.composer.bccModel.clear();
            for (idx = 0; idx < window.mailCc.length; idx ++)
                composerView.composer.bccModel.append({"email": window.mailCc[idx]});

            composerView.composer.bccModel.clear();
            for (idx = 0; idx < window.mailBcc.length; idx ++)
                composerView.composer.bccModel.append({"email": window.mailBcc[idx]});

            composerView.composer.attachmentsModel.clear();
            for (idx = 0; idx < window.mailAttachments.length; idx ++)
                composerView.composer.attachmentsModel.append({"uri": window.mailAttachments[idx]});
        }

        window.editableDraft= false
        window.composerIsCurrentPage = true;
    }

    Component.onDestruction: {
        window.composerIsCurrentPage = false;
    }

    FocusScope {
        id: composerViewContainer
        focus: true

        property alias composer: composer

        width: parent.width
        height: parent.height

        ListModel {
            id: toRecipients
        }

        ListModel {
            id: ccRecipients
        }

        ListModel {
            id: bccRecipients
        }

        ListModel {
            id: attachments
        }

        Composer {
            id: composer
            focus: true
            anchors.fill: parent

            toModel: toRecipients
            ccModel: ccRecipients
            bccModel: bccRecipients
            attachmentsModel: mailAttachmentModel
            accountsModel: mailAccountListModel
        }
    }

    tools: ToolBarLayout {
        ToolIcon { iconId: "toolbar-back"; onClicked: { pageStack.pop(); }  }
    }
}

