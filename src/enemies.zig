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

var maxEnemiesPerRespawn: i32 = 30;
// TODO: seg. fault on this values
// const START_ENEMIES_COUNT: f32 = 1000;
// var maxEnemiesPerRespawn: i32 = 30;
// const RESPAWN_COUNT_INC = 1000;
const START_ENEMIES_COUNT: f32 = 100;
const RESPAWN_COUNT_INC = 5;
const MIN_OFFSET: f32 = 700;
const MAX_OFFSET: f32 = 900;
const SPAWN_EVERY: f32 = 3;

pub fn spawn(allocator: std.mem.Allocator, player_center: rl.Vector2) Enemies {
    var enemies = std.ArrayList(Enemy).initCapacity(allocator, START_ENEMIES_COUNT * 10) catch h.oom();
    var i: i32 = 0;
    while (i < START_ENEMIES_COUNT) {
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
    var respawnedCount: i32 = 0;
    if (self.time_passed >= SPAWN_EVERY) {
        self.time_passed = 0;
        need_to_spawn = true;
        maxEnemiesPerRespawn += RESPAWN_COUNT_INC;
    }

    for (self.list.items, 0..) |*enemy, i| {
        if (enemy.entity.is_dead) {
            if (need_to_spawn and respawnedCount < maxEnemiesPerRespawn) {
                respawnedCount += 1;
                const rand_pos = rutils.rand_coord_in_range(player.entity.position_center, MIN_OFFSET, MAX_OFFSET);
                self.list.items[i] = Enemy.init(rand_pos);
            }
        } else {
            player.hit_enemy_with_skills(&enemy.entity);
        }

        enemy.update(&player.entity);
    }

    if (need_to_spawn and respawnedCount < maxEnemiesPerRespawn) {
        while (respawnedCount < maxEnemiesPerRespawn) {
            respawnedCount += 1;
            const rand_pos = rutils.rand_coord_in_range(player.entity.position_center, MIN_OFFSET, MAX_OFFSET);
            var enemy = Enemy.init(rand_pos);
            self.list.append(enemy) catch h.oom();
        }
    }
}

pub fn draw(self: *const Enemies) void {
    // TODO: this should be separated array for cache
    for (self.list.items) |*enemy| {
        if (enemy.entity.is_dead) {
            enemy.draw();
        }
    }
    for (self.list.items) |*enemy| {
        if (!enemy.entity.is_dead) {
            enemy.draw();
        }
    }
    for (self.list.items) |*enemy| {
        enemy.entity.draw_hit_text();
    }
}
