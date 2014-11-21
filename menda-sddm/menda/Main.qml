import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
    id: container
    width: 1600
    height: 900

    Connections {
        target: sddm

        onLoginSucceeded: {
            errorMessage.color = "green"
            errorMessage.text = qsTr("Login succeeded.")
        }

        onLoginFailed: {
            errorMessage.color = "red"
            errorMessage.text = qsTr("Login failed.")
        }
    }

    Rectangle {
        id: rectangle1
        property variant geometry: screenModel.geometry(screenModel.primary)
        color: "transparent"
        anchors.fill: parent

        Image {
            id: background
            anchors.fill: parent
            source: "background.jpg"
        }

        Text {
            color: "#ffffff"
            text: qsTr("Welcome to ") + sddm.hostName
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.top: parent.top
            anchors.topMargin: 15
            font.pixelSize: 24
        }

        Button {
            id: shutdownButton
            color: "#59B949"
            text: qsTr("Shutdown")
            borderColor: "#1e1e1e"
            activeColor: "#59B949"
            border.color: "#1e1e1e"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 10

            onClicked: sddm.powerOff()

            KeyNavigation.backtab: loginButton; KeyNavigation.tab: rebootButton
        }

        Button {
            id: rebootButton
            color: "#59B949"
            text: qsTr("Reboot")
            border.color: "#1e1e1e"
            activeColor: "#59B949"
            borderColor: "#1e1e1e"
            anchors.right: parent.right
            anchors.rightMargin: 100
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10

            onClicked: sddm.reboot()

            KeyNavigation.backtab: shutdownButton; KeyNavigation.tab: name
        }

        Column {
            id: column1
            width: 511
            height: 245
            anchors.top: parent.top
            anchors.topMargin: 100
            anchors.left: parent.left
            anchors.leftMargin: 60
            spacing: 12

            Column {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 4
                Text {
                    id: lblName
                    width: 60
                    color: "#ffffff"
                    text: qsTr("User name")
                    font.bold: true
                    font.pixelSize: 12
                }

                TextBox {
                    id: name
                    width: parent.width; height: 30
                    text: userModel.lastUser
                    font.pixelSize: 14

                    KeyNavigation.backtab: rebootButton; KeyNavigation.tab: 
password

                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return || event.key === 
Qt.Key_Enter) {
                            sddm.login(name.text, password.text, session.index)
                            event.accepted = true
                        }
                    }
                }
            }

            Column {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                spacing : 4
                Text {
                    id: lblPassword
                    width: 60
                    color: "#ffffff"
                    text: qsTr("Password")
                    font.bold: true
                    font.pixelSize: 12
                }

                TextBox {
                    id: password
                    width: parent.width; height: 30
                    font.pixelSize: 14

                    echoMode: TextInput.Password

                    KeyNavigation.backtab: name; KeyNavigation.tab: session

                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return) {
                            sddm.login(name.text, password.text, session.index)
                            event.accepted = true
                        }
                    }
                }
            }

            Column {
                z: 100
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                spacing : 4
                Text {
                    id: lblSession
                    width: 60
                    color: "#ffffff"
                    text: qsTr("Session")
                    font.bold: true
                    font.pixelSize: 12
                }

                ComboBox {
                    id: session
                    width: parent.width; height: 30
                    font.pixelSize: 14

                    arrowIcon: "angle-down.png"

                    model: sessionModel
                    index: sessionModel.lastIndex

                    KeyNavigation.backtab: password; KeyNavigation.tab: 
loginButton
                }
            }

            Column {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    id: errorMessage
                    color: "#ffffff"
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Enter your user name and password.")
                    font.pixelSize: 10
                }
            }

            Row {
                id: row1
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 40
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 4

                Button {
                    id: loginButton
                    width: 120
                    color: "#59B949"
                    text: qsTr("Login")
                    activeColor: "#59B949"
                    borderColor: "#1e1e1e"
                    border.color: "#1e1e1e"
                    anchors.horizontalCenter: parent.horizontalCenter

                    onClicked: sddm.login(name.text, password.text, session.index)

                    KeyNavigation.backtab: session; KeyNavigation.tab: shutdownButton
                }
            }
        }





    }

    Component.onCompleted: {
        if (name.text == "")
            name.focus = true
        else
            password.focus = true
    }
}
