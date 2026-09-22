-- LG C5 on this machine. Keep the everyday profile SDR and 8-bit.
-- Temporary 10-bit and HDR trials are handled by scripts/lg-c5-display-test.sh.
hl.monitor({
    output = "HDMI-A-1",
    mode = "3840x2160@143.99",
    position = "0x0",
    scale = 2.0,
    bitdepth = 8,
    cm = "srgb",
    vrr = 2,
})
