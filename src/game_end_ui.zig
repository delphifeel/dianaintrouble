const std = @import("std");
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");
const rutils = @import("rutils.zig");
const screen = @import("screen.zig");
const Text = @import("gui/text.zig");

const Player = @import("player.zig");

const s = "I love you Dianka, <3";

pub fn draw() void {
    rl.ClearBackground(rl.SKYBLUE);
    const screen_bounds = rutils.new_rect(0, 0, screen.width, screen.height);
    const text = Text.init_aligned(s, .Bigger, screen_bounds, .AllCenter);
    text.drawEx(rl.RED);
}
