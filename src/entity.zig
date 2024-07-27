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
const Background = @import("background.zig");

const Self = @This();

collider: rl.Rectangle,
// TODO: remove it after  coords system ?
position_center: rl.Vector2,
health: i32,
max_health: i32,

// TODO: move outside ?
sprite_tint_color: rl.Color = rl.WHITE,
is_flip: bool = false,
shield: i32 = 0,
is_dead: bool = false,
is_invurnable: bool = false,
hit_color: rl.Color,
hit_time_passed: f32 = 0,
hit_pos: rl.Vector2 = undefined,
hit_text: [16]u8 = undefined,
hit_text_x_offset: f32 = 0,

const HIT_TIMEOUT: comptime_float = 0.4;
const HIT_TEXT_SPEED: comptime_float = 200;

const COLLIDER_WIDTH: comptime_float = 40;
const COLLIDER_HEIGHT: comptime_float = 80;

pub fn init(center_pos: rl.Vector2, start_health: i32, hit_color: rl.Color) Self {
    var collider = rutils.new_rect_with_center_pos(center_pos, COLLIDER_WIDTH, COLLIDER_HEIGHT);
    collider = rutils.find_nearest_rect_inside_world(collider);
    const position_center = rutils.calc_rect_center(collider);
    return Self{
        .position_center = position_center,
        .collider = collider,
        .health = start_health,
        .max_health = start_health,
        .hit_color = hit_color,
    };
}

pub fn deinit(_: *Self) void {}

pub fn update(self: *Self, move_offset: rl.Vector2) void {
    const frame_time = rl.GetFrameTime();

    if (!self.is_dead) {
        var new_move_offset = move_offset;
        if ((new_move_offset.x != 0) and (new_move_offset.y != 0)) {
            new_move_offset.x *= 0.7;
            new_move_offset.y *= 0.7;
        }

        const new_collider = rutils.move_rect(self.collider, move_offset);
        if (!rutils.is_rect_out_of_rect(new_collider, Background.transform)) {
            self.collider = new_collider;
            self.position_center = rutils.calc_rect_center(self.collider);
        } else {}
    }

    if (self.is_invurnable) {
        self.hit_time_passed += frame_time;
        if (self.hit_time_passed < HIT_TIMEOUT) {
            self.hit_pos.y -= rutils.px_per_sec(HIT_TEXT_SPEED, frame_time);
            self.hit_pos.x += self.hit_text_x_offset;
        } else {
            self.is_invurnable = false;
            self.hit_time_passed = 0;
        }
    }

    self.sprite_tint_color = rl.WHITE;
    if (self.is_invurnable) {
        self.sprite_tint_color = rl.GRAY;
    } else if (self.is_dead) {
        self.sprite_tint_color = rl.BLACK;
    }
}

pub fn draw(_: *const Self) void {}

// hit with timeout
pub fn try_hit(self: *Self, dmg: f32) void {
    if (self.health <= 0) {
        return;
    }
    if (self.is_invurnable) {
        return;
    }

    self.hit(dmg);
}

fn hit(self: *Self, dmg: f32) void {
    const px_per_sec = rutils.px_per_sec(100, rl.GetFrameTime());
    self.hit_text_x_offset = rutils.rand_f(-px_per_sec, px_per_sec);

    const dmg_i: i32 = @intFromFloat(dmg);
    if (self.shield > 0) {
        self.shield = if (dmg_i > self.shield) 0 else (self.shield - dmg_i);
    } else {
        self.health -= dmg_i;
    }

    self.is_invurnable = true;
    self.hit_time_passed = 0;
    self.hit_pos = rutils.new_vector2(self.collider.x + self.collider.width + 10, self.collider.y - 15);
    _ = std.fmt.bufPrintZ(&self.hit_text, "{d}", .{dmg_i}) catch unreachable;

    if (self.health <= 0) {
        self.is_dead = true;
    }
}

// TODO: should move it to sep. module
pub fn draw_hit_text(self: *const Self) void {
    if (self.is_invurnable) {
        fonts.draw_text(&self.hit_text, self.hit_pos, .Bigger, self.hit_color);
    }
}
