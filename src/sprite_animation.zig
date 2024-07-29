const std = @import("std");
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");
const h = @import("helpers.zig");
const rutils = @import("rutils.zig");

const Self = @This();

texture: rl.Texture2D,
speed: f32,
sprite_width: f32,

is_flip: bool = false,
sprite_src_rect: rl.Rectangle = undefined,
sprite_index: u32 = 0,
time_passed: f32 = 0,

pub fn reset(self: *Self) void {
    self.time_passed = 0;
    self.sprite_index = 0;
}

pub fn update(self: *Self) void {
    // TODO: put in init ?
    const texture_width_f: f32 = @floatFromInt(self.texture.width);
    const sprite_height: f32 = @floatFromInt(self.texture.height);
    const sprites_count: f32 = texture_width_f / self.sprite_width;

    const frame_time = rl.GetFrameTime();
    self.time_passed += frame_time;
    if (self.time_passed >= self.speed) {
        self.time_passed = 0;
        self.sprite_index += 1;
        const sprites_count_i: u32 = @intFromFloat(sprites_count);
        if (self.sprite_index == sprites_count_i) {
            self.sprite_index = 0;
        }
    }

    const sprite_index_f: f32 = @floatFromInt(self.sprite_index);
    self.sprite_src_rect = rutils.new_rect(
        sprite_index_f * self.sprite_width,
        0,
        if (self.is_flip) -self.sprite_width else self.sprite_width,
        sprite_height,
    );
}

pub fn draw(self: *const Self, dest_transform: rl.Rectangle, tint_color: rl.Color) void {
    rl.DrawTexturePro(self.texture, self.sprite_src_rect, dest_transform, rm.Vector2Zero(), 0, tint_color);
}
