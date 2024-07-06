const std = @import("std");
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");

// ---+---+--- helpers imports ---+---+---
const helpers = @import("helpers.zig");
const rutils = @import("rutils.zig");
// ---+---+---+---+---+---

const Enemy = @import("enemy.zig");
const Entity = @import("entity.zig");
const Player = @import("player.zig");

const Enemies = @This();

list: std.ArrayList(Enemy),

const ENEMIES_COUNT: f32 = 100;
const RECT_SIDE_SIZE: f32 = 200;

// spawn in rectange from player pos
pub fn spawn(allocator: std.mem.Allocator, player_pos: rl.Vector2) Enemies {
    var enemies = std.ArrayList(Enemy).initCapacity(allocator, ENEMIES_COUNT) catch helpers.oom();

    const enemies_on_side = ENEMIES_COUNT / 4;
    const step = RECT_SIDE_SIZE / enemies_on_side;

    {
        // top side
        const start_pos = rutils.new_vector2(player_pos.x - RECT_SIDE_SIZE / 2, player_pos.y - RECT_SIDE_SIZE / 2);
        var delta: f32 = 0;
        while (delta <= RECT_SIDE_SIZE) {
            var enemy = Enemy.init(rutils.new_vector2(start_pos.x + delta, start_pos.y));
            enemies.append(enemy) catch helpers.oom();
            delta += step;
        }
    }
    {
        // left side
        const start_pos = rutils.new_vector2(player_pos.x - RECT_SIDE_SIZE / 2, player_pos.y - RECT_SIDE_SIZE / 2);
        var delta: f32 = 0;
        while (delta <= RECT_SIDE_SIZE) {
            var enemy = Enemy.init(rutils.new_vector2(start_pos.x, start_pos.y + delta));
            enemies.append(enemy) catch helpers.oom();
            delta += step;
        }
    }
    {
        // right side
        const start_pos = rutils.new_vector2(player_pos.x + RECT_SIDE_SIZE / 2, player_pos.y - RECT_SIDE_SIZE / 2);
        var delta: f32 = 0;
        while (delta <= RECT_SIDE_SIZE) {
            var enemy = Enemy.init(rutils.new_vector2(start_pos.x, start_pos.y + delta));
            enemies.append(enemy) catch helpers.oom();
            delta += step;
        }
    }
    {
        // bottom side
        const start_pos = rutils.new_vector2(player_pos.x - RECT_SIDE_SIZE / 2, player_pos.y + RECT_SIDE_SIZE / 2);
        var delta: f32 = 0;
        while (delta <= RECT_SIDE_SIZE) {
            var enemy = Enemy.init(rutils.new_vector2(start_pos.x + delta, start_pos.y));
            enemies.append(enemy) catch helpers.oom();
            delta += step;
        }
    }

    return Enemies{
        .list = enemies,
    };
}

pub fn deinit(self: *Enemies) void {
    self.list.deinit();
}

pub fn update(self: *Enemies, player: *Player) void {
    for (self.list.items) |*enemy| {
        if (rl.CheckCollisionRecs(enemy.entity.collider, player.player_projectile.collider)) {
            enemy.entity.try_hit(10);
        }

        enemy.update(&player.entity);
    }
}

pub fn draw(self: *const Enemies) void {
    for (self.list.items) |enemy| {
        enemy.draw();
    }
}
