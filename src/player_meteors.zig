const std = @import("std");
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");

// ---+---+--- helpers imports ---+---+---
const helpers = @import("helpers.zig");
const rutils = @import("rutils.zig");
// ---+---+---+---+---+---

const Player = @import("player.zig");

const Self = @This();

is_alive: bool,
final_pos: rl.Vector2,
transform: rl.Rectangle,
collider: rl.Rectangle,
time_passed: f32,
rotation: f32,

const SIZE: f32 = 40;
const MIN_OFFSET_FROM_CENTER: i32 = 100;
const MAX_OFFSET_FROM_CENTER: i32 = 200;
const SPAWN_EVERY: f32 = 4;
const ALIVE_TIME: f32 = 1;

fn init_transform(player_center: rl.Vector2) rl.Rectangle {
    const new_pos = rutils.rand_coord_in_range(player_center, MIN_OFFSET_FROM_CENTER, MAX_OFFSET_FROM_CENTER);
    return rutils.new_rect(new_pos.x, new_pos.y, SIZE, SIZE);
}

pub fn init() Self {
    return Self{
        .is_alive = false,
        .transform = undefined,
        .collider = undefined,
        .final_pos = undefined,
        .time_passed = 0,
        .rotation = 0,
    };
}

pub fn update(self: *Self, player_center: rl.Vector2) void {
    self.time_passed += rl.GetFrameTime();
    if (self.is_alive) {
        self.rotation += 5;
        self.transform.y += rutils.distance_by_speed(300, rl.GetFrameTime());
        self.collider = self.transform;

        if (self.transform.y >= self.final_pos.y) {
            self.is_alive = false;
            self.rotation = 0;
        }
    } else if (self.time_passed >= SPAWN_EVERY) {
        self.is_alive = true;
        self.time_passed = 0;
        self.final_pos = rutils.rand_coord_in_range(player_center, MIN_OFFSET_FROM_CENTER, MAX_OFFSET_FROM_CENTER);

        const start_pos = rutils.new_vector2(self.final_pos.x, self.final_pos.y - 1000);
        self.transform = rutils.new_rect_with_pos(start_pos, SIZE, SIZE);
        self.collider = self.transform;
    }
}

pub fn draw(self: *const Self) void {
    if (self.is_alive) {
        rl.DrawRectanglePro(self.transform, rutils.new_vector2(SIZE / 2, SIZE / 2), self.rotation, rl.RED);
    }
}
