const std = @import("std");
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");

// ---+---+--- helpers imports ---+---+---
const helpers = @import("helpers.zig");
const rutils = @import("rutils.zig");
// ---+---+---+---+---+---

const Player = @import("player.zig");

const Self = @This();

transform: rl.Rectangle,
collider: rl.Rectangle,
time_passed: f32,

const SIZE: f32 = 30;
const OFFSET_FROM_CENTER: f32 = 150;
const SWITCH_CORNER_TIMEOUT: f32 = 0.05;

fn set_new_pos(self: *Self, player_center: rl.Vector2, frame_time: f32) void {
    self.time_passed += frame_time;
    if (self.time_passed >= SWITCH_CORNER_TIMEOUT * 4) {
        self.time_passed = 0;
    }

    const pos_i: i32 = @intFromFloat(self.time_passed / SWITCH_CORNER_TIMEOUT);

    // TODO: we really need coors system, also refactor this
    switch (pos_i) {
        0 => {
            self.transform.x = player_center.x + OFFSET_FROM_CENTER - SIZE / 2;
            self.transform.y = player_center.y - OFFSET_FROM_CENTER - SIZE / 2;
        },
        1 => {
            self.transform.x = player_center.x + OFFSET_FROM_CENTER - SIZE / 2;
            self.transform.y = player_center.y + OFFSET_FROM_CENTER - SIZE / 2;
        },
        2 => {
            self.transform.x = player_center.x - OFFSET_FROM_CENTER - SIZE / 2;
            self.transform.y = player_center.y + OFFSET_FROM_CENTER - SIZE / 2;
        },
        3 => {
            self.transform.x = player_center.x - OFFSET_FROM_CENTER - SIZE / 2;
            self.transform.y = player_center.y - OFFSET_FROM_CENTER - SIZE / 2;
        },
        else => unreachable,
    }

    self.collider = self.transform;
}

fn calc_start_pos(player_center: rl.Vector2) rl.Rectangle {
    return rutils.new_rect(player_center.x, player_center.y, SIZE, SIZE);
}

pub fn init(player_center: rl.Vector2) Self {
    const transform = calc_start_pos(player_center);
    return Self{
        .transform = transform,
        .collider = transform,
        .time_passed = 0,
    };
}

pub fn update(self: *Self, player_center: rl.Vector2) void {
    // appear in one of 4 corners once of time
    self.set_new_pos(player_center, rl.GetFrameTime());
}

pub fn draw(self: *const Self) void {
    rl.DrawRectangleRec(self.transform, rl.PURPLE);
}
