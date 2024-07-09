const std = @import("std");
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");

// ---+---+--- helpers imports ---+---+---
const h = @import("helpers.zig");
const rutils = @import("rutils.zig");
// ---+---+---+---+---+---
const debug_info = @import("debug_info.zig");
const Text = @import("gui/text.zig");
const Progressbar = @import("gui/progressbar.zig");
const fonts = @import("gui/fonts.zig");
const PlayerProjectile = @import("player_projectile.zig");
const PlayerMeteors = @import("player_meteors.zig");
const Entity = @import("entity.zig");
const Background = @import("background.zig");
const screen = @import("screen.zig");

const Self = @This();

entity: Entity,
player_projectile: PlayerProjectile,
player_meteors: PlayerMeteors,
exp: f32,
lvl: u32,
exp_progressbar: Progressbar,

const MAX_EXP: f32 = 100;

pub fn up_exp(self: *Self) void {
    self.exp += 11;
    if (self.exp > MAX_EXP) {
        self.exp = 0;
        self.lvl += 1;
    }
}

fn init_progress_bar() Progressbar {
    var transform = rutils.new_rect_at_top(screen.remx(60), screen.remy(4));
    transform.y += screen.remy(2);

    return Progressbar{
        .transform = transform,
        .background_color = rl.GRAY,
        .fill_color = rl.BLUE,
    };
}

pub fn init(allocator: std.mem.Allocator, pos: rl.Vector2) Self {
    const entity = Entity.init(pos, 60, 100, rl.RED);
    var player_meteors = PlayerMeteors.init(allocator);
    player_meteors.start_spawning();
    return Self{
        .entity = entity,
        .player_projectile = PlayerProjectile.init(entity.position_center),
        .player_meteors = player_meteors,
        .exp = 0,
        .lvl = 1,
        .exp_progressbar = init_progress_bar(),
    };
}

pub fn deinit(self: *Self) void {
    self.entity.deinit();
    self.player_meteors.deinit();
}

pub fn update(self: *Self) void {
    const delta = rl.GetFrameTime();
    const step = rutils.distance_by_speed(80, delta);
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

    self.entity.update(pos_delta);
    self.player_projectile.update(self.entity.position_center);
    self.player_meteors.update(self.entity.position_center);
}

pub fn draw(self: *const Self) void {
    self.entity.draw(rl.BLUE);
}

pub fn draw_exp_progress(self: *const Self) void {
    self.exp_progressbar.draw(self.exp, MAX_EXP);
}
