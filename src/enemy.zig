const std = @import("std");
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");

// ---+---+--- helpers imports ---+---+---
const helpers = @import("helpers.zig");
const rutils = @import("rutils.zig");
// ---+---+---+---+---+---
const Entity = @import("entity.zig");

const Self = @This();

entity: Entity,

pub fn init(pos: rl.Vector2) Self {
    return Self{
        .entity = Entity.init(pos, 50, 40),
    };
}

pub fn deinit(self: *Self) void {
    self.entity.deinit();
}

pub fn update(self: *Self, player_entity: *Entity) void {
    const delta = rl.GetFrameTime();
    const step = rutils.distance_by_speed(50, delta);
    const self_center = self.entity.position_center;
    const diff = rm.Vector2Subtract(player_entity.position_center, self_center);
    const step_vec = rm.Vector2Normalize(diff);
    const move_offset = rutils.new_vector2(step_vec.x * step, step_vec.y * step);

    if (!self.entity.is_dead) {
        if (rl.CheckCollisionRecs(self.entity.collider, player_entity.collider)) {
            player_entity.try_hit(1);
        }
    }

    self.entity.update(move_offset);
}

pub fn draw(self: *const Self) void {
    self.entity.draw(rl.ORANGE);
}
