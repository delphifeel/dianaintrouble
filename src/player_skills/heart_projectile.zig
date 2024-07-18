const std = @import("std");
const rl = @import("../raylib.zig");
const rm = @import("../raymath.zig");
const rutils = @import("../rutils.zig");

const Player = @import("../player.zig");

const Self = @This();

transform: rl.Rectangle,
collider: rl.Rectangle,
angle: f32,
dmg: i32 = 10,

const SIZE: f32 = 40;
const OFFSET_FROM_CENTER: f32 = 150;
const INIT_ANGLE: comptime_float = 270;

pub fn init(player_center: rl.Vector2) Self {
    const pos = rutils.rotate_vector2(player_center, OFFSET_FROM_CENTER, INIT_ANGLE);
    const transform = rutils.new_rect_with_center_pos(pos, SIZE, SIZE);
    return Self{
        .transform = transform,
        .collider = transform,
        .angle = INIT_ANGLE,
    };
}

pub fn update(self: *Self, player_center: rl.Vector2) void {
    self.angle += rutils.distance_per_frame(300, rl.GetFrameTime());
    if (self.angle >= 360) {
        self.angle = 360 - self.angle;
    }
    const new_pos = rutils.rotate_vector2(player_center, OFFSET_FROM_CENTER, self.angle);
    self.transform = rutils.new_rect_with_center_pos(new_pos, SIZE, SIZE);
    self.collider = self.transform;
}

pub fn draw(self: *const Self) void {
    rl.DrawRectangleRec(self.transform, rl.PINK);
}
