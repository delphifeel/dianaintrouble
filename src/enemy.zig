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

const DMG = 20;
pub const DEFAULT_HEALTH = 200;
const MOVE_SPEED = 50;

const ANIMATION_SPEED = 0.1;
const SPRITE_DEST_SIZE = 200.0;

pub fn init(pos: rl.Vector2, start_health: i32) Self {
    const entity = Entity.init(pos, start_health, rl.GREEN);
    const texture = rl.LoadTexture("assets/enemy_walk.png");
    return Self{
        .entity = entity,
        .walk_animation = .{
            .texture = texture,
            .speed = ANIMATION_SPEED,
            .sprite_width = 64,
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

inline fn divInts(a: i32, b: i32) f32 {
    const a_f: f32 = @floatFromInt(a);
    const b_f: f32 = @floatFromInt(b);
    return a_f / b_f;
}

inline fn lerp_color(start: rl.Color, end: rl.Color, percent: f32) rl.Color {
    var new_color = rl.Color{};
    new_color.r = @intFromFloat(rm.Lerp(
        rutils.f32_from_int(start.r),
        rutils.f32_from_int(end.r),
        percent,
    ));
    new_color.g = @intFromFloat(rm.Lerp(
        rutils.f32_from_int(start.g),
        rutils.f32_from_int(end.g),
        percent,
    ));
    new_color.b = @intFromFloat(rm.Lerp(
        rutils.f32_from_int(start.b),
        rutils.f32_from_int(end.b),
        percent,
    ));
    new_color.a = @intFromFloat(rm.Lerp(
        rutils.f32_from_int(start.a),
        rutils.f32_from_int(end.a),
        percent,
    ));
    return new_color;
}

pub fn draw(self: *const Self) void {
    var tint_color = self.entity.sprite_tint_color orelse rl.WHITE;
    if (self.entity.sprite_tint_color == null and self.entity.health != self.entity.max_health) {
        const hp_percent: f32 = divInts(self.entity.health, self.entity.max_health);
        tint_color = lerp_color(rl.WHITE, rl.RED, 1 - hp_percent);
    }

    self.walk_animation.draw(self.transform, tint_color);
    // rutils.draw_collider(self.entity.collider);
}
