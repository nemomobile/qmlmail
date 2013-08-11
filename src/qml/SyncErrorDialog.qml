import QtQuick 2.0
import com.nokia.meego 2.0

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

