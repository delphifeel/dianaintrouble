const std = @import("std");
const rl = @import("../raylib.zig");
const rm = @import("../raymath.zig");
const rutils = @import("../rutils.zig");

const Player = @import("../player.zig");
const Background = @import("../background.zig");
const SpriteAnimation = @import("../sprite_animation.zig");

const Self = @This();

falling_animation: SpriteAnimation,
explosion_animation: SpriteAnimation,

is_falling: bool = false,
is_explosion: bool = false,
is_exploded: bool = false,
explosion_color_alpha: f32 = 1,
done: bool = true,
final_pos: rl.Vector2 = undefined,
transform: rl.Rectangle = undefined,
explosion_collider: ?rl.Rectangle = null,
time_passed: f32 = 0,
rotation: f32 = 0,

const SIZE: comptime_float = 120;
const MIN_OFFSET_FROM_CENTER: i32 = 50;
const MAX_OFFSET_FROM_CENTER: i32 = 150;
const EXPLOSION_TIME: f32 = 1;
const EXPLOSION_SIZE: comptime_float = 400;

pub fn respawn(self: *Self, player_center: rl.Vector2) void {
    var final_pos = rutils.rand_coord_in_range(player_center, MIN_OFFSET_FROM_CENTER, MAX_OFFSET_FROM_CENTER);
    var final_approx_transform = rutils.new_rect_with_pos(final_pos, SIZE, SIZE);
    if (rutils.is_rect_out_of_rect(final_approx_transform, Background.transform)) {
        final_approx_transform = rutils.find_nearest_rect_inside_world(final_approx_transform);
        final_pos = rutils.rect_pos(final_approx_transform);
    }
    const start_pos = rutils.new_vector2(final_pos.x + Background.transform.width / 4, final_pos.y - Background.transform.height / 4);
    const transform = rutils.new_rect_with_center_pos(start_pos, SIZE, SIZE);

    self.explosion_color_alpha = 1;
    self.explosion_animation.reset();
    self.falling_animation.reset();
    self.is_falling = true;
    self.done = false;
    self.transform = transform;
    self.final_pos = final_pos;
}

fn animate_falling(self: *Self, last_frame_time: f32) void {
    self.rotation += rutils.px_per_sec(300, last_frame_time);
    self.transform.y += rutils.px_per_sec(600, last_frame_time);
    self.transform.x -= rutils.px_per_sec(400, last_frame_time);
    self.falling_animation.update();
}

fn animate_explosion(self: *Self, last_frame_time: f32) void {
    if (self.is_exploded) {
        self.explosion_collider = null;
        self.explosion_color_alpha -= rutils.px_per_sec(1, last_frame_time);
        const delta = rutils.px_per_sec(100, last_frame_time);
        self.transform = rutils.grow_rect_from_center(self.transform, -delta, -delta);
        self.explosion_animation.update();
    } else {
        const transform_center = rutils.calc_rect_center(self.transform);
        self.transform = rutils.new_rect_with_center_pos(transform_center, EXPLOSION_SIZE, EXPLOSION_SIZE);
        self.explosion_collider = self.transform;
        self.is_exploded = true;
    }
}

pub fn update(self: *Self) void {
    const last_frame_time = rl.GetFrameTime();
    self.time_passed += last_frame_time;
    if (self.is_falling) {
        self.animate_falling(last_frame_time);
        if (self.transform.y >= self.final_pos.y) {
            self.time_passed = 0;
            self.rotation = 0;
            self.is_explosion = true;
            self.explosion_animation.reset();
            self.is_falling = false;
        }
        return;
    }
    if (self.is_explosion) {
        self.animate_explosion(last_frame_time);
        if (self.time_passed >= EXPLOSION_TIME) {
            self.time_passed = 0;
            self.is_explosion = false;
            self.is_exploded = false;
            self.done = true;
            self.explosion_collider = null;
        }
        return;
    }
}

pub fn draw(self: *const Self) void {
    if (self.is_explosion) {
        self.explosion_animation.draw(self.transform, rl.WHITE);
    } else if (self.is_falling) {
        self.falling_animation.draw_rotation(self.transform, rl.WHITE, self.rotation);
    }

    if (self.explosion_collider) |collider| {
        rutils.draw_collider(collider);
    }
}
