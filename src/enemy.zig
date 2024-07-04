const std = @import("std");
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");

// ---+---+--- helpers imports ---+---+---
const helpers = @import("helpers.zig");
const rutils = @import("rutils.zig");
// ---+---+---+---+---+---
const Player = @import("player.zig");

const Enemy = @This();

transform: rl.Rectangle,
collider: rl.Rectangle,
// TODO: make entity class
health: u32,

pub fn init(pos: rl.Vector2) Enemy {
    const transform = rutils.new_rect(pos.x, pos.y, 50, 50);
    return Enemy{
        .transform = transform,
        .collider = transform,
        .health = 30,
    };
}

pub fn deinit(_: *Enemy) void {}

pub fn update(self: *Enemy, player: *Player) void {
    const step = rutils.calc_fixed_speed(0.5);
    const self_center = rutils.calc_rect_center(self.transform);
    const diff = rm.Vector2Subtract(player.position_center, self_center);
    const step_vec = rm.Vector2Normalize(diff);
    self.transform.x += step_vec.x * step;
    self.transform.y += step_vec.y * step;
    self.collider = self.transform;

    if (rl.CheckCollisionRecs(self.collider, player.collider)) {
        player.try_hit();
    }
}

pub fn draw(self: *const Enemy) void {
    rl.DrawRectangleRec(self.transform, rl.ORANGE);
    rl.DrawRectangleLinesEx(self.transform, 1, rl.BLACK);
}
