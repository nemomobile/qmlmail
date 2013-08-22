/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import QtQuick 2.0
import com.nokia.meego 2.0

Item {
    id: addAttachmentPageContainer

    width: parent.width
    height: parent.height

    property ListModel attachments

    function pickerCancelled () {
        console.log ("Cancelled picker");
    }

    function pickerSelected (uri) {
        console.log (uri + " selected");

        attachments.append ({"uri": uri});
    }

	function pickerMultipleSelected (uris) {
		for(var i = 0; i < uris.length; i++) {
			pickerSelected (uris[i]);
		}
	}


    function addPicker (pickerComponent) {
        var picker = pickerComponent.createObject (addAttachmentPageContainer);

		if(pickerComponent == photoPicker) {
			picker.multiSelection = true;
			console.log('multiSelection is Enabled');
		}
        picker.show ();
        picker.rejected.connect (pickerCancelled);
    }

    Column {
        width: parent.width

//        AttachmentPicker {
//            pickerComponent: documentPicker
//            pickerLabel: qsTr("Documents")
//            pickerImage: "image://theme/panels/pnl_icn_documents"
//        }

        AttachmentPicker {
            pickerComponent: photoPicker
            pickerLabel: qsTr("Photos")
            pickerImage: "image://theme/panels/pnl_icn_photos"
        }

        AttachmentPicker {
            pickerComponent: moviePicker
            pickerLabel: qsTr("Movies")
            pickerImage: "image://theme/panels/pnl_icn_video"
        }

        AttachmentPicker {
            pickerComponent: musicPicker
            pickerLabel: qsTr("Music")
            pickerImage: "image://theme/panels/pnl_icn_music"
        }
    }

//    Component {
//        id: documentPicker
//        Rectangle {
//            anchors.fill: parent
//            color: "pink"
//        }
//    }

    Component {
        id: musicPicker
        MusicPicker {
            //anchors.fill: parent

            showPlaylists: false
            showAlbums: false
            selectSongs: true

            onSongSelected: {
                console.log ("Song: " + title);
                pickerSelected(uri);
            }
        }
    }

    Component {
        id: photoPicker
        PhotoPicker {
            //anchors.fill: parent

            onPhotoSelected: {
                console.log ("Photo: " + uri);
                pickerSelected(uri);
            }

			onMultiplePhotosSelected: {
				console.log ("Multiple Photo Selected");
				pickerMultipleSelected(uris);
			}

        }
    }

    Component {
        id: moviePicker
        VideoPicker {
            //anchors.fill: parent

            onVideoSelected: {
                console.log ("Video: " + uri);
                pickerSelected(uri);
            }
        }
    }
}
