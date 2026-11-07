-- SPDX-License-Identifier: GPL-3.0-or-later
-- Displays. Kessel: QEMU/VirtIO GPU, output "Virtual-1".
-- Current mode chosen by the user: 1920x1080 (was 2560x1440). Auto scale → 1.5.
-- Rollback/alternative: set mode = "2560x1440" (auto scale → 1.6).

hl.monitor({
    output   = "",          -- any monitor (only Virtual-1 exists)
    mode     = "1920x1080",
    position = "0x0",
    scale    = "auto",
})
