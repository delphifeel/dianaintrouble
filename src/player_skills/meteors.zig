const std = @import("std");
const rl = @import("../raylib.zig");
const rm = @import("../raymath.zig");
const h = @import("../helpers.zig");
const rutils = @import("../rutils.zig");

const Meteor = @import("meteors_internal.zig");

const Self = @This();

time_passed: f32,
list: std.ArrayList(Meteor),
dmg: i32 = 20,

const MAX_METEORS = 100;
const SPAWN_EVERY: f32 = 1;

pub fn update(self: *Self, player_pos: rl.Vector2) void {
    const frame_time = rl.GetFrameTime();
    self.time_passed += frame_time;
    var need_to_spawn = false;
    if (self.time_passed >= SPAWN_EVERY) {
        need_to_spawn = true;
        self.time_passed = 0;
    }

    for (self.list.items) |*meteor| {
        if (meteor.done and need_to_spawn) {
            meteor.respawn(player_pos);
            need_to_spawn = false;
        } else if (!meteor.done) {
            meteor.update();
        }
    }
}
pub fn draw(self: *const Self) void {
    for (self.list.items) |*meteor| {
        if (!meteor.done) {
            meteor.draw();
        }
    }
}

pub fn init(allocator: std.mem.Allocator) Self {
    var list = std.ArrayList(Meteor).initCapacity(allocator, MAX_METEORS) catch h.oom();

    for (0..MAX_METEORS) |_| {
        list.append(Meteor{}) catch h.oom();
    }

    return Self{
        .time_passed = 0,
        .list = list,
    };
}

pub fn deinit(self: *Self) void {
    self.list.deinit();
}
