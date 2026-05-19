import QtQuick 2.15

FocusScope {
    id: container

    width: 80
    height: 30

    property color color: "transparent"
    property color borderColor: "transparent"
    property color focusColor: "#87b8ff"
    property color hoverColor: Qt.rgba(1, 1, 1, 0.08)
    property color menuColor: Qt.rgba(7/255, 10/255, 15/255, 0.96)
    property color textColor: Qt.rgba(1, 1, 1, 0.78)
    property color menuBorderColor: Qt.rgba(1, 1, 1, 0.08)

    property int borderWidth: 1
    property font font
    property alias model: listView.model
    property int index: 0

    signal valueChanged(int id)

    Component {
        id: rowDelegate

        Text {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 26
            verticalAlignment: Text.AlignVCenter
            color: container.textColor
            font: container.font
            elide: Text.ElideRight
            text: parent.modelItem.name
        }
    }

    onFocusChanged: if (!container.activeFocus) close(false)

    Rectangle {
        id: main
        anchors.fill: parent
        color: container.color
        border.color: container.activeFocus ? container.focusColor : container.borderColor
        border.width: container.borderWidth
        radius: 16

        Behavior on border.color { ColorAnimation { duration: 120 } }
    }

    Loader {
        id: topRow
        anchors.fill: parent
        sourceComponent: rowDelegate
        property variant modelItem
    }

    Text {
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        text: dropDown.state === "visible" ? "\u25b4" : "\u25be"
        font.family: container.font.family
        font.pixelSize: 11
        color: container.textColor
    }

    MouseArea {
        id: mouseArea
        anchors.fill: container
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: {
            container.focus = true
            toggle()
        }
        onWheel: {
            if (wheel.angleDelta.y > 0)
                listView.decrementCurrentIndex()
            else
                listView.incrementCurrentIndex()
        }
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Up) {
            listView.decrementCurrentIndex()
        } else if (event.key === Qt.Key_Down) {
            listView.incrementCurrentIndex()
        } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            close(true)
        } else if (event.key === Qt.Key_Escape) {
            close(false)
        }
    }

    Rectangle {
        id: dropDown
        width: container.width
        height: 0
        anchors.bottom: container.top
        anchors.bottomMargin: 8
        color: container.menuColor
        border.color: container.menuBorderColor
        border.width: 1
        radius: 16
        clip: true
        visible: height > 0

        Component {
            id: itemDelegate

            Rectangle {
                width: dropDown.width
                height: container.height
                color: ListView.isCurrentItem ? container.hoverColor : "transparent"

                Loader {
                    anchors.fill: parent
                    sourceComponent: rowDelegate
                    property variant modelItem: model
                }

                property variant modelItem: model

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: listView.currentIndex = index
                    onClicked: close(true)
                }
            }
        }

        ListView {
            id: listView
            anchors.fill: parent
            anchors.margins: 1
            implicitHeight: container.height * count
            model: []
            delegate: itemDelegate
            currentIndex: container.index
            clip: true
        }

        states: [
            State {
                name: "visible"
                PropertyChanges {
                    target: dropDown
                    height: Math.min(listView.implicitHeight + 2, container.height * 6 + 2)
                }
            }
        ]

        transitions: Transition {
            NumberAnimation { property: "height"; duration: 120 }
        }
    }

    function toggle() {
        if (dropDown.state === "visible")
            close(false)
        else
            open()
    }

    function open() {
        dropDown.state = "visible"
        listView.currentIndex = container.index
        listView.positionViewAtIndex(container.index, ListView.Contain)
    }

    function close(update) {
        dropDown.state = ""

        if (update) {
            container.index = listView.currentIndex
            if (listView.currentItem)
                topRow.modelItem = listView.currentItem.modelItem
            valueChanged(listView.currentIndex)
        }
    }

    Component.onCompleted: {
        listView.currentIndex = container.index
        if (listView.currentItem)
            topRow.modelItem = listView.currentItem.modelItem
    }

    onIndexChanged: {
        listView.currentIndex = container.index
        if (listView.currentItem)
            topRow.modelItem = listView.currentItem.modelItem
    }

    onModelChanged: {
        listView.currentIndex = container.index
        if (listView.currentItem)
            topRow.modelItem = listView.currentItem.modelItem
    }
}
