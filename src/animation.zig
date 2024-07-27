const std = @import("std");
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");
const h = @import("helpers.zig");
const rutils = @import("rutils.zig");

const Self = @This();

texture: rl.Texture2D,
speed: f32,
sprites_count: u32,

sprite_src_rect: rl.Rectangle = undefined,
sprite_dest_rect: rl.Rectangle = undefined,
sprite_flip: bool = false,
sprite_index: u32 = 0,
time_passed: f32 = 0,

pub fn reset(self: *Self) void {
    self.time_passed = 0;
    self.sprite_index = 0;
    // self.sprite_flip = false;
}

pub fn update(self: *Self, dest_transform: rl.Rectangle) void {
    const frame_time = rl.GetFrameTime();
    self.time_passed += frame_time;
    if (self.time_passed >= self.speed) {
        self.time_passed = 0;
        self.sprite_index += 1;
        if (self.sprite_index == self.sprites_count) {
            self.sprite_index = 0;
        }
    }

    const sprite_height: f32 = @floatFromInt(self.texture.height);
    const texture_width_f: f32 = @floatFromInt(self.texture.width);
    const sprites_count_f: f32 = @floatFromInt(self.sprites_count);
    var sprite_width: f32 = texture_width_f / sprites_count_f;
    if (self.sprite_flip) {
        sprite_width *= -1;
    }

    const index_f: f32 = @floatFromInt(self.sprite_index);
    self.sprite_src_rect = rutils.new_rect(index_f * sprite_width, 0, sprite_width, sprite_height);
    self.sprite_dest_rect = dest_transform;
}

pub fn draw(self: *const Self, tint_color: rl.Color) void {
    rl.DrawTexturePro(self.texture, self.sprite_src_rect, self.sprite_dest_rect, rm.Vector2Zero(), 0, tint_color);
}

pub fn set_flip(self: *Self, v: bool) void {
    self.sprite_flip = v;
}
