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

texture: rl.Texture2D,
collider: rl.Rectangle,
// TODO: remove it after  coords system ?
position_center: rl.Vector2,
health: i32,
max_health: i32,

sprite_src_rect: rl.Rectangle = undefined,
sprite_dest_rect: rl.Rectangle = undefined,
sprite_flip: bool = false,
sprite_index: u32 = 0,
sprite_tint_color: rl.Color = rl.WHITE,
animation_time_passed: f32 = 0,

shield: i32 = 0,
is_dead: bool = false,
is_invurnable: bool = false,
hit_color: rl.Color,
hit_time_passed: f32 = 0,
hit_pos: rl.Vector2 = undefined,
hit_text: [8]u8 = undefined,
hit_text_x_offset: f32 = 0,

const HIT_TIMEOUT: comptime_float = 0.4;
const HIT_TEXT_SPEED: comptime_float = 200;

const ANIMATION_ROTATION_TIMEOUT: comptime_float = 0.1;

const SPRITE_SRC_SIZE: comptime_float = 64;
const SPRITE_DEST_SIZE: comptime_float = 200;
const SPRITES_COUNT: comptime_int = 8;

const COLLIDER_WIDTH: comptime_float = 40;
const COLLIDER_HEIGHT: comptime_float = 80;

pub fn init(center_pos: rl.Vector2, start_health: i32, hit_color: rl.Color) Self {
    const texture = rl.LoadTexture("assets/character_run.png");
    var collider = rutils.new_rect_with_center_pos(center_pos, COLLIDER_WIDTH, COLLIDER_HEIGHT);
    collider = rutils.find_nearest_rect_inside_world(collider);

    const position_center = rutils.calc_rect_center(collider);
    return Self{
        .texture = texture,
        .position_center = position_center,
        .collider = collider,
        .health = start_health,
        .max_health = start_health,
        .hit_color = hit_color,
    };
}

pub fn deinit(self: *Self) void {
    rl.UnloadTexture(self.texture);
}

fn update_animation(self: *Self, frame_time: f32) void {
    self.animation_time_passed += frame_time;
    if (self.animation_time_passed >= ANIMATION_ROTATION_TIMEOUT) {
        self.animation_time_passed = 0;
        self.sprite_index += 1;
        if (self.sprite_index == SPRITES_COUNT) {
            self.sprite_index = 0;
        }
    }

    const index_f: f32 = @floatFromInt(self.sprite_index);
    const sprite_width: f32 = if (self.sprite_flip) -SPRITE_SRC_SIZE else SPRITE_SRC_SIZE;
    self.sprite_src_rect = rutils.new_rect(index_f * SPRITE_SRC_SIZE, 0, sprite_width, SPRITE_SRC_SIZE);
    self.sprite_dest_rect = rutils.new_rect_with_center_pos(self.position_center, SPRITE_DEST_SIZE, SPRITE_DEST_SIZE);
}

pub fn update(self: *Self, move_offset: rl.Vector2) void {
    const frame_time = rl.GetFrameTime();

    if (!self.is_dead) {
        self.update_animation(frame_time);
        var new_move_offset = move_offset;
        if ((new_move_offset.x != 0) and (new_move_offset.y != 0)) {
            new_move_offset.x *= 0.7;
            new_move_offset.y *= 0.7;
        }
        if (new_move_offset.x < 0) {
            self.sprite_flip = true;
        } else if (new_move_offset.x > 0) {
            self.sprite_flip = false;
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

pub fn draw(self: *const Self, _: rl.Color) void {
    rl.DrawTexturePro(self.texture, self.sprite_src_rect, self.sprite_dest_rect, rm.Vector2Zero(), 0, self.sprite_tint_color);
    // rl.DrawRectangleLinesEx(self.collider, 2, rl.PURPLE);
}

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
    _ = std.fmt.bufPrintZ(&self.hit_text, "{d}", .{dmg_i}) catch {
        unreachable;
    };

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
