const std = @import("std");
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");

// ---+---+--- helpers imports ---+---+---
const helpers = @import("helpers.zig");
const rutils = @import("rutils.zig");
// ---+---+---+---+---+---

const Player = @This();

const STEP: f32 = 1;

transform: rl.Rectangle,

pub fn init(pos: rl.Vector2) Player {
    return Player{
        .transform = rutils.new_rect(pos.x, pos.y, 50, 50),
    };
}

pub fn deinit(_: *Player) void {}

pub fn update(self: *Player) void {
    var pos_delta = rm.Vector2Zero();
    if (rl.IsKeyDown(rl.KEY_A)) {
        pos_delta.x -= STEP;
    }
    if (rl.IsKeyDown(rl.KEY_D)) {
        pos_delta.x += STEP;
    }
    if (rl.IsKeyDown(rl.KEY_W)) {
        pos_delta.y -= STEP;
    }
    if (rl.IsKeyDown(rl.KEY_S)) {
        pos_delta.y += STEP;
    }

    if ((pos_delta.x != 0) and (pos_delta.y != 0)) {
        pos_delta.x *= 0.7;
        pos_delta.y *= 0.7;
    }

    self.transform.x += pos_delta.x;
    self.transform.y += pos_delta.y;
}

pub fn draw(self: *const Player) void {
    rl.DrawRectangleRec(self.transform, rl.BLUE);
}
