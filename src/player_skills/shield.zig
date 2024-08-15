const std = @import("std");
const rl = @import("../raylib.zig");
const rm = @import("../raymath.zig");
const rutils = @import("../rutils.zig");

const Player = @import("../player.zig");

const Self = @This();

time_passed: f32 = 0,
restore_amount: f32 = 50,
restore_speed: f32 = 1,

pub fn init() Self {
    return Self{};
}
pub fn deinit(_: *Self) void {}

pub fn update(self: *Self, player: *Player) void {
    if (player.entity.shield == 0) {
        self.time_passed += rl.GetFrameTime();
    }
    const restore_timeout = 10 / self.restore_speed;
    if (self.time_passed >= restore_timeout) {
        self.time_passed = 0;
        player.entity.shield = @intFromFloat(self.restore_amount);
    }
}

pub fn draw(_: *const Self) void {}
