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
const Background = @import("background.zig");

const Self = @This();

transform: rl.Rectangle,
// TODO: remove it after  coords system ?
position_center: rl.Vector2,
collider: rl.Rectangle,
health: i32,
is_dead: bool,
// was hit, and now invurnable
is_invurnable: bool,

hit_color: rl.Color,
hit_time_passed: f32,
hit_pos: rl.Vector2,
hit_text: [4]u8,
hit_text_slice: [:0]u8,

const HIT_TIMEOUT: f32 = 0.4;

// hit with timeout
pub fn try_hit(self: *Self, dmg: i32) void {
    if (self.health <= 0) {
        return;
    }
    if (self.is_invurnable) {
        return;
    }

    self.hit(dmg);
}

fn hit(self: *Self, dmg: i32) void {
    self.health -= dmg;
    self.is_invurnable = true;
    self.hit_time_passed = 0;
    self.hit_pos = rutils.new_vector2(self.transform.x + self.transform.width + 10, self.transform.y - 15);
    self.hit_text_slice = std.fmt.bufPrintZ(&self.hit_text, "{d}", .{dmg}) catch unreachable;

    if (self.health <= 0) {
        self.is_dead = true;
    }
}

pub fn init(pos: rl.Vector2, size: f32, start_health: i32, hit_color: rl.Color) Self {
    const transform = rutils.new_rect(pos.x, pos.y, size, size);
    const position_center = rutils.calc_rect_center(transform);
    return Self{
        .transform = transform,
        .position_center = position_center,
        .collider = transform,
        .health = start_health,
        .is_dead = false,
        .is_invurnable = false,
        .hit_time_passed = 0,
        .hit_color = hit_color,
        .hit_pos = undefined,
        .hit_text = undefined,
        .hit_text_slice = undefined,
    };
}

pub fn deinit(_: *Self) void {}

pub fn update(self: *Self, move_offset: rl.Vector2) void {
    if (self.is_dead) {
        return;
    }
    var new_move_offset = move_offset;
    if ((new_move_offset.x != 0) and (new_move_offset.y != 0)) {
        new_move_offset.x *= 0.7;
        new_move_offset.y *= 0.7;
    }

    const new_transform = rutils.move_rect(self.transform, move_offset);
    if (!rutils.is_rect_out_of_rect(new_transform, Background.transform)) {
        self.transform = new_transform;
        self.collider = self.transform;
        self.position_center = rutils.calc_rect_center(self.transform);
    } else {}

    if (self.is_invurnable) {
        self.hit_time_passed += rl.GetFrameTime();
        if (self.hit_time_passed < HIT_TIMEOUT) {
            self.hit_pos.y -= 1;
            self.hit_pos.x += 0.2;
        } else {
            self.is_invurnable = false;
            self.hit_time_passed = 0;
        }
    }
}

pub fn draw(self: *const Self, base_color: rl.Color) void {
    var color = base_color;
    if (self.is_dead) {
        color = rl.BLACK;
    } else if (self.is_invurnable) {
        color = rl.Fade(color, 0.7);
    }
    rl.DrawRectangleRec(self.transform, color);

    // TODO: text still can be under entity
    if (self.is_invurnable) {
        fonts.draw_text(self.hit_text_slice, self.hit_pos, fonts.FontSize.Bigger, self.hit_color);
    }
}
