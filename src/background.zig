const std = @import("std");
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");

// ---+---+--- helpers imports ---+---+---
const helpers = @import("helpers.zig");
const rutils = @import("rutils.zig");
// ---+---+---+---+---+---

const Background = @This();

texture: rl.Texture2D,
transform: rl.Rectangle,

pub fn init() Background {
    var background = Background{
        .texture = rl.LoadTexture("assets/background.png"),
        .transform = rutils.new_rect(0, 0, 4000, 4000),
    };
    return background;
}

pub fn deinit(self: *Background) void {
    rl.UnloadTexture(self.texture);
}

pub fn update(_: *Background) void {}

pub fn draw(self: *const Background) void {
    var source = rutils.new_rect(0, 0, @floatFromInt(self.texture.width), @floatFromInt(self.texture.height));
    rl.DrawTexturePro(self.texture, source, self.transform, rm.Vector2Zero(), 0, rl.WHITE);
}
