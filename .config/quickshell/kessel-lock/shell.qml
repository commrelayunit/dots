// SPDX-License-Identifier: GPL-3.0-or-later
// Kessel lock screen — a separate Quickshell config that runs only while the
// session is locked, then exits. Started by ~/.config/hypr/scripts/lock.sh,
// which falls back to hyprlock if this cannot lock securely.
//
// Preview without locking (for development):  KESSEL_LOCK_PREVIEW=1 qs -c kessel-lock
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: shell

    LockContext {
        id: ctx
        onUnlocked: action => {
            if (action === LockContext.Action.Poweroff) { Quickshell.execDetached(["systemctl", "poweroff"]); return }
            if (action === LockContext.Action.Reboot)   { Quickshell.execDetached(["systemctl", "reboot"]); return }
            if (ctx.keepAwake) Quickshell.execDetached(["qs", "-c", "kessel", "ipc", "call", "island", "stayAwake", "true"])
            if (ctx.preview) { Qt.quit(); return }
            lock.locked = false
        }
    }

    // ── the real lock ────────────────────────────────────────────────────────
    WlSessionLock {
        id: lock
        locked: !ctx.preview
        onLockedChanged: if (!locked) quitTimer.start()   // let the unlock reach the compositor first
        WlSessionLockSurface {
            color: "black"
            LockSurface { anchors.fill: parent; context: ctx }
        }
    }
    Timer { id: quitTimer; interval: 150; onTriggered: Qt.quit() }

    // lock.sh asks whether the compositor confirmed the lock
    IpcHandler {
        target: "lockstate"
        function secure(): string { return lock.secure ? "yes" : "no" }
    }

    // ── preview (no session lock) ────────────────────────────────────────────
    Variants {
        model: ctx.preview ? Quickshell.screens : []
        PanelWindow {
            required property var modelData
            screen: modelData
            anchors { top: true; bottom: true; left: true; right: true }
            exclusionMode: ExclusionMode.Ignore
            color: "black"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "kessel-lock-preview"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            LockSurface {
                anchors.fill: parent
                context: ctx
                Keys.onEscapePressed: Qt.quit()
            }
        }
    }
}
