const std = @import("std");
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");

// ---+---+--- helpers imports ---+---+---
const h = @import("helpers.zig");
const rutils = @import("rutils.zig");
// ---+---+---+---+---+---
const Meteor = @import("player_meteor.zig");

const Self = @This();

time_passed: f32,
list: std.ArrayList(Meteor),

const MAX_METEORS = 100;
const SPAWN_EVERY: f32 = 3;

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
    return Self{
        .time_passed = 0,
        .list = std.ArrayList(Meteor).initCapacity(allocator, MAX_METEORS) catch h.oom(),
    };
}

pub fn start_spawning(self: *Self) void {
    var i: i32 = 0;
    while (i < MAX_METEORS) {
        var meteor: Meteor = undefined;
        meteor.reset();
        self.list.append(meteor) catch h.oom();
        i += 1;
    }
}

pub fn deinit(self: *Self) void {
    self.list.deinit();
}
