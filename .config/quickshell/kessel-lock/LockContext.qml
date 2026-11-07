// SPDX-License-Identifier: GPL-3.0-or-later
// Authentication state shared by every monitor's lock surface.
// Passwords are checked by PAM (service "hyprlock" → includes "login"), exactly
// like hyprlock; nothing is stored or logged.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam

Scope {
    id: root

    enum Action { Unlock, Poweroff, Reboot }

    readonly property bool preview: Quickshell.env("KESSEL_LOCK_PREVIEW") === "1"
    property string currentText: ""
    property bool unlockInProgress: false
    property bool failed: false
    property int targetAction: LockContext.Action.Unlock
    property bool keepAwake: false          // CTRL+Enter: unlock and keep the session awake

    signal unlocked(int action)
    signal shouldReFocus()

    function resetTargetAction() { targetAction = LockContext.Action.Unlock }
    function resetClearTimer() { clearTimer.restart() }

    // Typed-but-abandoned passwords are cleared after 10 s of inactivity.
    Timer { id: clearTimer; interval: 10000; onTriggered: root.currentText = "" }
    onCurrentTextChanged: { if (currentText.length > 0) { failed = false; clearTimer.restart() } }

    function tryUnlock(ctrlHeld) {
        if (unlockInProgress || currentText.length === 0) return
        keepAwake = !!ctrlHeld
        unlockInProgress = true
        if (!pam.start()) { fail(); return }
    }
    function fail() {
        unlockInProgress = false
        failed = true
        currentText = ""
        shouldReFocus()
    }

    PamContext {
        id: pam
        config: "hyprlock"
        onPamMessage: { if (responseRequired) respond(root.currentText) }
        onCompleted: result => {
            if (result === PamResult.Success) {
                root.unlockInProgress = false
                root.currentText = ""
                root.unlocked(root.targetAction)
            } else {
                root.fail()
            }
        }
        onError: root.fail()
    }

    // Test hook for the non-locking preview only. In a real lock there is no IPC
    // that accepts a password.
    IpcHandler {
        target: "lock"
        enabled: root.preview
        function status(): string {
            return JSON.stringify({ preview: root.preview, failed: root.failed, busy: root.unlockInProgress, typed: root.currentText.length })
        }
        function tryPassword(pw: string): string { root.currentText = pw; root.tryUnlock(false); return "started" }
    }
}
