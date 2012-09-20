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
        id: composer
        focus:  true
        width: parent.width
        height: parent.height

        property string quotedBody: "";

        property alias textBody: textEditPane.text;
        property alias toModel: header.toModel
        property alias ccModel: header.ccModel
        property alias bccModel: header.bccModel
        property alias attachmentsModel: header.attachmentsModel
        property alias accountsModel: header.accountsModel
        property alias priority: header.priority
        property alias subject: header.subject
        property alias fromEmail: header.fromEmail
        property alias header: header

        property string replyElementId: "replyElement"


        function completeEmailAddresses () {
            header.completeEmailAddresses ();
        }

        function setQuotedHtmlBody(header,quotedHtml) {
            var newBody;
            newBody = "<DIV style=\"background-color:#ffffff\"><DIV id=\"" + replyElementId + "\"CONTENTEDITABLE=\"true\"></DIV>" + header + "</DIV>";
            newBody += "<blockquote style=\"margin: 0pt 0pt 0pt 0.8ex; border-left: 1px solid rgb(204, 204, 204); padding-left: 1ex;\">\n";
            newBody += quotedHtml + "\n</blockquote>\n";
            quotedBody = newBody;
        }

        function setReplyFocus() {
            focus = true;
            if (window.composeInTextMode) {
                focus = true;
                textEditPane.focus = true;
                return textEditPane.focus;
            } else {
                return htmlEditPane.setFocusElement(replyElementId)
            }
        }

        EmailHeader {
            id: header
            anchors.top: parent.top
            anchors.topMargin: UiConstants.DefaultMargin
            width: parent.width
            x: 10
            z: 1000

            toModel: ListModel {
            }

            ccModel: ListModel {
            }

            bccModel: ListModel {
            }

            attachmentsModel: mailAttachmentModel
            accountsModel: mailAccountListModel
        }

        Image {
            width: parent.width
            anchors.top:  header.bottom
            anchors.topMargin:  5
            anchors.bottom:parent.bottom

            source: "image://theme/email/bg_reademail_l"

    /*
            HtmlField {
                id: htmlEditPane
                anchors.fill: parent
                anchors.bottomMargin: 5
                focus: true
                font.pixelSize: theme.fontPixelSizeLarge
                visible: window.composeInTextMode ? false : true
                html : {
                    var sig = emailAgent.getSignatureForAccount(window.currentMailAccountId);
                    if (sig == "")
                        return composer.quotedBody;
                    else
                        return (composer.quotedBody + "\n-- \n" + sig + "\n");
                }
            }
    */

            TextArea {
                id: textEditPane
                visible: window.composeInTextMode
                font.pixelSize: theme.fontPixelSizeLarge
                text : {
                    var sig = emailAgent.getSignatureForAccount(window.currentMailAccountId);
                    if (sig == "")
                        return composer.quotedBody;
                    else
                        return (composer.quotedBody + "\n-- \n" + sig + "\n");
                }

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: UiConstants.DefaultMargin
            }
        }
    }

    tools: ToolBarLayout {
        ToolIcon { iconId: "toolbar-back"; onClicked: { pageStack.pop(); }  }
    }
}

