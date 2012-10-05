import QtQuick 1.1
import com.nokia.meego 1.2

Dialog {
    title: qsTr("Error")

    content: Item {
        anchors.fill: parent
        anchors.margins: 10
        Text {
            text: window.errMsg;
            anchors.fill: parent
            color: "white"
            wrapMode: Text.Wrap
        }
    }
}

