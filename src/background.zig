const std = @import("std");
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");

// ---+---+--- helpers imports ---+---+---
const helpers = @import("helpers.zig");
const rutils = @import("rutils.zig");
// ---+---+---+---+---+---

const Background = @This();

pub const transform = rutils.new_rect(0, 0, 2000, 2000);

texture: rl.Texture2D,

pub fn init() Background {
    var background = Background{
        .texture = rl.LoadTexture("assets/background.png"),
    };
    return background;
}

pub fn deinit(self: *Background) void {
    rl.UnloadTexture(self.texture);
}

pub fn update(_: *Background) void {}

pub fn draw(self: *const Background) void {
    var source = rutils.new_rect(0, 0, @floatFromInt(self.texture.width), @floatFromInt(self.texture.height));
    rl.DrawTexturePro(self.texture, source, transform, rm.Vector2Zero(), 0, rl.WHITE);
}
