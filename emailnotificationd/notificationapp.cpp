#include <mnotification.h>
#include "notificationapp.h"

NotificationApp::NotificationApp(int argc, char **argv)
    : QCoreApplication(argc, argv)
{
    mSetting = new MGConfItem("/apps/meego-app-email/newmailnotifications");
    connect(mSetting, SIGNAL(valueChanged()), this, SLOT(valueChanged()));
    valueChanged();
}

void NotificationApp::messagesAdded(const QMailMessageIdList &ids)
{
    QMailMessageId id;
    foreach (id, ids) {
        QMailMessage *message = new QMailMessage(id);
        QString sender = message->from().toString();
        QString subject = message->subject();
        MNotification *notification = new MNotification(MNotification::EmailArrivedEvent, sender, subject);
        notification->publish();
        qDebug() << "new email:" << sender << subject;
    }
}

void NotificationApp::valueChanged()
{
    QMailStore *mailStore = QMailStore::instance();
    if (mSetting->value() == true) {
        connect(mailStore, SIGNAL(messagesAdded(const QMailMessageIdList&)), this, SLOT(messagesAdded(const QMailMessageIdList&)));
    } else {
        disconnect(mailStore, SIGNAL(messagesAdded(const QMailMessageIdList&)), this, SLOT(messagesAdded(const QMailMessageIdList&)));
    }
}
