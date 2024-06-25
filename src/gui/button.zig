const std = @import("std");
const debug = std.debug;
const rl = @import("../raylib.zig");
const screen = @import("../screen.zig");
const fonts = @import("fonts.zig");
const Text = @import("text.zig");

// ---+---+--- helpers imports ---+---+---
const helpers = @import("../helpers.zig");
const string = helpers.string;
const string_view = helpers.string_view;
const oom = helpers.oom;
// ---+---+---+---+---+---

const Button = @This();

const OnClick = *const fn () void;

transform: rl.Rectangle,
label: Text,
on_click: OnClick,

fn init(transform: rl.Rectangle, text: string, fontSize: fonts.FontSize, on_click: OnClick) Button {
    return Button{
        .transform = transform,
        .label = Text.init_aligned(text, fontSize, transform, Text.TextAlignment.AllCenter),
        .on_click = on_click,
    };
}

fn input(self: *const Button) void {
    if (!rl.IsMouseButtonPressed(rl.MouseButtonLeft)) {
        return;
    }

    if (rl.CheckCollisionPointRec(rl.GetMousePosition(), self.transform)) {
        self.on_click();
    }
}

fn draw(self: *const Button) void {
    rl.DrawRectangleRec(self.transform, rl.Blue);
    self.label.draw();
}
