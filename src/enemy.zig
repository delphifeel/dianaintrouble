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

const DMG = 2;
const HEALTH = 40;
const MOVE_SPEED = 50;
// const HEALTH = 5;

pub fn init(pos: rl.Vector2) Self {
    var entity = Entity.init(pos, HEALTH, rl.GREEN);
    return Self{
        .entity = entity,
    };
}

pub fn deinit(self: *Self) void {
    self.entity.deinit();
}

pub fn update(self: *Self, player_entity: *Entity) void {
    const delta = rl.GetFrameTime();
    const step = rutils.px_per_sec(MOVE_SPEED, delta);
    const self_center = self.entity.position_center;
    const diff = rm.Vector2Subtract(player_entity.position_center, self_center);
    const step_vec = rm.Vector2Normalize(diff);
    const move_offset = rutils.new_vector2(step_vec.x * step, step_vec.y * step);

    if (!self.entity.is_dead) {
        if (rl.CheckCollisionRecs(self.entity.collider, player_entity.collider)) {
            player_entity.try_hit(DMG);
        }
    }

    self.entity.update(move_offset);
}

pub fn draw(self: *const Self) void {
    self.entity.draw();
}
