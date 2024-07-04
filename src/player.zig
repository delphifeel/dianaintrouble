const std = @import("std");
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");

// ---+---+--- helpers imports ---+---+---
const helpers = @import("helpers.zig");
const rutils = @import("rutils.zig");
// ---+---+---+---+---+---
const debug_info = @import("debug_info.zig");
const Text = @import("gui/text.zig");
const fonts = @import("gui/fonts.zig");
const PlayerProjectile = @import("player_projectile.zig");

const Player = @This();

transform: rl.Rectangle,
position_center: rl.Vector2,
collider: rl.Rectangle,
health: u32,
player_projectile: PlayerProjectile,
// TODO: all this staff should move to entity class
is_invurnable: bool,

fn is_dead(self: *const Player) bool {
    return self.health == 0;
}

const HIT_TIMEOUT: f32 = 0.4;
var hit_time_passed: f32 = 0;

// hit with timeout
pub fn try_hit(self: *Player) void {
    if (self.health == 0) {
        return;
    }
    if (self.is_invurnable) {
        return;
    }

    self.health -= 1;
    buf_ptr = std.fmt.bufPrint(&buf, "{d}", .{self.health}) catch unreachable;
    self.is_invurnable = true;
    hit_time_passed = 0;
}

pub fn init(pos: rl.Vector2) Player {
    const transform = rutils.new_rect(pos.x, pos.y, 50, 50);
    const position_center = rutils.calc_rect_center(transform);
    return Player{
        .transform = transform,
        .position_center = position_center,
        .collider = transform,
        .health = 100,
        .player_projectile = PlayerProjectile.init(position_center),
        .is_invurnable = false,
    };
}

pub fn deinit(_: *Player) void {}

pub fn update(self: *Player) void {
    if (self.is_dead()) {
        return;
    }

    const step = rutils.calc_fixed_speed(1);
    var pos_delta = rm.Vector2Zero();
    if (rl.IsKeyDown(rl.KEY_A)) {
        pos_delta.x -= step;
    }
    if (rl.IsKeyDown(rl.KEY_D)) {
        pos_delta.x += step;
    }
    if (rl.IsKeyDown(rl.KEY_W)) {
        pos_delta.y -= step;
    }
    if (rl.IsKeyDown(rl.KEY_S)) {
        pos_delta.y += step;
    }

    if ((pos_delta.x != 0) and (pos_delta.y != 0)) {
        pos_delta.x *= 0.7;
        pos_delta.y *= 0.7;
    }

    self.transform.x += pos_delta.x;
    self.transform.y += pos_delta.y;

    self.collider = self.transform;

    self.position_center = rutils.calc_rect_center(self.transform);

    self.player_projectile.update(self.position_center);

    if (self.is_invurnable) {
        hit_time_passed += rl.GetFrameTime();
        if (hit_time_passed >= HIT_TIMEOUT) {
            self.is_invurnable = false;
            hit_time_passed = 0;
        }
    }
}

var buf: [128]u8 = undefined;
var buf_ptr: []u8 = undefined;

pub fn draw(self: *Player) void {
    var color = if (self.is_dead()) rl.GRAY else rl.BLUE;
    if (self.is_invurnable) {
        color = rl.GRAY;
    }
    rl.DrawRectangleRec(self.transform, color);

    var text = Text.init(buf_ptr, fonts.FontSize.Medium, self.position_center);
    text.draw();

    if (!self.is_dead()) {
        self.player_projectile.draw();
    }
}
