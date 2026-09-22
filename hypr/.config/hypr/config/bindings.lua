local home = os.getenv("HOME")
local terminal = "kitty"
local browser = "helium-browser"
local file_manager = "dolphin"
local run_menu = "rofi -show run"
local app_menu = "rofi -show drun"
local main_mod = "SUPER"

hl.bind(main_mod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(main_mod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(main_mod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(main_mod .. " + C", hl.dsp.window.close())
hl.bind(main_mod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(main_mod .. " + M", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/logout.sh"))
hl.bind(main_mod .. " + E", hl.dsp.exec_cmd(file_manager))
hl.bind(main_mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(main_mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle", mode = "fullscreen" }))
hl.bind(main_mod .. " + R", hl.dsp.exec_cmd(run_menu))
hl.bind("ALT + SPACE", hl.dsp.exec_cmd(app_menu))
hl.bind(main_mod .. " + CTRL + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(main_mod .. " + CTRL + W", hl.dsp.exec_cmd([[sh -c 'pkill waybar; waybar']]))
hl.bind(main_mod .. " + SHIFT + 1", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/screenshot.sh area"))
hl.bind(main_mod .. " + SHIFT + 2", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/screenshot.sh full"))
hl.bind(main_mod .. " + SHIFT + 3", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/screenshot.sh active"))
hl.bind(main_mod .. " + P", hl.dsp.window.pseudo())
hl.bind(main_mod .. " + J", hl.dsp.layout("consume_or_expel next"))
hl.bind(main_mod .. " + SHIFT + J", hl.dsp.layout("promote"))

-- Scrolling layout: move the viewport, resize a column, or reorder columns.
hl.bind(main_mod .. " + ALT + left", hl.dsp.layout("move -col"))
hl.bind(main_mod .. " + ALT + right", hl.dsp.layout("move +col"))
hl.bind(main_mod .. " + ALT + up", hl.dsp.layout("colresize +conf"))
hl.bind(main_mod .. " + ALT + down", hl.dsp.layout("colresize -conf"))
hl.bind(main_mod .. " + SHIFT + left", hl.dsp.layout("swapcol l"))
hl.bind(main_mod .. " + SHIFT + right", hl.dsp.layout("swapcol r"))
hl.bind(main_mod .. " + ALT + C", hl.dsp.layout("center"))

-- These modes are shown in Waybar. Escape or Return always exits them.
hl.bind(main_mod .. " + SHIFT + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    local step = 20
    local repeatable = { repeating = true }
    hl.bind("left", hl.dsp.window.resize({ x = -step, y = 0, relative = true }), repeatable)
    hl.bind("right", hl.dsp.window.resize({ x = step, y = 0, relative = true }), repeatable)
    hl.bind("up", hl.dsp.window.resize({ x = 0, y = -step, relative = true }), repeatable)
    hl.bind("down", hl.dsp.window.resize({ x = 0, y = step, relative = true }), repeatable)
    hl.bind("h", hl.dsp.window.resize({ x = -step, y = 0, relative = true }), repeatable)
    hl.bind("l", hl.dsp.window.resize({ x = step, y = 0, relative = true }), repeatable)
    hl.bind("k", hl.dsp.window.resize({ x = 0, y = -step, relative = true }), repeatable)
    hl.bind("j", hl.dsp.window.resize({ x = 0, y = step, relative = true }), repeatable)
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("return", hl.dsp.submap("reset"))
    hl.bind(main_mod .. " + SHIFT + R", hl.dsp.submap("reset"))
    hl.bind("catchall", hl.dsp.submap("reset"))
end)

hl.bind(main_mod .. " + G", hl.dsp.submap("groups"))
hl.define_submap("groups", function()
    hl.bind("g", hl.dsp.group.toggle())
    hl.bind("h", hl.dsp.window.move({ into_or_create_group = "l" }))
    hl.bind("l", hl.dsp.window.move({ into_or_create_group = "r" }))
    hl.bind("u", hl.dsp.window.move({ out_of_group = true }))
    hl.bind("n", hl.dsp.group.next())
    hl.bind("p", hl.dsp.group.prev())
    hl.bind("k", hl.dsp.group.lock_active())
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("return", hl.dsp.submap("reset"))
    hl.bind(main_mod .. " + G", hl.dsp.submap("reset"))
    hl.bind("catchall", hl.dsp.submap("reset"))
end)

hl.bind(main_mod .. " + left", hl.dsp.layout("focus l"))
hl.bind(main_mod .. " + right", hl.dsp.layout("focus r"))
hl.bind(main_mod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(main_mod .. " + down", hl.dsp.focus({ direction = "down" }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(main_mod .. " + CTRL + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(main_mod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(main_mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(main_mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(main_mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), {
    locked = true,
    repeating = true,
})
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), {
    locked = true,
    repeating = true,
})
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), {
    locked = true,
    repeating = true,
})
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), {
    locked = true,
    repeating = true,
})
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), {
    locked = true,
    repeating = true,
})
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), {
    locked = true,
    repeating = true,
})

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
