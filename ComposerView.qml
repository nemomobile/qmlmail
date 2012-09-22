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
    property alias quotedBody: composer.quotedBody

    Component.onCompleted: {

        if (window.editableDraft) {
            composer.textBody= window.mailBody
            composer.subject= window.mailSubject

            var idx;
            composer.toModel.clear();
            for (idx = 0; idx < window.mailRecipients.length; idx++)
                composer.toModel.append({"name": "", "email": window.mailRecipients[idx]});

            composer.bccModel.clear();
            for (idx = 0; idx < window.mailCc.length; idx ++)
                composer.bccModel.append({"email": window.mailCc[idx]});

            composer.bccModel.clear();
            for (idx = 0; idx < window.mailBcc.length; idx ++)
                composer.bccModel.append({"email": window.mailBcc[idx]});

            composer.attachmentsModel.clear();
            for (idx = 0; idx < window.mailAttachments.length; idx ++)
                composer.attachmentsModel.append({"uri": window.mailAttachments[idx]});
        }

        window.editableDraft= false
        window.composerIsCurrentPage = true;
    }

    Component.onDestruction: {
        window.composerIsCurrentPage = false;
    }

    function setMessageDetails(messageID, replyToAll) {
        var dateline = qsTr ("On %1 %2 wrote:").arg(messageListModel.timeStamp (messageID)).arg(messageListModel.mailSender (messageID));

//        if (window.mailHtmlBody != "") {
//            window.composeInTextMode = false;
//            composer.setQuotedHtmlBody(dateline, messageListModel.htmlBody(messageID))
//        } else {
            window.composeInTextMode = true;
            composer.quotedBody = "\n" + dateline + "\n" + messageListModel.quotedBody (messageID); //i18n ok
//        }

        attachmentsModel.clear();
        composer.attachmentsModel = attachmentsModel;
        toModel.clear();
        toModel.append({"name": "", "email": messageListModel.mailSender(messageID)});
        composer.toModel = toModel;


        if (replyToAll == true) {
            ccModel.clear();
            var recipients = new Array();
            recipients = messageListModel.recipients(messageID);
            var idx;
            for (idx = 0; idx < recipients.length; idx++)
                ccModel.append({"name": "", "email": recipients[idx]});
            composer.ccModel = ccModel;
        }

        // "Re:" is not supposed to be translated as per RFC 2822 section 3.6.5
        // Internet Message Format - http://www.faqs.org/rfcs/rfc2822.html
        //
        // "If this is done, only one instance of the literal string
        // "Re: " ought to be used since use of other strings or more
        // than one instance can lead to undesirable consequences."
        // Also see: http://www.chemie.fu-berlin.de/outerspace/netnews/son-of-1036.html#5.4
        // FIXME: Also need to only add Re: if it isn't already in the subject
        // to prevent "Re: Re: Re: Re: " subjects.
        composer.subject = "Re: " + messageListModel.subject (messageID);  //i18n ok

    }

    function setReplyFocus() {
        composer.focus = true;
        if (window.composeInTextMode) {
            textEditPane.focus = true;
            return textEditPane.focus;
        } else {
            return htmlEditPane.setFocusElement(replyElementId)
        }
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

        EmailHeader {
            id: header
            z: 1000

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: UiConstants.DefaultMargin

            toModel: ListModel {
            }

            ccModel: ListModel {
            }

            bccModel: ListModel {
            }

            attachmentsModel: mailAttachmentModel
            accountsModel: mailAccountListModel
        }

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
        Rectangle {
            id: editorBackground
            anchors.top: header.bottom
            anchors.topMargin: UiConstants.DefaultMargin
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            color: "white"
        }

        Flickable {
            anchors.fill: editorBackground
            contentHeight: textEditPane.height
            clip: true
            TextArea {
                id: textEditPane
                width: parent.width
                visible: window.composeInTextMode
                text : {
                    var sig = emailAgent.getSignatureForAccount(window.currentMailAccountId);
                    if (sig == "")
                        return composer.quotedBody;
                    else
                        return (composer.quotedBody + "\n-- \n" + sig + "\n");
                }

                platformStyle: TextAreaStyle {
                    background: ""
                    backgroundSelected: ""
                    backgroundDisabled: ""
                    backgroundError: ""
                    backgroundCornerMargin: 0
                }
            }
        }
    }

    Component {
        id: messageComponent

        EmailMessage {
            id: emailMessage
        }
    }

    tools: ToolBarLayout {
        ToolIcon { iconId: "toolbar-back"; onClicked: { pageStack.pop(); }  }
        ToolIcon {
            iconId: "icon-m-toolbar-send-sms";
            onClicked: {
                var i;
                var message;

                composer.completeEmailAddresses();

                message = messageComponent.createObject(composer);
                message.setFrom (mailAccountListModel.getEmailAddressByIndex(composer.fromEmail));

                var to = new Array ();
                for (i = 0; i < composer.toModel.count; i++)
                    to[i] = composer.toModel.get (i).email;
                message.setTo (to);

                var cc = new Array ();
                for (i = 0; i < composer.ccModel.count; i++)
                    cc[i] = composer.ccModel.get (i).email;
                message.setCc (cc);

                var bcc = new Array ();
                for (i = 0; i < composer.bccModel.count; i++)
                    bcc[i] = composer.bccModel.get (i).email;
                message.setBcc (bcc);

                var att = new Array ();
                for (i = 0; i < composer.attachmentsModel.count; i++)
                    att[i] = composer.attachmentsModel.get (i).uri;
                message.setAttachments (att);

                message.setSubject (composer.subject);
                message.setPriority (composer.priority);
                if (window.composeInTextMode)
                    message.setBody (composer.textBody, true);
                else
                    message.setBody (composer.htmlBody, false);

                message.send ();
                pageStack.pop();
            }
        }
    }
}

