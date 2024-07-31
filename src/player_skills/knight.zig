const std = @import("std");
const rl = @import("../raylib.zig");
const rm = @import("../raymath.zig");
const rutils = @import("../rutils.zig");

const Player = @import("../player.zig");
const SpriteAnimation = @import("../sprite_animation.zig");

const Self = @This();

animation: SpriteAnimation,
collider: rl.Rectangle,

// TODO: enum
direction: i32 = 0,
transform: rl.Rectangle = undefined,
time_passed: f32 = 0,
dmg: f32 = 10,
rotation_timeout: f32 = 10,
size: f32 = DEFAULT_SIZE,

const DEFAULT_SIZE = 96;
const COLLIDER_WIDTH = 64;
const OFFSET_VERTICAL = 150;
const OFFSET_HORIZONTAL = 100;

fn calc_transform(player_center: rl.Vector2, direction: i32, size: f32) rl.Rectangle {
    var pos = player_center;
    var width: f32 = size;
    var height: f32 = size;
    switch (direction) {
        // left
        0 => pos.x -= OFFSET_HORIZONTAL,
        // top
        1 => {
            pos.y -= OFFSET_VERTICAL;
        },
        // right
        2 => pos.x += OFFSET_HORIZONTAL,
        // bottom
        3 => {
            pos.y += OFFSET_VERTICAL;
        },
        else => unreachable,
    }
    return rutils.new_rect_with_center_pos(pos, width, height);
}

inline fn calc_collider(transform: rl.Rectangle) rl.Rectangle {
    const center_pos = rutils.calc_rect_center(transform);
    return rutils.new_rect_with_center_pos(center_pos, COLLIDER_WIDTH, DEFAULT_SIZE);
}

pub fn init(player_center: rl.Vector2) Self {
    const transform = calc_transform(player_center, 0, DEFAULT_SIZE);
    return Self{
        .animation = .{
            .texture = rl.LoadTexture("assets/knight.png"),
            .speed = 0.1,
            .sprite_width = 32,
        },
        .transform = transform,
        .collider = calc_collider(transform),
    };
}

pub fn deinit(self: *Self) void {
    rl.UnloadTexture(self.animation.texture);
}

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
    self.collider = calc_collider(self.transform);
    self.animation.update();
}

pub fn draw(self: *const Self) void {
    self.animation.draw(self.transform, rl.WHITE);
    // rutils.draw_collider(self.collider);
}
