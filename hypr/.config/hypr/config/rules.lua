hl.window_rule({
    name = "dolphin-opacity",
    match = { class = [[^org\.kde\.dolphin$]] },
    opacity = "0.98 0.95",
})

hl.window_rule({
    name = "kde-file-dialog-opacity",
    match = {
        class = [[^(org\.freedesktop\.impl\.portal\.desktop\.kde|org\.kde\.kdialog)$]],
    },
    opacity = "0.98 0.95",
})

hl.window_rule({
    name = "panel-volume",
    match = { class = [[^(pavucontrol|Pavucontrol)$]] },
    float = true,
    size = { 860, 560 },
    move = { "monitor_w-w-24", 52 },
})

hl.window_rule({
    name = "panel-volume-title",
    match = { title = [[^(Volume Control|PulseAudio Volume Control)$]] },
    float = true,
    size = { 860, 560 },
    move = { "monitor_w-w-24", 52 },
})

hl.window_rule({
    name = "panel-network",
    match = { class = [[^(nm-connection-editor|Nm-connection-editor)$]] },
    float = true,
    size = { 980, 640 },
    move = { "monitor_w-w-24", 52 },
})

hl.window_rule({
    name = "panel-network-title",
    match = { title = [[^Network Connections$]] },
    float = true,
    size = { 980, 640 },
    move = { "monitor_w-w-24", 52 },
})

hl.window_rule({
    name = "panel-bluetooth",
    match = { class = [[^(blueman-manager|Blueman-manager)$]] },
    float = true,
    size = { 900, 620 },
    move = { "monitor_w-w-24", 52 },
})

hl.window_rule({
    name = "panel-bluetooth-title",
    match = { title = [[^Bluetooth Devices$]] },
    float = true,
    size = { 900, 620 },
    move = { "monitor_w-w-24", 52 },
})

hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

hl.window_rule({
    name = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move = { 20, "monitor_h-120" },
    float = true,
})

-- Edge-to-edge for a lone visible tiled window or a maximized window.
-- Special workspaces keep their normal gaps and rounded corners.
for _, selector in ipairs({ "w[tv1]s[false]", "f[1]s[false]" }) do
    hl.workspace_rule({ workspace = selector, gaps_out = 0, gaps_in = 0 })
    hl.window_rule({
        name = "smart-gaps-border-" .. selector,
        match = { float = false, workspace = selector },
        border_size = 0,
    })
    hl.window_rule({
        name = "smart-gaps-rounding-" .. selector,
        match = { float = false, workspace = selector },
        rounding = 0,
    })
end
