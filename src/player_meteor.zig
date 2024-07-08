const std = @import("std");
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");

// ---+---+--- helpers imports ---+---+---
const helpers = @import("helpers.zig");
const rutils = @import("rutils.zig");
// ---+---+---+---+---+---

const Player = @import("player.zig");
const Background = @import("background.zig");

const Self = @This();

is_falling: bool,
is_explosion: bool,
done: bool,
final_pos: rl.Vector2,
transform: rl.Rectangle,
collider: ?rl.Rectangle,
time_passed: f32,
rotation: f32,

const SIZE: f32 = 40;
const MIN_OFFSET_FROM_CENTER: i32 = 300;
const MAX_OFFSET_FROM_CENTER: i32 = 700;
const EXPLOSION_TIME: f32 = 1;

pub fn reset(self: *Self) void {
    self.is_explosion = false;
    self.is_falling = false;
    self.done = true;
    self.transform = undefined;
    self.collider = null;
    self.final_pos = undefined;
    self.time_passed = 0;
    self.rotation = 0;
}

pub fn respawn(self: *Self, player_center: rl.Vector2) void {
    const final_pos = rutils.rand_coord_in_range(player_center, MIN_OFFSET_FROM_CENTER, MAX_OFFSET_FROM_CENTER);
    const start_pos = rutils.new_vector2(final_pos.x, final_pos.y - Background.transform.height / 4);

    self.is_falling = true;
    self.done = false;
    self.transform = rutils.new_rect_with_pos(start_pos, SIZE, SIZE);
    self.final_pos = final_pos;
}

pub fn deinit(_: *Self) void {}

fn animate_falling(self: *Self, last_frame_time: f32) void {
    self.rotation += rutils.distance_by_speed(300, last_frame_time);
    self.transform.y += rutils.distance_by_speed(600, last_frame_time);
}

fn animate_explosion(self: *Self, last_frame_time: f32) void {
    const delta = rutils.distance_by_speed(100, last_frame_time);
    self.transform = rutils.grow_rect_from_center(self.transform, delta, delta);
    self.collider = self.transform;
}

pub fn update(self: *Self) void {
    const last_frame_time = rl.GetFrameTime();
    self.time_passed += last_frame_time;
    if (self.is_falling) {
        self.animate_falling(last_frame_time);
        if (self.transform.y >= self.final_pos.y) {
            self.time_passed = 0;
            self.rotation = 0;
            self.is_explosion = true;
            self.is_falling = false;
        }
        return;
    }
    if (self.is_explosion) {
        self.animate_explosion(last_frame_time);
        if (self.time_passed >= EXPLOSION_TIME) {
            self.time_passed = 0;
            self.is_explosion = false;
            self.done = true;
            self.collider = null;
        }
        return;
    }
}

pub fn draw(self: *const Self) void {
    rl.DrawRectanglePro(self.transform, rutils.new_vector2(SIZE / 2, SIZE / 2), self.rotation, rl.RED);
}
