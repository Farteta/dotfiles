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
    property int cornerRadius: 18
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
        radius: container.cornerRadius

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
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Up) {
            moveCurrentIndex(-1)
            event.accepted = true
        } else if (event.key === Qt.Key_Down) {
            moveCurrentIndex(1)
            event.accepted = true
        } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            close(true)
            event.accepted = true
        } else if (event.key === Qt.Key_Escape) {
            close(false)
            event.accepted = true
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
        radius: container.cornerRadius
        clip: true
        visible: height > 0

        Component {
            id: itemDelegate

            Rectangle {
                property bool activeSession: index === container.index
                width: dropDown.width
                height: activeSession ? 0 : container.height
                visible: !activeSession
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
                    height: container.dropDownHeight()
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
        if (selectableCount() === 0)
            return

        dropDown.state = "visible"
        listView.currentIndex = firstSelectableIndex()
        listView.positionViewAtIndex(listView.currentIndex, ListView.Contain)
    }

    function close(update) {
        dropDown.state = ""

        if (update && listView.currentIndex !== container.index && listView.currentIndex >= 0) {
            container.index = listView.currentIndex
            if (listView.currentItem)
                topRow.modelItem = listView.currentItem.modelItem
            valueChanged(listView.currentIndex)
        } else {
            listView.currentIndex = container.index
        }
    }

    function selectableCount() {
        return Math.max(0, listView.count - 1)
    }

    function dropDownHeight() {
        if (selectableCount() === 0)
            return 0
        return Math.min(selectableCount() * container.height + 2, container.height * 6 + 2)
    }

    function firstSelectableIndex() {
        for (var i = 0; i < listView.count; i++) {
            if (i !== container.index)
                return i
        }
        return container.index
    }

    function moveCurrentIndex(step) {
        if (selectableCount() === 0)
            return

        var nextIndex = listView.currentIndex >= 0 ? listView.currentIndex : container.index
        for (var i = 0; i < listView.count; i++) {
            nextIndex = (nextIndex + step + listView.count) % listView.count
            if (nextIndex !== container.index) {
                listView.currentIndex = nextIndex
                listView.positionViewAtIndex(nextIndex, ListView.Contain)
                return
            }
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
