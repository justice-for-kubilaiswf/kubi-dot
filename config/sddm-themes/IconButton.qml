import QtQuick 2.12
import QtQuick.Controls 2.12

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