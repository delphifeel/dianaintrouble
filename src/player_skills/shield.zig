const std = @import("std");
const rl = @import("../raylib.zig");
const rm = @import("../raymath.zig");
const rutils = @import("../rutils.zig");

const Player = @import("../player.zig");

const Self = @This();

transform: ?rl.Rectangle,

time_passed: f32 = 0,
restore_amount: f32 = 5,
restore_timeout: f32 = 10,

const SIZE = 20;

fn calc_transform(player_center: rl.Vector2) rl.Rectangle {
    var pos = player_center;
    pos.x += 40;
    pos.y -= 70;
    return rutils.new_rect_with_center_pos(pos, SIZE, SIZE);
}

pub fn init(player_center: rl.Vector2) Self {
    return Self{
        .transform = calc_transform(player_center),
    };
}

pub fn deinit(_: *Self) void {}

pub fn update(self: *Self, player: *Player) void {
    if (player.entity.shield == 0) {
        self.time_passed += rl.GetFrameTime();
    }
    if (self.time_passed >= self.restore_timeout) {
        self.time_passed = 0;
        player.entity.shield = @intFromFloat(self.restore_amount);
    }
    if (player.entity.shield > 0) {
        self.transform = calc_transform(player.entity.position_center);
    } else {
        self.transform = null;
    }
}

pub fn draw(self: *const Self) void {
    if (self.transform) |transform| {
        rl.DrawRectangleRec(transform, rl.BLUE);
    }
}
