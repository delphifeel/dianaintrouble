const std = @import("std");
const rl = @import("../raylib.zig");
const rm = @import("../raymath.zig");
const h = @import("../helpers.zig");
const rutils = @import("../rutils.zig");

const Meteor = @import("meteors_internal.zig");

const Self = @This();

falling_texture: rl.Texture2D,
explosion_texture: rl.Texture2D,
time_passed: f32,
list: std.ArrayList(Meteor),

dmg: f32 = 400,
respawn_speed: f32 = 1,

const MAX_METEORS = 100;

pub fn init(allocator: std.mem.Allocator) Self {
    var list = std.ArrayList(Meteor).initCapacity(allocator, MAX_METEORS) catch h.oom();
    const falling_texture = rl.LoadTexture("assets/meteor.png");
    const explosion_texture = rl.LoadTexture("assets/meteor_explosion.png");

    for (0..MAX_METEORS) |_| {
        list.append(.{
            .falling_animation = .{
                .texture = falling_texture,
                .speed = 0.1,
                .sprite_width = 32,
            },
            .explosion_animation = .{
                .texture = explosion_texture,
                .speed = 0.1,
                .sprite_width = 32,
            },
        }) catch h.oom();
    }

    return Self{
        .time_passed = 0,
        .list = list,
        .falling_texture = falling_texture,
        .explosion_texture = explosion_texture,
    };
}

pub fn deinit(self: *Self) void {
    self.list.deinit();
    rl.UnloadTexture(self.falling_texture);
    rl.UnloadTexture(self.explosion_texture);
}

pub fn update(self: *Self, player_pos: rl.Vector2) void {
    const frame_time = rl.GetFrameTime();
    self.time_passed += frame_time;
    var need_to_spawn = false;
    const spawn_timeout = 3 / self.respawn_speed;
    if (self.time_passed >= spawn_timeout) {
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
