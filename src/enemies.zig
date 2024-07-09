const std = @import("std");
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");

// ---+---+--- h imports ---+---+---
const h = @import("helpers.zig");
const rutils = @import("rutils.zig");
// ---+---+---+---+---+---

const Enemy = @import("enemy.zig");
const Entity = @import("entity.zig");
const Player = @import("player.zig");

const Enemies = @This();

list: std.ArrayList(Enemy),
time_passed: f32,

const ENEMIES_COUNT: f32 = 1000;
const MAX_RESPAWN_ENEMIES = 30;
const MIN_OFFSET: f32 = 700;
const MAX_OFFSET: f32 = 900;
const SPAWN_EVERY: f32 = 3;

pub fn spawn(allocator: std.mem.Allocator, player_center: rl.Vector2) Enemies {
    var enemies = std.ArrayList(Enemy).initCapacity(allocator, ENEMIES_COUNT) catch h.oom();
    var i: i32 = 0;
    while (i < ENEMIES_COUNT) {
        const rand_pos = rutils.rand_coord_in_range(player_center, MIN_OFFSET, MAX_OFFSET);
        var enemy = Enemy.init(rand_pos);
        enemies.append(enemy) catch h.oom();

        i += 1;
    }
    return Enemies{
        .list = enemies,
        .time_passed = 0,
    };
}

pub fn deinit(self: *Enemies) void {
    self.list.deinit();
}

pub fn update(self: *Enemies, player: *Player) void {
    self.time_passed += rl.GetFrameTime();
    var need_to_spawn = false;
    var raspawned: i32 = 0;
    if (self.time_passed >= SPAWN_EVERY) {
        self.time_passed = 0;
        need_to_spawn = true;
    }

    for (self.list.items, 0..) |*enemy, i| {
        if (enemy.entity.is_dead) {
            if (need_to_spawn and raspawned < MAX_RESPAWN_ENEMIES) {
                raspawned += 1;
                const rand_pos = rutils.rand_coord_in_range(player.entity.position_center, MIN_OFFSET, MAX_OFFSET);
                self.list.items[i] = Enemy.init(rand_pos);
            }
        } else {
            if (rl.CheckCollisionRecs(enemy.entity.collider, player.player_projectile.collider)) {
                const entity = &enemy.entity;
                entity.try_hit(10);
                if (entity.is_dead) {
                    player.up_exp();
                }
            }

            for (player.player_meteors.list.items) |*meteor| {
                if (meteor.collider) |collider| {
                    if (rl.CheckCollisionRecs(enemy.entity.collider, collider)) {
                        const entity = &enemy.entity;
                        entity.try_hit(20);
                        if (entity.is_dead) {
                            player.up_exp();
                        }
                    }
                }
            }
        }

        enemy.update(&player.entity);
    }
}

pub fn draw(self: *const Enemies) void {
    for (self.list.items) |*enemy| {
        enemy.draw();
    }
    for (self.list.items) |*enemy| {
        enemy.entity.draw_hit_text();
    }
}
