-- Simon's modular Hyprland configuration.
-- Each module is isolated by Hyprland's require wrapper, so a failure in one
-- secondary module does not prevent the remaining modules from loading.

require("config.monitors")
require("config.monitors.lg_c5")

-- Machine-specific monitor and input settings live outside the repository.
local host_path = os.getenv("HOME") .. "/.config/hypr/host.lua"
local host_ok, host_error = pcall(dofile, host_path)
if not host_ok then
    print("Hyprland host config was not loaded: " .. tostring(host_error))
end

require("config.environment")
require("config.autostart")
require("config.plugins")
require("config.appearance")
require("config.layouts")
require("config.input")
require("config.bindings")
require("config.rules")
