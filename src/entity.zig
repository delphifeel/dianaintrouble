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
const SelfProjectile = @import("player_projectile.zig");

const Self = @This();

transform: rl.Rectangle,
// TODO: remove it after  coords system ?
position_center: rl.Vector2,
collider: rl.Rectangle,
health: i32,
is_invurnable: bool,
hit_time_passed: f32,

// TODO: should be private
pub fn is_dead(self: *const Self) bool {
    return self.health <= 0;
}

const HIT_TIMEOUT: f32 = 0.4;

// hit with timeout
pub fn try_hit(self: *Self, dmg: i32) void {
    if (self.health <= 0) {
        return;
    }
    if (self.is_invurnable) {
        return;
    }

    self.health -= dmg;
    self.is_invurnable = true;
    self.hit_time_passed = 0;
}

pub fn init(pos: rl.Vector2, size: f32, start_health: i32) Self {
    const transform = rutils.new_rect(pos.x, pos.y, size, size);
    const position_center = rutils.calc_rect_center(transform);
    return Self{
        .transform = transform,
        .position_center = position_center,
        .collider = transform,
        .health = start_health,
        .is_invurnable = false,
        .hit_time_passed = 0,
    };
}

pub fn deinit(_: *Self) void {}

pub fn update(self: *Self, move_offset: rl.Vector2) void {
    if (self.is_dead()) {
        return;
    }

    self.transform.x += move_offset.x;
    self.transform.y += move_offset.y;
    self.collider = self.transform;
    self.position_center = rutils.calc_rect_center(self.transform);

    if (self.is_invurnable) {
        self.hit_time_passed += rl.GetFrameTime();
        if (self.hit_time_passed >= HIT_TIMEOUT) {
            self.is_invurnable = false;
            self.hit_time_passed = 0;
        }
    }
}

pub fn draw(self: *const Self, base_color: rl.Color) void {
    var color = base_color;
    if (self.is_dead()) {
        color = rl.BLACK;
    } else if (self.is_invurnable) {
        color = rl.GRAY;
    }
    rl.DrawRectangleRec(self.transform, color);
}
