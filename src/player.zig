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
const Entity = @import("entity.zig");

const Self = @This();

entity: Entity,
player_projectile: SelfProjectile,

pub fn init(pos: rl.Vector2) Self {
    const entity = Entity.init(pos, 50, 100);
    return Self{
        .entity = entity,
        .player_projectile = SelfProjectile.init(entity.position_center),
    };
}

pub fn deinit(self: *Self) void {
    self.entity.deinit();
}

pub fn update(self: *Self) void {
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

    self.entity.update(pos_delta);
    self.player_projectile.update(self.entity.position_center);
}

pub fn draw(self: *const Self) void {
    self.entity.draw(rl.BLUE);

    if (!self.entity.is_dead()) {
        self.player_projectile.draw();
    }
}
