const std = @import("std");
const rl = @import("../raylib.zig");
const rutils = @import("../rutils.zig");

const Self = @This();

transform: rl.Rectangle,
background_color: rl.Color,
fill_color: rl.Color,

pub fn draw(self: *const Self, value: f32, max_value: f32) void {
    rl.DrawRectangleRec(self.transform, self.background_color);

    var filled_rect = self.transform;
    if (value <= max_value) {
        filled_rect.width = value * self.transform.width / max_value;
    }
    rl.DrawRectangleRec(filled_rect, self.fill_color);
}
