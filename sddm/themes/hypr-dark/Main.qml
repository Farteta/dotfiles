import QtQuick 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0

Item {
    id: root

    property string notification: ""
    property bool loggingIn: false

    readonly property string fontFamily:   config.font        || "JetBrainsMono Nerd Font"
    readonly property color accentBlue:    config.accentColor || "#87b8ff"
    readonly property color bgOverlay:     "#10151f"
    readonly property color textPrimary:   "#eeeeee"
    readonly property color textSecondary: Qt.rgba(1, 1, 1, 0.6)
    readonly property color textMuted:     Qt.rgba(1, 1, 1, 0.33)
    readonly property color successGreen:  "#a6e3a1"
    readonly property color errorRed:      "#f38ba8"
    readonly property color inputBg:       Qt.rgba(16/255, 21/255, 31/255, 0.8)
    readonly property color chromeBg:      Qt.rgba(7/255, 10/255, 15/255, 0.34)
    readonly property color chromeBorder:  Qt.rgba(1, 1, 1, 0.08)

    TextConstants { id: textConstants }

    // Primary screen geometry for UI positioning
    property var primaryScreen: screenModel.geometry(screenModel.primary)

    // ── Background (per-screen) ─────────────────────────────────
    Repeater {
        model: screenModel
        Background {
            x: geometry.x; y: geometry.y
            width: geometry.width; height: geometry.height
            source: config.background
            fillMode: Image.PreserveAspectCrop
        }
    }

    // ── Blur + overlay on primary screen ────────────────────────
    Item {
        id: blurLayer
        x: primaryScreen.x; y: primaryScreen.y
        width: primaryScreen.width; height: primaryScreen.height
        clip: true

        Image {
            anchors.fill: parent
            source: config.background
            fillMode: Image.PreserveAspectCrop
        }

        Rectangle {
            anchors.fill: parent
            color: root.bgOverlay
            opacity: 0.82
        }

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.12) }
                GradientStop { position: 0.38; color: "transparent" }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.34) }
            }
        }
    }

    // ── Clock ───────────────────────────────────────────────────
    ColumnLayout {
        id: clockBlock
        x: primaryScreen.x + (primaryScreen.width - width) / 2
        y: primaryScreen.y + (primaryScreen.height - height) / 2 - 88
        spacing: 4

        Text {
            id: timeLabel
            Layout.alignment: Qt.AlignHCenter
            font.family: root.fontFamily
            font.pixelSize: 102
            font.weight: Font.Light
            color: Qt.rgba(1, 1, 1, 0.93)
            renderType: Text.CurveRendering
        }

        Text {
            id: dateLabel
            Layout.alignment: Qt.AlignHCenter
            font.family: root.fontFamily
            font.pixelSize: 18
            color: root.textSecondary
            renderType: Text.CurveRendering
        }
    }

    Timer {
        interval: 1000; running: true; repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            timeLabel.text = Qt.formatTime(now, "HH:mm")
            dateLabel.text = Qt.formatDate(now, "dddd, dd MMMM yyyy")
        }
    }

    // ── Central login column (on primary screen) ────────────────
    Item {
        id: loginColumn
        x: primaryScreen.x + (primaryScreen.width - width) / 2
        y: Math.max(primaryScreen.y + primaryScreen.height * 0.52,
                    primaryScreen.y + primaryScreen.height - height - 72)
        width: 364
        height: cardColumn.implicitHeight

        Behavior on opacity { NumberAnimation { duration: 300 } }

        ColumnLayout {
            id: cardColumn
            anchors.fill: parent
            anchors.margins: 0
            spacing: 0

            Item {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 120
                Layout.preferredHeight: 120

                Rectangle {
                    id: avatarBorder
                    anchors.fill: parent
                    radius: width / 2
                    color: Qt.rgba(1, 1, 1, 0.04)
                    border.width: 3
                    border.color: Qt.rgba(1, 1, 1, 0.4)
                }

                Rectangle {
                    id: avatarClip
                    anchors.fill: parent
                    anchors.margins: avatarBorder.border.width
                    radius: width / 2
                    clip: true
                    color: "transparent"

                    Image {
                        id: avatarSource
                        anchors.fill: parent
                        source: userImage()
                        fillMode: Image.PreserveAspectCrop
                        visible: avatarSource.status === Image.Ready
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "\uf007"
                    font.family: root.fontFamily
                    font.pixelSize: 48
                    color: root.textSecondary
                    visible: avatarSource.status !== Image.Ready
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 16
                text: userModel.lastUser || "User"
                font.family: root.fontFamily
                font.pixelSize: 24
                font.weight: Font.Light
                color: root.textPrimary
                renderType: Text.CurveRendering
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 8
                text: root.loggingIn ? "Authenticating..." : ""
                font.family: root.fontFamily
                font.pixelSize: 12
                color: root.textSecondary
                visible: text !== ""
                renderType: Text.CurveRendering
            }

            Item {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 22
                Layout.preferredWidth: 364
                Layout.preferredHeight: 58

                    Rectangle {
                        id: inputRect
                        anchors.fill: parent
                        radius: 18
                        color: root.inputBg
                    border.width: 2
                    border.color: {
                        if (root.notification === textConstants.loginFailed)
                            return root.errorRed
                        return passwordField.activeFocus ? root.accentBlue : Qt.rgba(1, 1, 1, 0.12)
                    }

                    Behavior on border.color { ColorAnimation { duration: 200 } }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 18
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\uf023"
                        font.family: root.fontFamily
                        font.pixelSize: 16
                        color: passwordField.activeFocus ? root.accentBlue : root.textMuted
                    }

                    TextInput {
                        id: passwordField
                        anchors.fill: parent
                        anchors.leftMargin: 50
                        anchors.rightMargin: 20
                        verticalAlignment: TextInput.AlignVCenter
                        font.family: root.fontFamily
                        font.pixelSize: 15
                        font.letterSpacing: 3
                        color: root.textPrimary
                        echoMode: TextInput.Password
                        passwordCharacter: "\u25cf"
                        clip: true
                        focus: true
                        enabled: !root.loggingIn

                        Keys.onReturnPressed: doLogin()
                        Keys.onEnterPressed:  doLogin()
                        Keys.onEscapePressed: { text = ""; root.notification = "" }
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 50
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Password"
                        font.family: root.fontFamily
                        font.pixelSize: 13
                        color: root.textMuted
                        visible: !passwordField.text && !passwordField.activeFocus
                    }
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 14
                text: root.notification
                font.family: root.fontFamily
                font.pixelSize: 12
                color: root.notification === textConstants.loginSucceeded
                       ? root.successGreen : root.errorRed
                visible: root.notification !== ""
                renderType: Text.CurveRendering
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: root.notification ? 6 : 12
                text: "Press ESC to clear input"
                font.family: root.fontFamily
                font.pixelSize: 11
                color: root.textMuted
                visible: true
                renderType: Text.CurveRendering
            }

        }
    }

    // ── Power controls (top-right of primary) ───────────────────
    Rectangle {
        x: primaryScreen.x + primaryScreen.width - width - 24
        y: primaryScreen.y + 24
        width: powerRow.implicitWidth + 20
        height: powerRow.implicitHeight + 12
        radius: 24
        color: root.chromeBg
        border.width: 1
        border.color: root.chromeBorder

        Row {
            id: powerRow
            anchors.centerIn: parent
            spacing: 10

            PowerButton {
                label: "Restart";  icon: "\uf0e2"
                enabled: sddm.canReboot
                onClicked: sddm.reboot()
                fontFamily: root.fontFamily
                accentColor: root.accentBlue
                textColor: root.textSecondary
            }

            PowerButton {
                label: "Shut Down"; icon: "\uf011"
                enabled: sddm.canPowerOff
                onClicked: sddm.powerOff()
                fontFamily: root.fontFamily
                accentColor: root.accentBlue
                textColor: root.textSecondary
            }

            PowerButton {
                label: "Sleep"; icon: "\uf186"
                enabled: sddm.canSuspend
                onClicked: sddm.suspend()
                fontFamily: root.fontFamily
                accentColor: root.accentBlue
                textColor: root.textSecondary
            }
        }
    }

    // ── Footer: session selector (bottom-left of primary) ───────
    Rectangle {
        x: primaryScreen.x + 24
        y: primaryScreen.y + primaryScreen.height - height - 24
        width: sessionRow.width + 28
        height: 44
        radius: 22
        color: root.chromeBg
        border.width: 1
        border.color: root.chromeBorder

        Row {
            id: sessionRow
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: "\ue795"
                font.family: root.fontFamily
                font.pixelSize: 14
                color: root.textMuted
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "Session"
                font.family: root.fontFamily
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: root.textMuted
                anchors.verticalCenter: parent.verticalCenter
            }

            SessionComboBox {
                id: sessionSelect
                model: sessionModel
                index: sessionModel.lastIndex
                width: 200; height: 32
                font.family: root.fontFamily
                font.pixelSize: 13
                color: "transparent"
                textColor: root.textSecondary
                borderColor: "transparent"
                focusColor: root.accentBlue
                hoverColor: Qt.rgba(1, 1, 1, 0.08)
                menuColor: Qt.rgba(7/255, 10/255, 15/255, 0.96)
                menuBorderColor: root.chromeBorder
            }
        }
    }

    // ── Reject shake animation ──────────────────────────────────
    SequentialAnimation {
        id: rejectAnimation
        property int d: 50
        NumberAnimation { target: loginColumn; property: "x"; to: loginColumn.x - 12; duration: rejectAnimation.d }
        NumberAnimation { target: loginColumn; property: "x"; to: loginColumn.x + 12; duration: rejectAnimation.d }
        NumberAnimation { target: loginColumn; property: "x"; to: loginColumn.x - 8;  duration: rejectAnimation.d }
        NumberAnimation { target: loginColumn; property: "x"; to: loginColumn.x + 8;  duration: rejectAnimation.d }
        NumberAnimation { target: loginColumn; property: "x"; to: loginColumn.x;      duration: 60 }
    }

    // ── SDDM signals ───────────────────────────────────────────
    Connections {
        target: sddm

        function onLoginSucceeded() {
            root.notification = textConstants.loginSucceeded
            root.loggingIn = false
            loginColumn.opacity = 0
            clockBlock.opacity = 0
        }

        function onLoginFailed() {
            root.notification = textConstants.loginFailed
            root.loggingIn = false
            passwordField.text = ""
            passwordField.forceActiveFocus()
            rejectAnimation.start()
        }
    }

    // ── Helpers ─────────────────────────────────────────────────
    function doLogin() {
        if (passwordField.text === "") return
        root.loggingIn = true
        root.notification = ""
        sddm.login(userModel.lastUser, passwordField.text, sessionSelect.index)
    }

    function userImage() {
        if (typeof userModel.data === "function" && userModel.lastIndex >= 0) {
            var img = userModel.data(userModel.index(userModel.lastIndex, 0), 101)
            if (img && img.toString() !== "") return img
        }
        return ""
    }

    Component.onCompleted: passwordField.forceActiveFocus()
}
