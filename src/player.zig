const std = @import("std");
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");
const h = @import("helpers.zig");
const rutils = @import("rutils.zig");
const debug_info = @import("debug_info.zig");

const Text = @import("gui/text.zig");
const Progressbar = @import("gui/progressbar.zig");
const fonts = @import("gui/fonts.zig");
const HeartProjectile = @import("player_skills/heart_projectile.zig");
const Meteors = @import("player_skills/meteors.zig");
const Sparkles = @import("player_skills/sparkles.zig");
const Shield = @import("player_skills/shield.zig");
const Entity = @import("entity.zig");
const Background = @import("background.zig");

const screen = @import("screen.zig");
const player_lvlup_ui = @import("player_lvlup_ui.zig");
const skillsInfo = @import("player_skills_info.zig");

const Self = @This();

entity: Entity,
exp: f32,
lvl: u32,
hp_bar: Progressbar,
// TODO: move to sep. module
exp_progressbar: Progressbar,
exp_needed_for_lvl: f32 = 4,

// skills
active_skills: std.ArrayList(skillsInfo.SkillId),
active_upgrades: std.ArrayList(skillsInfo.UpgradeId),
heart_projectile: HeartProjectile,
meteors: Meteors,
sparkles: Sparkles,
shield_skill: Shield,

const DEFAULT_SKILLS_ARRAY_CAP = 100;
const START_HEALTH = 40;
// const START_HEALTH = 200;

pub fn init(allocator: std.mem.Allocator, pos: rl.Vector2) Self {
    const entity = Entity.init(pos, 60, START_HEALTH, rl.RED);
    var meteors = Meteors.init(allocator);

    var skills = std.ArrayList(skillsInfo.SkillId).initCapacity(allocator, DEFAULT_SKILLS_ARRAY_CAP) catch h.oom();
    // default skills
    skills.append(skillsInfo.SkillId.Heart) catch h.oom();
    const upgrades = std.ArrayList(skillsInfo.UpgradeId).initCapacity(allocator, DEFAULT_SKILLS_ARRAY_CAP) catch h.oom();

    return Self{
        .entity = entity,
        .heart_projectile = HeartProjectile.init(entity.position_center),
        .sparkles = Sparkles.init(entity.position_center),
        .shield_skill = Shield.init(entity.position_center),
        .meteors = meteors,
        .exp = 0,
        .lvl = 1,
        .exp_progressbar = init_exp_bar(),
        .hp_bar = init_hp_bar(entity.position_center),
        .active_skills = skills,
        .active_upgrades = upgrades,
    };
}

pub fn deinit(self: *Self) void {
    self.entity.deinit();
    self.meteors.deinit();
    self.sparkles.deinit();
    self.active_skills.deinit();
    self.active_upgrades.deinit();
    self.shield_skill.deinit();
}

pub fn hit_enemy_with_skills(self: *Self, enemy_entity: *Entity) void {
    var dmg_sum: f32 = 0;

    for (self.active_skills.items) |skill_id| {
        switch (skill_id) {
            // TODO: is shield special case ?
            .Shield => {},
            .Heart => {
                if (rl.CheckCollisionRecs(enemy_entity.collider, self.heart_projectile.collider)) {
                    dmg_sum += self.heart_projectile.dmg;
                }
            },
            .Meteors => {
                for (self.meteors.list.items) |*meteor| {
                    if (meteor.explosion_collider) |collider| {
                        if (rl.CheckCollisionRecs(enemy_entity.collider, collider)) {
                            dmg_sum += self.meteors.dmg;
                        }
                    }
                }
            },
            .Sparkles => {
                if (self.sparkles.is_collides(enemy_entity.collider)) {
                    dmg_sum += self.sparkles.dmg;
                }
            },
        }
    }

    if (dmg_sum > 0) {
        enemy_entity.try_hit(dmg_sum);
        if (enemy_entity.is_dead) {
            self.up_exp();
        }
    }
}

