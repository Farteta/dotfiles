import QtQuick 2.15

Item {
    id: btn

    property string label: ""
    property string icon: ""
    property string fontFamily: ""
    property color accentColor: "#87b8ff"
    property color textColor: Qt.rgba(1, 1, 1, 0.6)

    signal clicked()

    width: col.implicitWidth + 22
    height: col.implicitHeight + 14
    opacity: enabled ? (mouseArea.containsMouse ? 1.0 : 0.8) : 0.3

    Behavior on opacity { NumberAnimation { duration: 150 } }

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: mouseArea.containsMouse
               ? Qt.rgba(btn.accentColor.r, btn.accentColor.g, btn.accentColor.b, 0.10)
               : Qt.rgba(1, 1, 1, 0.03)
        border.width: 1
        border.color: mouseArea.containsMouse
                      ? Qt.rgba(btn.accentColor.r, btn.accentColor.g, btn.accentColor.b, 0.18)
                      : Qt.rgba(1, 1, 1, 0.06)

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
    }

    Column {
        id: col
        anchors.centerIn: parent
        spacing: 6

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 38; height: 38
            radius: width / 2
            color: mouseArea.containsMouse
                   ? Qt.rgba(btn.accentColor.r, btn.accentColor.g, btn.accentColor.b, 0.12)
                   : Qt.rgba(1, 1, 1, 0.04)

            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: btn.icon
                font.family: btn.fontFamily
                font.pixelSize: 17
                color: mouseArea.containsMouse ? btn.accentColor : btn.textColor

                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: btn.label
            font.family: btn.fontFamily
            font.pixelSize: 11
            font.weight: Font.Normal
            color: mouseArea.containsMouse ? btn.accentColor : btn.textColor

            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
    }
}
