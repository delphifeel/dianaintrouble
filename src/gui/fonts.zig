const std = @import("std");
const debug = std.debug;
const rl = @import("../raylib.zig");
const screen = @import("../screen.zig");

// ---+---+--- helpers imports ---+---+---
const helpers = @import("../helpers.zig");
const string = helpers.string;
const string_view = helpers.string_view;
const oom = helpers.oom;
// ---+---+---+---+---+---

pub const FontSize = enum(i32) {
    VerySmall = @intFromFloat(screen.remy(1.33)),
    Small = @intFromFloat(screen.remy(2.7)),
    Medium = @intFromFloat(screen.remy(4)),
    Big = @intFromFloat(screen.remy(5.26)),
    Bigger = @intFromFloat(screen.remy(7)),
};

var fonts: std.AutoHashMap(FontSize, rl.Font) = undefined;

// TODO: is it text module ?
pub fn draw_text(text: [:0]const u8, pos: rl.Vector2, font_size: FontSize, color: rl.Color) void {
    const font = get_font(font_size);
    rl.DrawTextEx(font, text, pos, @floatFromInt(font.baseSize), 0, color);
}

pub fn get_font(font_size: FontSize) rl.Font {
    return fonts.get(font_size).?;
}

pub fn load_fonts(allocator: std.mem.Allocator) void {
    fonts = std.AutoHashMap(FontSize, rl.Font).init(allocator);

    load_font(FontSize.VerySmall);
    load_font(FontSize.Small);
    load_font(FontSize.Medium);
    load_font(FontSize.Big);
    load_font(FontSize.Bigger);
}

pub fn unload_fonts() void {
    var iter = fonts.iterator();
    while (iter.next()) |entry| {
        rl.UnloadFont(entry.value_ptr.*);
    }

    fonts.deinit();
}

fn load_font(size: FontSize) void {
    var font = rl.LoadFontEx("fonts/Rajdhani-SemiBold.ttf", @intFromEnum(size), null, 0);
    rl.SetTextureFilter(font.texture, rl.TEXTURE_FILTER_BILINEAR);
    fonts.put(size, font) catch oom();
}