pub fn has_active_skill(self: *const Self, id: skillsInfo.SkillId) bool {
    for (self.active_skills.items) |active_skill_id| {
        if (active_skill_id == id) {
            return true;
        }
    }
    return false;
}

pub fn add_skill(self: *Self, id: skillsInfo.SkillId) void {
    self.active_skills.append(id) catch h.oom();
}

pub fn add_upgrade(self: *Self, id: skillsInfo.UpgradeId) void {
    self.active_upgrades.append(id) catch h.oom();

    switch (id) {
        .HeartRange => self.heart_projectile.offset_from_center *= 1.1,
        .ShieldEndurence => {
            self.entity.health += 1;
            self.entity.max_health += 1;
        },
        .ShieldFasterRestore => self.shield_skill.restore_timeout *= 0.9,
        .SparklesBigger => self.sparkles.size *= 1.3,
        .HeartFaster => self.heart_projectile.speed *= 1.1,
        .HeartStronger => self.heart_projectile.dmg *= 1.1,
        .MeteorsFasterSpawn => self.meteors.spawn_timeout *= 0.9,
        .MeteorsStronger => self.meteors.dmg *= 1.1,
        .SparklesFasterSpawn => self.sparkles.fire_timeout *= 0.9,
        .SparklesStronger => self.sparkles.dmg *= 1.1,
    }
}

fn up_exp(self: *Self) void {
    self.exp += 1;
    if (self.exp > self.exp_needed_for_lvl) {
        self.exp = 0;
        self.lvl += 1;
        self.exp_needed_for_lvl *= 1.3;
        player_lvlup_ui.show(self.lvl);
    }
}

pub fn update(self: *Self) void {
    const frame_time = rl.GetFrameTime();
    const step = rutils.distance_per_frame(80, frame_time);
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
    self.update_skills();
    self.update_hp_bar();
}

fn update_hp_bar(self: *Self) void {
    self.hp_bar.fill_color = if (self.entity.shield > 0) rl.BLUE else rl.GREEN;
    self.hp_bar.transform = calc_hp_bar_transform(self.entity.position_center);
}

fn update_skills(self: *Self) void {
    for (self.active_skills.items) |skill_id| {
        switch (skill_id) {
            .Shield => self.shield_skill.update(self),
            .Heart => self.heart_projectile.update(self.entity.position_center),
            .Meteors => self.meteors.update(self.entity.position_center),
            .Sparkles => self.sparkles.update(self.entity.position_center),
        }
    }
}

pub fn draw_skills(self: *const Self) void {
    for (self.active_skills.items) |skill_id| {
        switch (skill_id) {
            .Shield => self.shield_skill.draw(),
            .Heart => self.heart_projectile.draw(),
            .Meteors => self.meteors.draw(),
            .Sparkles => self.sparkles.draw(),
        }
    }
}

pub fn draw(self: *const Self) void {
    self.entity.draw(rl.BLUE);
    self.draw_hp_bar();
}

fn draw_hp_bar(self: *const Self) void {
    const hp_f: f32 = @floatFromInt(self.entity.health);
    const max_hp_f: f32 = @floatFromInt(self.entity.max_health);
    self.hp_bar.draw(hp_f, max_hp_f);
}

fn init_hp_bar(player_center: rl.Vector2) Progressbar {
    return Progressbar{
        .transform = calc_hp_bar_transform(player_center),
        .background_color = rl.GRAY,
        .fill_color = rl.GREEN,
    };
}

fn calc_hp_bar_transform(player_center: rl.Vector2) rl.Rectangle {
    var pos = player_center;
    pos.y -= 40;
    return rutils.new_rect_with_center_pos(pos, 70, 12);
}

pub fn draw_exp_progress(self: *const Self) void {
    self.exp_progressbar.draw(self.exp, self.exp_needed_for_lvl);
}

fn init_exp_bar() Progressbar {
    var transform = rutils.new_rect_at_top(screen.remx(60), screen.remy(4));
    transform.y += screen.remy(2);

    return Progressbar{
        .transform = transform,
        .background_color = rl.GRAY,
        .fill_color = rl.BLUE,
    };
}
