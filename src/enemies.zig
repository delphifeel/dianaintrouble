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

// DEBUG
// const START_ENEMIES_COUNT: f32 = 400;
// const RESPAWN_COUNT_INCREASE = 100;

var maxEnemiesPerRespawn: i32 = START_ENEMIES_COUNT;
var next_spawn_start_health: i32 = Enemy.DEFAULT_HEALTH;
const START_ENEMIES_COUNT: f32 = 40;
const RESPAWN_COUNT_INCREASE = 1;
const MIN_OFFSET: f32 = 700;
const MAX_OFFSET: f32 = 900;
const SPAWN_EVERY: f32 = 10;

pub fn spawn(allocator: std.mem.Allocator, player_center: rl.Vector2) Enemies {
    // TODO: make no allocations
    var enemies = std.ArrayList(Enemy).initCapacity(allocator, START_ENEMIES_COUNT * 1000) catch h.oom();
    var i: i32 = 0;
    while (i < START_ENEMIES_COUNT) {
        const rand_pos = rutils.rand_coord_in_range(player_center, MIN_OFFSET, MAX_OFFSET);
        var enemy = Enemy.init(rand_pos, Enemy.DEFAULT_HEALTH);
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
        maxEnemiesPerRespawn += RESPAWN_COUNT_INCREASE;
        const next_spawn_start_health_f: f32 = @floatFromInt(next_spawn_start_health);
        next_spawn_start_health = @intFromFloat(next_spawn_start_health_f * 1.1);
    }

    for (self.list.items, 0..) |*enemy, i| {
        if (enemy.entity.is_dead) {
            if (need_to_spawn and respawnedCount < maxEnemiesPerRespawn) {
                respawnedCount += 1;
                const rand_pos = rutils.rand_coord_in_range(player.entity.position_center, MIN_OFFSET, MAX_OFFSET);
                self.list.items[i] = Enemy.init(rand_pos, next_spawn_start_health);
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
            var enemy = Enemy.init(rand_pos, next_spawn_start_health);
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
