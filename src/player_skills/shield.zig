const std = @import("std");
const rl = @import("../raylib.zig");
const rm = @import("../raymath.zig");
const rutils = @import("../rutils.zig");

const Player = @import("../player.zig");

const Self = @This();

transform: ?rl.Rectangle,

time_passed: f32 = 0,
restore_count: f32 = 5,
restore_timeout: f32 = 10,

const SIZE = 10;

fn calc_transform(player_center: rl.Vector2) rl.Rectangle {
    var pos = player_center;
    pos.x += 30;
    pos.y -= 60;
    return rutils.new_rect_with_center_pos(pos, SIZE, SIZE);
}

pub fn init(player_center: rl.Vector2) Self {
    return Self{
        .transform = calc_transform(player_center),
    };
}

pub fn update(self: *Self, player: *Player) void {
    self.time_passed += rl.GetFrameTime();
    if (self.time_passed >= self.restore_timeout) {
        self.time_passed = 0;
        player.entity.shield = @intFromFloat(self.restore_count);
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
