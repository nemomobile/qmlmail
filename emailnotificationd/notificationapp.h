
#include <mgconfitem.h>
#include <QCoreApplication>
#include <QMailStore>

class NotificationApp : public QCoreApplication
{
    Q_OBJECT
public:
    NotificationApp(int argc, char **argv);
private slots:
    void messagesAdded(const QMailMessageIdList &ids);
    void valueChanged();
private:
    MGConfItem *mSetting;
};
