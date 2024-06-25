const std = @import("std");
const fmt = std.fmt;
const debug = std.debug;
const rl = @import("../raylib.zig");
const rutils = @import("../rutils.zig");

const fonts = @import("fonts.zig");
const FontSize = fonts.FontSize;

// ---+---+--- helpers imports ---+---+---
const helpers = @import("../helpers.zig");
const string = helpers.string;
const string_view = helpers.string_view;
const oom = helpers.oom;
// ---+---+---+---+---+---

const Text = @This();

text: string_view,
font: rl.Font,
pos: rl.Vector2,
color: rl.Color,

pub const TextAlignment = enum(u32) {
    AllCenter = 0,
    Right = 1,
    Left = 2,
    Top = 4,
    Bottom = 8,
};

const spacing: f32 = 0.0;

pub fn set_color(self: *Text, color: rl.Color) void {
    self.color = color;
}

pub fn draw(self: *const Text) void {
    rl.DrawTextEx(self.font, self.text.ptr, self.pos, @floatFromInt(self.font.baseSize), spacing, self.color);
}

pub fn drawEx(self: *const Text, color: rl.Color) void {
    rl.DrawTextEx(self.font, self.text.ptr, self.pos, @floatFromInt(self.font.baseSize), spacing, color);
}

pub fn init_aligned(text: string_view, font_size: FontSize, bounds: rl.Rectangle, alignment: TextAlignment) Text {
    var font = fonts.get_font(font_size);
    var text_size = rl.MeasureTextEx(font, text.ptr, @floatFromInt(@intFromEnum(font_size)), spacing);
    var text_pos = rutils.calc_rect_at_center(bounds);
    text_pos.x -= text_size.x / 2;
    text_pos.y -= text_size.y / 2;

    if (is_eq_aligment(alignment, TextAlignment.Right)) {
        text_pos.x = bounds.x + bounds.width - text_size.x;
    } else if (is_eq_aligment(alignment, TextAlignment.Left)) {
        text_pos.x = bounds.x;
    }

    if (is_eq_aligment(alignment, TextAlignment.Top)) {
        text_pos.y = bounds.y;
    } else if (is_eq_aligment(alignment, TextAlignment.Bottom)) {
        text_pos.y = bounds.y + bounds.height - text_size.y;
    }

    return Text{
        .text = text,
        .font = font,
        .pos = text_pos,
        .color = rl.WHITE,
    };
}

pub fn init(text: string, font_size: FontSize, pos: rl.Vector2) Text {
    var font = fonts.get_font(font_size);
    return Text{
        .text = text,
        .font = font,
        .pos = pos,
        .color = rl.WHITE,
    };
}

fn is_eq_aligment(alignment: TextAlignment, flag: TextAlignment) bool {
    var flag_int = @intFromEnum(flag);
    return @intFromEnum(alignment) & flag_int == flag_int;
}
