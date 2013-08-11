import QtQuick 2.0
import com.nokia.meego 2.0

QueryDialog {
    id: verifyDelete
    acceptButtonText: qsTr ("Yes")
    rejectButtonText: qsTr ("Cancel")
    titleText: qsTr ("Delete Email")
    message: qsTr ("Are you sure you want to delete this email?")

    onAccepted: { emailAgent.deleteMessage (window.mailId) }
}


