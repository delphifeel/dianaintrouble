const std = @import("std");
const rl = @import("../raylib.zig");
const rm = @import("../raymath.zig");
const rutils = @import("../rutils.zig");

const Player = @import("../player.zig");

const Self = @This();

center: rl.Vector2,

radius: f32 = 100,
dmg: f32 = 20,

pub fn init(player_center: rl.Vector2) Self {
    return Self{
        .center = player_center,
    };
}

pub fn deinit(_: *Self) void {}

pub fn update(self: *Self, player_center: rl.Vector2) void {
    self.center = player_center;
}

pub fn draw(self: *const Self) void {
    rl.DrawCircleV(self.center, self.radius, rl.ColorAlpha(rl.GRAY, 0.3));
}

pub inline fn is_collides(self: *const Self, enemy_collider: rl.Rectangle) bool {
    return rl.CheckCollisionCircleRec(self.center, self.radius, enemy_collider);
}
