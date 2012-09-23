import QtQuick 1.1
import com.nokia.meego 1.2

SelectionDialog {
    id: selectFolderDialog
    model: mailFolderListModel

    delegate: MouseArea {
        id: folderItem
        height: 50
        width: parent.width

        Label {
            id: folderLabel
            height: 50
            text: folderName + (folderUnreadCount ? (" (" + folderUnreadCount +")") : "")
            color: "white"
            anchors.left: parent.left
            anchors.leftMargin: 15
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        onClicked: {
            window.currentFolderId = folderId;
            window.currentFolderName = folderName;
            window.folderListViewTitle = currentAccountDisplayName + " " + folderName;
            messageListModel.setFolderKey(folderId);
            reject()
        }
    }
}

