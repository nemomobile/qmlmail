/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */


#include <QMailAccount>
#include <QMailStore>
#include <QDeclarativeItem>
#include <QFileInfo>
#include "emailagent.h"
#include "emailmessage.h"
#include "qmailnamespace.h"

EmailMessage::EmailMessage (QDeclarativeItem *parent)
    : QDeclarativeItem(parent)
{
    // set the default priority to normal
    m_msg.appendHeaderField("X-Priority", "3");
    m_msg.appendHeaderField("X-MSMail-Priority", "Normal");
}

EmailMessage::~EmailMessage ()
{
}

void EmailMessage::setFrom (const QString &sender)
{
    QMailAccountIdList accountIds = QMailStore::instance()->queryAccounts(
                                       QMailAccountKey::status(QMailAccount::Enabled, 
                                       QMailDataComparator::Includes), QMailAccountSortKey::name());
    // look up the account id for the given sender
    foreach (QMailAccountId id, accountIds)
    {
        QMailAccount account(id);
        QMailAddress from = account.fromAddress();
        if (from.address() == sender || from.toString() == sender ||
            from.name() == sender)
        {
            m_account = account;
            m_msg.setParentAccountId(id);
            m_msg.setFrom(account.fromAddress());
        }
    }
}

void EmailMessage::setTo (const QStringList &toList)
{
    m_msg.setTo(QMailAddress::fromStringList(toList));
}

void EmailMessage::setCc (const QStringList &ccList)
{
    m_msg.setCc(QMailAddress::fromStringList(ccList));
}

void EmailMessage::setBcc(const QStringList &bccList)
{
    m_msg.setBcc(QMailAddress::fromStringList(bccList));
}

void EmailMessage::setSubject (const QString &subject)
{
    m_msg.setSubject(subject);
}

void EmailMessage::setBody (const QString &body)
{
    m_bodyText = body;
}

void EmailMessage::setAttachments (const QStringList &uris)
{
    m_attachments = uris;
}

void EmailMessage::setPriority (int priority)
{
    switch (priority) {
    case 2:  //PriorityHigh
        m_msg.appendHeaderField("X-Priority", "1");
        m_msg.appendHeaderField("X-MSMail-Priority", "High");
        break;
    case 1: // PriorityLow
        m_msg.appendHeaderField("X-Priority", "5");
        m_msg.appendHeaderField("X-MSMail-Priority", "Low");
        break;
    case 0:
    default:
        m_msg.appendHeaderField("X-Priority", "3");
        m_msg.appendHeaderField("X-MSMail-Priority", "Normal");
        break;
    }

}

void EmailMessage::send()
{
    QMailMessageContentType type("text/plain; charset=UTF-8");

    if (m_attachments.size() == 0)
        m_msg.setBody(QMailMessageBody::fromData(m_bodyText, type, QMailMessageBody::Base64));
    else
    {
        QMailMessagePart body;
        body.setBody(QMailMessageBody::fromData(m_bodyText.toUtf8(), type, QMailMessageBody::Base64));
        m_msg.setMultipartType(QMailMessagePartContainer::MultipartMixed);
        m_msg.appendPart(body);
    }

    // Include attachments into the message before sending
    processAttachments();

    // set message basic attributes
    m_msg.setDate(QMailTimeStamp::currentDateTime());
    m_msg.setStatus(QMailMessage::Outgoing, true);
    m_msg.setStatus(QMailMessage::ContentAvailable, true);
    m_msg.setStatus(QMailMessage::PartialContentAvailable, true);
    m_msg.setStatus(QMailMessage::Read, true);
    m_msg.setStatus((QMailMessage::Outbox | QMailMessage::Draft), true);

    m_msg.setParentFolderId(QMailFolder::LocalStorageFolderId);

    m_msg.setMessageType(QMailMessage::Email);
    m_msg.setSize(m_msg.indicativeSize() * 1024);

    bool stored = false;
    
    if (!m_msg.id().isValid())
        stored = QMailStore::instance()->addMessage(&m_msg);
    else
        stored = QMailStore::instance()->updateMessage(&m_msg);

    EmailAgent *emailAgent = EmailAgent::instance();
    if (stored && !emailAgent->isSynchronizing())
    {
        connect(emailAgent, SIGNAL(sendCompleted()), this, SLOT(onSendCompleted()));
        emailAgent->sendMessages(m_msg.parentAccountId());
    }
    else
       qDebug() << "Error queuing message, stored: " << stored << "isSynchronising: " << emailAgent->isSynchronizing();

}

void EmailMessage::onSendCompleted()
{
    emit sendCompleted();
}

void EmailMessage::processAttachments ()
{
    QMailMessagePart attachmentPart;
    foreach (QString attachment, m_attachments)
    {
        // Attaching a file
        if (attachment.startsWith("file://"))
            attachment.remove(0, 7);
        QFileInfo fi(attachment);

        // Just in case..
        if (!fi.isFile())
            continue;

        QMailMessageContentType attachmenttype(QMail::mimeTypeFromFileName(attachment).toLatin1());
        attachmenttype.setName(fi.fileName().toLatin1());

        QMailMessageContentDisposition disposition(QMailMessageContentDisposition::Attachment);
        disposition.setFilename(fi.fileName().toLatin1());
        disposition.setSize(fi.size());

        attachmentPart = QMailMessagePart::fromFile(attachment,
                                                    disposition,
                                                    attachmenttype,
                                                    QMailMessageBody::Base64,
                                                    QMailMessageBody::RequiresEncoding);
        m_msg.appendPart(attachmentPart);
    }
}
