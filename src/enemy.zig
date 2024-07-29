const std = @import("std");
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");

// ---+---+--- helpers imports ---+---+---
const helpers = @import("helpers.zig");
const rutils = @import("rutils.zig");
// ---+---+---+---+---+---
const Entity = @import("entity.zig");
const SpriteAnimation = @import("sprite_animation.zig");

const Self = @This();

entity: Entity,
walk_animation: SpriteAnimation,

transform: rl.Rectangle = undefined,

const DMG = 2;
const HEALTH = 20;
const MOVE_SPEED = 50;

const ANIMATION_SPEED: comptime_float = 0.1;
const SPRITE_DEST_SIZE: comptime_float = 200;

pub fn init(pos: rl.Vector2) Self {
    const entity = Entity.init(pos, HEALTH, rl.GREEN);
    const texture = rl.LoadTexture("assets/enemy_walk.png");
    return Self{
        .entity = entity,
        .walk_animation = .{
            .texture = texture,
            .speed = ANIMATION_SPEED,
            .sprites_count = 8,
        },
    };
}

pub fn deinit(self: *Self) void {
    self.entity.deinit();
    rl.UnloadTexture(self.walk_animation.texture);
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

    if (!self.entity.is_dead) {
        if (move_offset.x < 0) {
            self.walk_animation.is_flip = true;
        } else if (move_offset.x > 0) {
            self.walk_animation.is_flip = false;
        }
        self.transform = rutils.new_rect_with_center_pos(self.entity.position_center, SPRITE_DEST_SIZE, SPRITE_DEST_SIZE);
        self.walk_animation.update();
    }
}

pub fn draw(self: *const Self) void {
    self.entity.draw();
    self.walk_animation.draw(self.transform, self.entity.sprite_tint_color);
    // rutils.draw_collider(self.entity.collider);
}
