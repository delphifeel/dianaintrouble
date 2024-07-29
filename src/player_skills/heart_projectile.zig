const std = @import("std");
const rl = @import("../raylib.zig");
const rm = @import("../raymath.zig");
const rutils = @import("../rutils.zig");

const Player = @import("../player.zig");
const SpriteAnimation = @import("../sprite_animation.zig");

const Self = @This();

animation: SpriteAnimation,
transform: rl.Rectangle,
collider: rl.Rectangle,
angle: f32,

dmg: f32 = 10,
speed: f32 = 250,
offset_from_center: f32 = DEFAULT_OFFSET_FROM_CENTER,

const DEFAULT_OFFSET_FROM_CENTER: comptime_float = 150;
const SIZE: f32 = 50;
const INIT_ANGLE: comptime_float = 270;

pub fn init(player_center: rl.Vector2) Self {
    const pos = rutils.rotate_vector2(player_center, DEFAULT_OFFSET_FROM_CENTER, INIT_ANGLE);
    const transform = rutils.new_rect_with_center_pos(pos, SIZE, SIZE);
    return Self{
        .transform = transform,
        .collider = transform,
        .angle = INIT_ANGLE,
        .animation = .{
            .texture = rl.LoadTexture("assets/heart.png"),
            .speed = 0.1,
            .sprite_width = 32,
        },
    };
}

pub fn deinit(self: *Self) void {
    rl.UnloadTexture(self.animation.texture);
}

pub fn update(self: *Self, player_center: rl.Vector2) void {
    self.angle += rutils.px_per_sec(self.speed, rl.GetFrameTime());
    if (self.angle >= 360) {
        self.angle = 360 - self.angle;
    }
    const new_pos = rutils.rotate_vector2(player_center, self.offset_from_center, self.angle);
    self.transform = rutils.new_rect_with_center_pos(new_pos, SIZE, SIZE);
    self.collider = self.transform;

    self.animation.update();
}

pub fn draw(self: *const Self) void {
    self.animation.draw(self.transform, rl.WHITE);
}
