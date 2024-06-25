const std = @import("std");
const debug = std.debug;

pub const string = []u8;
pub const string_view = []const u8;

pub inline fn oom() noreturn {
    debug.panic("OOM\n", .{});
}
