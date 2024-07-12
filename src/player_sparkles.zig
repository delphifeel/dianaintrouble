const std = @import("std");
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");

// ---+---+--- helpers imports ---+---+---
const helpers = @import("helpers.zig");
const rutils = @import("rutils.zig");
// ---+---+---+---+---+---

const Player = @import("player.zig");

const Self = @This();

transforms: [4]rl.Rectangle = undefined,
colliders: [4]rl.Rectangle = undefined,
time_passed: f32 = 0,
dmg: i32 = 5,

const FIRE_TIMEOUT: comptime_float = 2;
const SIZE: f32 = 50;
const OFFSET_FROM_CENTER: f32 = 50;

fn reset(self: *Self, player_center: rl.Vector2) void {
    self.transforms[0] = rutils.new_rect(player_center.x - OFFSET_FROM_CENTER, player_center.y - OFFSET_FROM_CENTER, SIZE, SIZE);
    self.transforms[1] = rutils.new_rect(player_center.x + OFFSET_FROM_CENTER, player_center.y - OFFSET_FROM_CENTER, SIZE, SIZE);
    self.transforms[2] = rutils.new_rect(player_center.x + OFFSET_FROM_CENTER, player_center.y + OFFSET_FROM_CENTER, SIZE, SIZE);
    self.transforms[3] = rutils.new_rect(player_center.x - OFFSET_FROM_CENTER, player_center.y + OFFSET_FROM_CENTER, SIZE, SIZE);

    self.colliders[0] = self.transforms[0];
    self.colliders[1] = self.transforms[1];
    self.colliders[2] = self.transforms[2];
    self.colliders[3] = self.transforms[3];
}

pub fn init(player_center: rl.Vector2) Self {
    var self: Self = .{};
    self.reset(player_center);

    return self;
}

pub fn deinit(_: *Self) void {}

pub fn is_collides(self: *const Self, target_rect: rl.Rectangle) bool {
    for (self.colliders) |collider| {
        if (rl.CheckCollisionRecs(collider, target_rect)) {
            return true;
        }
    }
    return false;
}

pub fn update(self: *Self, player_center: rl.Vector2) void {
    const frame_time = rl.GetFrameTime();
    self.time_passed += frame_time;
    if (self.time_passed >= FIRE_TIMEOUT) {
        self.time_passed = 0;
        self.reset(player_center);
    }

    const distance = rutils.distance_per_frame(400, frame_time);

    self.move_sparkle(0, rutils.new_vector2(-distance, -distance));
    self.move_sparkle(1, rutils.new_vector2(distance, -distance));
    self.move_sparkle(2, rutils.new_vector2(distance, distance));
    self.move_sparkle(3, rutils.new_vector2(-distance, distance));
}

pub fn draw(self: *const Self) void {
    for (self.transforms) |t| {
        rl.DrawRectangleRec(t, rl.YELLOW);
    }
}

fn move_sparkle(self: *Self, index: usize, offset: rl.Vector2) void {
    self.transforms[index] = rutils.move_rect(self.transforms[index], offset);
    self.colliders[index] = self.transforms[index];
}
