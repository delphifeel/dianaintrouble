const std = @import("std");
const rl = @import("../raylib.zig");
const rm = @import("../raymath.zig");
const rutils = @import("../rutils.zig");

const Player = @import("../player.zig");
const SpriteAnimation = @import("../sprite_animation.zig");

const Self = @This();

idle_animation: SpriteAnimation,
attack_animation: SpriteAnimation,
collider: rl.Rectangle,

// TODO: enum
direction: i32 = 0,
is_attacking: bool = false,
stop_attacking_next_frame: bool = false,
transform: rl.Rectangle = undefined,
time_passed: f32 = 0,
dmg: f32 = 30,
rotation_speed: f32 = 1,
scale: f32 = DEFAULT_SCALE,

const DEFAULT_SCALE = 1.4;
const PUSH_FORCE = 10;
const WIDTH = 100;
const HEIGHT = 64;
const COLLIDER_WIDTH = 80;
const COLLIDER_HEIGHT = 64;
const OFFSET_VERTICAL = 150;
const OFFSET_HORIZONTAL = 100;

pub fn init(player_center: rl.Vector2) Self {
    const transform = calc_transform(player_center, 0, DEFAULT_SCALE);
    return Self{
        .idle_animation = .{
            .texture = rl.LoadTexture("assets/knight_idle.png"),
            .speed = 0.2,
            .sprite_width = 100,
            .is_flip = true,
        },
        .attack_animation = .{
            .texture = rl.LoadTexture("assets/knight_bash.png"),
            .speed = 0.2,
            .sprite_width = 100,
            .is_flip = true,
        },
        .transform = transform,
        .collider = calc_collider(transform, DEFAULT_SCALE),
    };
}

pub fn deinit(self: *Self) void {
    rl.UnloadTexture(self.idle_animation.texture);
}

pub fn update(self: *Self, player_center: rl.Vector2) void {
    self.time_passed += rl.GetFrameTime();
    const rotation_timeout = 10.0 / self.rotation_speed;
    if (self.time_passed >= rotation_timeout) {
        self.time_passed = 0;
        self.direction += 1;
        if (self.direction == 2) {
            self.direction = 0;
        }
    }

    self.transform = calc_transform(player_center, self.direction, self.scale);
    self.collider = calc_collider(self.transform, self.scale);

    var is_flip = false;
    switch (self.direction) {
        // left
        0 => is_flip = true,
        // right
        1 => is_flip = false,
        else => unreachable,
    }

    if (self.stop_attacking_next_frame) {
        self.stop_attacking_next_frame = false;
        self.is_attacking = false;
        self.idle_animation.reset();
    }

    if (self.is_attacking) {
        self.attack_animation.is_flip = is_flip;
        self.attack_animation.update();
        if (self.attack_animation.is_finished) {
            self.stop_attacking_next_frame = true;
        }
    } else {
        self.idle_animation.is_flip = is_flip;
        self.idle_animation.update();
    }
}

pub fn draw(self: *const Self) void {
    if (self.is_attacking) {
        self.attack_animation.draw(self.transform, rl.WHITE);
    } else {
        self.idle_animation.draw(self.transform, rl.WHITE);
    }
    // rutils.draw_collider(self.collider);
}

pub fn play_attack_animation(self: *Self) void {
    self.attack_animation.reset();
    self.is_attacking = true;
}

pub fn calc_push_vector(self: *const Self) rl.Vector2 {
    var vector = rm.Vector2Zero();
    switch (self.direction) {
        // left
        0 => vector.x -= PUSH_FORCE,
        // right
        1 => vector.x += PUSH_FORCE,
        else => unreachable,
    }
    return vector;
}

fn calc_transform(player_center: rl.Vector2, direction: i32, scale: f32) rl.Rectangle {
    var pos = player_center;
    var width: f32 = WIDTH * scale;
    var height: f32 = HEIGHT * scale;
    switch (direction) {
        // left
        0 => pos.x -= OFFSET_HORIZONTAL,
        // right
        1 => pos.x += OFFSET_HORIZONTAL,
        else => unreachable,
    }
    return rutils.new_rect_with_center_pos(pos, width, height);
}

inline fn calc_collider(transform: rl.Rectangle, scale: f32) rl.Rectangle {
    const center_pos = rutils.calc_rect_center(transform);
    return rutils.new_rect_with_center_pos(center_pos, COLLIDER_WIDTH * scale, COLLIDER_HEIGHT * scale);
}
