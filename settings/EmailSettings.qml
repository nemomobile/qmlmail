/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import QtQuick 1.0
import MeeGo.Labs.Components 0.1 as Labs
import MeeGo.Components 0.1
import MeeGo.Settings 0.1
import MeeGo.App.Email 0.1

AppPage {
    id: settingsPage
    property alias accountSettingsModel: accountSettingsModel
    pageTitle: qsTr("Email Settings")
    disableSearch: true
    Translator { catalog: "meego-app-email" }
    EmailAccount { id: emailAccount }
    EmailAccountSettingsModel { id: accountSettingsModel }
    Labs.ApplicationsModel { id: appModel }
    function returnToEmail() {
        var cmd = "/usr/bin/meego-qml-launcher --app meego-app-email --opengl --fullscreen"; //i18n ok
        appModel.launch(cmd);
    }
    Loader {
        id: loader
        anchors.fill: parent
    }
    function getRestoredHomescreen() {
        if(mainSaveRestoreState.restoreRequired) {
            if((mainSaveRestoreState.value("email-PageState") == "RegisterScreen") &&
                    (mainSaveRestoreState.value("email-PageState") != undefined) ) {
                emailAccount.clear();
                if(mainSaveRestoreState.value("email-account-preset") == "-1") {
                    emailAccount.recvSecurity = mainSaveRestoreState.value("email-account-recvSecurity");
                    emailAccount.sendAuth =  mainSaveRestoreState.value("email-account-sendAuth");
                    emailAccount.sendSecurity =  mainSaveRestoreState.value("email-account-sendSecurity");
                } else {
                    emailAccount.preset = mainSaveRestoreState.value("email-account-preset");
                    emailAccount.description= mainSaveRestoreState.value("email-account-description");
                }
                emailAccount.name = mainSaveRestoreState.value("email-account-name");
                emailAccount.address = mainSaveRestoreState.value("email-account-address");
                emailAccount.password = mainSaveRestoreState.value("email-account-password");
                emailAccount.recvType = mainSaveRestoreState.value("email-account-recvType");
                emailAccount.recvServer = mainSaveRestoreState.value("email-account-recvServer");
                emailAccount.recvPort = mainSaveRestoreState.value("email-account-recvPort");
                emailAccount.recvSecurity = mainSaveRestoreState.value("email-account-recvSecurity");
                emailAccount.recvUsername = mainSaveRestoreState.value("email-account-recvUsername");
                emailAccount.recvPassword = mainSaveRestoreState.value("email-account-recvPassword");
                emailAccount.sendServer = mainSaveRestoreState.value("email-account-sendServer");
                emailAccount.sendPort = mainSaveRestoreState.value("email-account-sendPort");
                emailAccount.sendAuth = mainSaveRestoreState.value("email-account-sendAuth");
                emailAccount.sendSecurity = mainSaveRestoreState.value("email-account-sendSecurity");
                emailAccount.sendUsername = mainSaveRestoreState.value("email-account-sendUsername");
                emailAccount.sendPassword = mainSaveRestoreState.value("email-account-sendPassword");
            }
            return mainSaveRestoreState.value("email-PageState");
        } else {
            return getHomescreen(); //by default
        }
    }

    function getHomescreen() {
        if (accountSettingsModel.rowCount() > 0) {
            return "SettingsScreen";
        } else {
            return "WelcomeScreen";
        }
    }

    SaveRestoreState {
        id: mainSaveRestoreState
        onSaveRequired: {
            setValue("email-PageState",settingsPage.state);

            setValue("email-account-name",emailAccount.name);
            setValue("email-account-address",emailAccount.address);
            setValue("email-account-password",emailAccount.password);
            setValue("email-account-recvType",emailAccount.recvType)
            setValue("email-account-recvServer",emailAccount.recvServer)
            setValue("email-account-recvPort",emailAccount.recvPort)
            setValue("email-account-recvSecurity",emailAccount.recvSecurity)
            setValue("email-account-recvUsername",emailAccount.recvUsername)
            setValue("email-account-recvPassword",emailAccount.recvPassword)
            setValue("email-account-sendServer",emailAccount.sendServer)
            setValue("email-account-sendPort",emailAccount.sendPort)
            setValue("email-account-sendAuth",emailAccount.sendAuth)
            setValue("email-account-sendSecurity",emailAccount.sendSecurity)
            setValue("email-account-sendUsername",emailAccount.sendUsername)
            setValue("email-account-sendPassword",emailAccount.sendPassword)

            setValue("email-sendPassword",emailAccount.sendPassword)



            sync();
        }
    }

    state: getRestoredHomescreen()
    states: [
        State {
            name: "WelcomeScreen"
            PropertyChanges { target: loader; source: "WelcomeScreen.qml" }
        },
        State {
            name: "SettingsScreen"
            PropertyChanges { target: loader; source: "AccountSettings.qml" }
        },
        State {
            name: "RegisterScreen"
            PropertyChanges { target: loader; source: "RegisterScreen.qml" }
        },
        State {
            name: "DetailsScreen"
            PropertyChanges { target: loader; source: "DetailsScreen.qml" }
        },
        State {
            name: "ConfirmScreen"
            PropertyChanges { target: loader; source: "ConfirmScreen.qml" }
        },
        State {
            name: "ManualScreen"
            PropertyChanges { target: loader; source: "ManualScreen.qml" }
        }
    ]
}
