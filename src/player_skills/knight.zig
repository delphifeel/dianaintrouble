const std = @import("std");
const rl = @import("../raylib.zig");
const rm = @import("../raymath.zig");
const rutils = @import("../rutils.zig");

const Player = @import("../player.zig");

const Self = @This();

transform: rl.Rectangle,
collider: rl.Rectangle,

// TODO: enum
direction: i32 = 0,
time_passed: f32 = 0,
dmg: f32 = 10,
rotation_timeout: f32 = 10,
size: f32 = DEFAULT_SIZE,

const DEFAULT_SIZE = 70;
const OFFSET = 100;

fn calc_transform(player_center: rl.Vector2, direction: i32, size: f32) rl.Rectangle {
    var pos = player_center;
    var width: f32 = size;
    var height: f32 = size + 50;
    switch (direction) {
        // left
        0 => {
            pos.x -= OFFSET;
        },
        // top
        1 => {
            pos.y -= OFFSET;
            width = size + 50;
            height = size;
        },
        // right
        2 => pos.x += OFFSET,
        // bottom
        3 => {
            pos.y += OFFSET;
            width = size + 50;
            height = size;
        },
        else => unreachable,
    }
    return rutils.new_rect_with_center_pos(pos, width, height);
}

pub fn init(player_center: rl.Vector2) Self {
    const transform = calc_transform(player_center, 0, DEFAULT_SIZE);
    return Self{
        .transform = transform,
        .collider = transform,
    };
}

pub fn deinit(_: *Self) void {}

pub fn update(self: *Self, player_center: rl.Vector2) void {
    self.time_passed += rl.GetFrameTime();
    if (self.time_passed >= self.rotation_timeout) {
        self.time_passed = 0;
        self.direction += 1;
        if (self.direction == 4) {
            self.direction = 0;
        }
    }

    self.transform = calc_transform(player_center, self.direction, self.size);
    self.collider = self.transform;
}

pub fn draw(self: *const Self) void {
    rl.DrawRectangleRec(self.transform, rl.BLUE);
}
