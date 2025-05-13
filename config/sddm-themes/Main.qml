import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: config.backgroundColor || "#1a1b26"

    property string user: userModel.lastUser

    Timer {
        id: timeTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            timeLabel.text = Qt.formatDateTime(new Date(), "hh:mm")
            dateLabel.text = Qt.formatDateTime(new Date(), "dddd, MMMM d")
        }
    }

    Image {
        id: backgroundImage
        anchors.fill: parent
        source: config.background || "background.jpg"
        fillMode: Image.PreserveAspectCrop

        FastBlur {
            id: backgroundBlur
            anchors.fill: backgroundImage
            source: backgroundImage
            radius: 40
        }
    }

    Rectangle {
        id: glassPanel
        anchors.centerIn: parent
        width: 550
        height: 620
        color: "transparent"
        radius: 16

        Rectangle {
            id: blurBackground
            anchors.fill: parent
            radius: 16
            color: Qt.rgba(24/255, 28/255, 59/255, 0.75)
            border.color: Qt.rgba(1, 1, 1, 0.05)
            border.width: 1

            layer.enabled: true
            layer.effect: DropShadow {
                radius: 20
                samples: 20
                color: Qt.rgba(0, 0, 0, 0.4)
                horizontalOffset: 0
                verticalOffset: 0
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 30
            width: parent.width - 80

            Item {
                width: parent.width
                height: 100
                
                Column {
                    anchors.centerIn: parent
                    spacing: 5
                    
                    Text {
                        id: timeLabel
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pointSize: 36
                        font.family: config.displayFont || "JetBrains Mono Nerd Font"
                        font.weight: Font.DemiBold
                        color: config.foreground || "#c0caf5"
                        text: Qt.formatDateTime(new Date(), "hh:mm")
                    }
                    
                    Text {
                        id: dateLabel
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pointSize: 12
                        font.family: config.displayFont || "JetBrains Mono Nerd Font"
                        color: config.foregroundInactive || "#565f89"
                        text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 20
                font.family: config.displayFont || "JetBrains Mono Nerd Font"
                color: config.foreground || "#c0caf5"
                text: config.titleText || "Welcome"
            }

            Rectangle {
                id: userSelection
                width: parent.width
                height: 60
                radius: 12
                color: config.inputColor || "#414868"
                
                ComboBox {
                    id: userBox
                    anchors.fill: parent
                    textRole: "name"
                    currentIndex: userModel.lastIndex
                    model: userModel
                    font.pointSize: 12
                    font.family: config.displayFont || "JetBrains Mono Nerd Font"
                    
                    delegate: ItemDelegate {
                        width: userBox.width
                        highlighted: userBox.highlightedIndex === index
                        contentItem: Text {
                            text: name
                            font.pointSize: 12
                            font.family: config.displayFont || "JetBrains Mono Nerd Font"
                            color: config.foreground || "#c0caf5"
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: highlighted ? Qt.rgba(122/255, 162/255, 247/255, 0.2) : Qt.rgba(0, 0, 0, 0)
                            radius: 12
                        }
                    }
                    
                    onCurrentIndexChanged: {
                        user = userModel.data(userModel.index(currentIndex, 0), Qt.UserRole + 1)
                    }
                    
                    background: Rectangle {
                        color: "transparent"
                        radius: 12
                        border.color: "transparent"
                    }
                    
                    contentItem: Text {
                        leftPadding: 12
                        text: userBox.displayText
                        font: userBox.font
                        color: config.foreground || "#c0caf5"
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            TextField {
                id: passwordField
                width: parent.width
                height: 60
                placeholderText: qsTr("Password")
                echoMode: TextInput.Password
                passwordCharacter: config.passwordCharacter || "•"
                font.pointSize: 12
                font.family: config.displayFont || "JetBrains Mono Nerd Font"
                selectionColor: config.accentColor || "#7dcfff"
                
                background: Rectangle {
                    radius: 12
                    color: config.inputColor || "#414868"
                }
                
                color: config.foreground || "#c0caf5"
                padding: 15
                
                Keys.onReturnPressed: tryLogin()
                Keys.onEnterPressed: tryLogin()
            }
            
            Button {
                id: loginButton
                width: parent.width
                height: 60
                text: config.loginButtonText || "Login"
                font.pointSize: 12
                font.family: config.displayFont || "JetBrains Mono Nerd Font"
                
                contentItem: Text {
                    text: loginButton.text
                    font: loginButton.font
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                background: Rectangle {
                    radius: 12
                    color: loginButton.down ? Qt.darker(config.buttonColorHover || "#bb9af7", 1.1) : 
                           loginButton.hovered ? config.buttonColorHover || "#bb9af7" : 
                           config.buttonColor || "#7aa2f7"
                    
                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }
                }
                
                onClicked: tryLogin()
            }
            
            Item {
                width: parent.width
                height: 20
                
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 20
                    
                    IconButton {
                        id: restartButton
                        iconSource: "assets/restart.svg"
                        tooltip: "Restart"
                        
                        onClicked: {
                            sddm.reboot()
                        }
                    }
                    
                    IconButton {
                        id: shutdownButton
                        iconSource: "assets/shutdown.svg"
                        tooltip: "Shutdown"
                        
                        onClicked: {
                            sddm.powerOff()
                        }
                    }
                    
                    IconButton {
                        id: sessionButton
                        iconSource: "assets/session.svg"
                        tooltip: "Session"
                        
                        onClicked: {
                            sessionPopup.open()
                        }
                    }
                }
            }
        }
    }
    
    Popup {
        id: sessionPopup
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: 300
        height: 400
        modal: true
        padding: 20
        
        background: Rectangle {
            color: Qt.rgba(24/255, 28/255, 59/255, 0.95)
            radius: 12
            border.color: Qt.rgba(1, 1, 1, 0.05)
            border.width: 1
            
            layer.enabled: true
            layer.effect: DropShadow {
                radius: 20
                samples: 20
                color: Qt.rgba(0, 0, 0, 0.4)
            }
        }
        
        contentItem: ListView {
            model: sessionModel
            spacing: 8
            clip: true
            
            delegate: ItemDelegate {
                width: parent.width
                height: 50
                
                background: Rectangle {
                    radius: 10
                    color: highlighted ? Qt.rgba(122/255, 162/255, 247/255, 0.2) : "transparent"
                }
                
                contentItem: Text {
                    text: model.name
                    font.pointSize: 12
                    font.family: config.displayFont || "JetBrains Mono Nerd Font"
                    color: config.foreground || "#c0caf5"
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                }
                
                highlighted: ListView.isCurrentItem
                
                onClicked: {
                    sessionModel.lastIndex = index
                    sessionPopup.close()
                }
            }
        }
    }
    
    Component.onCompleted: {
        timeTimer.start()
        passwordField.forceActiveFocus()
    }
    
    function tryLogin() {
        loginButton.enabled = false
        passwordField.enabled = false
        
        if (sddm.login(user, passwordField.text, sessionModel.lastIndex)) {
            loginSuccessAnimation.start()
        } else {
            passwordField.text = ""
            passwordField.enabled = true
            loginButton.enabled = true
            passwordField.forceActiveFocus()
            wrongPasswordAnimation.start()
        }
    }
    
    ParallelAnimation {
        id: wrongPasswordAnimation
        
        PropertyAnimation {
            target: passwordField
            property: "x"
            from: passwordField.x
            to: passwordField.x + 10
            duration: 100
            easing.type: Easing.InOutQuad
        }
        PropertyAnimation {
            target: passwordField
            property: "x"
            from: passwordField.x + 10
            to: passwordField.x - 10
            duration: 100
            easing.type: Easing.InOutQuad
        }
        PropertyAnimation {
            target: passwordField
            property: "x"
            from: passwordField.x - 10
            to: passwordField.x
            duration: 100
            easing.type: Easing.InOutQuad
        }
    }
    
    SequentialAnimation {
        id: loginSuccessAnimation
        
        PropertyAnimation {
            target: glassPanel
            property: "opacity"
            from: 1
            to: 0
            duration: 500
            easing.type: Easing.InOutQuad
        }
    }
}

// IconButton component
Component {
    id: iconButtonComponent
    
    Rectangle {
        id: button
        width: 38
        height: 38
        radius: 10
        color: "transparent"
        
        property alias iconSource: icon.source
        property string tooltip: ""
        signal clicked
        
        MouseArea {
            id: buttonArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: button.clicked()
        }
        
        Image {
            id: icon
            anchors.centerIn: parent
            width: 20
            height: 20
            fillMode: Image.PreserveAspectFit
            opacity: buttonArea.containsMouse ? 1 : 0.7
        }
        
        Rectangle {
            anchors.fill: parent
            radius: 10
            color: config.buttonColor || "#7aa2f7"
            opacity: buttonArea.containsMouse ? 0.2 : 0
            
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }
        }
    }
}