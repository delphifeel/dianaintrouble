const std = @import("std");
const fmt = std.fmt;
const rl = @import("raylib.zig");
const h = @import("helpers.zig");

var fmt_vec_buf: [128]u8 = undefined;

inline fn fmtVec(vec: rl.Vector2) h.string_view {
    return fmt.bufPrint(&fmt_vec_buf, "[{d}, {d}]", .{ vec.x, vec.y }) catch unreachable;
}

inline fn rlMousePosInWorld(camera: rl.Camera2D) rl.Vector2 {
    return rl.GetScreenToWorld2D(rl.GetMousePosition(), camera);
}

pub var extra_info_buf: [128]u8 = undefined;
var extra_info_c_buf: ?h.string_view = null;

pub fn draw_extra_info(buf_c: h.string_view) void {
    extra_info_c_buf = buf_c;
}

pub fn draw(camera: *const rl.Camera2D) void {
    var buf: [128]u8 = undefined;
    var pos_x: i32 = 10;
    var pos_y: i32 = 10;

    var str = fmt.bufPrintZ(&buf, "Zoom: {d}", .{camera.zoom}) catch unreachable;
    rl.DrawText(str.ptr, pos_x, pos_y, 20, rl.GREEN);
    pos_y += 30;

    str = fmt.bufPrintZ(&buf, "Mouse Pos: {s}", .{fmtVec(rl.GetMousePosition())}) catch unreachable;
    rl.DrawText(str, pos_x, pos_y, 20, rl.GREEN);
    pos_y += 30;

    str = fmt.bufPrintZ(&buf, "Mouse Pos World: {s}", .{fmtVec(rlMousePosInWorld(camera.*))}) catch unreachable;
    rl.DrawText(str, pos_x, pos_y, 20, rl.GREEN);
    pos_y += 30;

    if (extra_info_c_buf) |s| {
        rl.DrawText(s.ptr, pos_x, pos_y, 20, rl.RED);
        extra_info_c_buf = null;
        pos_y += 30;
    }
}
