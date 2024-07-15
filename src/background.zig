const std = @import("std");
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");

// ---+---+--- helpers imports ---+---+---
const helpers = @import("helpers.zig");
const rutils = @import("rutils.zig");
// ---+---+---+---+---+---

const Self = @This();

pub const transform = rutils.new_rect(0, 0, 4000, 4000);
// pub const transform = rutils.new_rect(0, 0, 2000, 2000);

pub fn init() Self {
    return Self{};
}

pub fn deinit(_: *Self) void {}

pub fn update(_: *Self) void {}

pub fn draw(_: *const Self) void {
    // var source = rutils.new_rect(0, 0, @floatFromInt(self.texture.width), @floatFromInt(self.texture.height));
    // rl.DrawTexturePro(self.texture, source, transform, rm.Vector2Zero(), 0, rl.WHITE);
    rl.DrawRectangleRec(transform, rl.DARKBROWN);
}
