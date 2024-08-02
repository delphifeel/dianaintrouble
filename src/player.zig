const std = @import("std");
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");
const h = @import("helpers.zig");
const rutils = @import("rutils.zig");
const debug_info = @import("debug_info.zig");

const Text = @import("gui/text.zig");
const Progressbar = @import("gui/progressbar.zig");
const Entity = @import("entity.zig");
const Background = @import("background.zig");
const SpriteAnimation = @import("sprite_animation.zig");

const fonts = @import("gui/fonts.zig");
const screen = @import("screen.zig");
const player_lvlup_ui = @import("player_lvlup_ui.zig");
const skillsInfo = @import("player_skills_info.zig");

// skills
const HeartProjectile = @import("player_skills/heart_projectile.zig");
const Meteors = @import("player_skills/meteors.zig");
const Sparkles = @import("player_skills/sparkles.zig");
const Shield = @import("player_skills/shield.zig");
const Knight = @import("player_skills/knight.zig");
const Moon = @import("player_skills/moon.zig");

const Self = @This();

entity: Entity,
run_animation: SpriteAnimation,
idle_animation: SpriteAnimation,
exp: f32,
lvl: u32,
hp_bar: Progressbar,
// TODO: move to sep. module
exp_progressbar: Progressbar,

transform: rl.Rectangle = undefined,
is_moving: bool = false,
exp_needed_for_lvl: f32 = 10,

// skills
active_skills: std.ArrayList(skillsInfo.SkillId),
active_upgrades: std.ArrayList(skillsInfo.UpgradeId),
heart_projectile: HeartProjectile,
moon: Moon,
meteors: Meteors,
sparkles: Sparkles,
knight: Knight,
shield_skill: Shield,

const DEFAULT_SKILLS_ARRAY_CAP = 100;
// const START_HEALTH = 200;
const START_HEALTH = 400;
const MOVE_SPEED: comptime_float = 200;

const ANIMATION_SPEED: comptime_float = 0.1;
const SPRITE_DEST_SIZE: comptime_float = 200;

pub fn init(allocator: std.mem.Allocator, pos: rl.Vector2) Self {
    const entity = Entity.init(pos, START_HEALTH, rl.RED);
    var meteors = Meteors.init(allocator);

    var skills = std.ArrayList(skillsInfo.SkillId).initCapacity(allocator, DEFAULT_SKILLS_ARRAY_CAP) catch h.oom();
    // default skills
    skills.append(.Heart) catch h.oom();
    // skills.append(.Meteors) catch h.oom();
    // skills.append(.Sparkles) catch h.oom();
    const upgrades = std.ArrayList(skillsInfo.UpgradeId).initCapacity(allocator, DEFAULT_SKILLS_ARRAY_CAP) catch h.oom();

    const texture_run = rl.LoadTexture("assets/character_run.png");
    const texture_idle = rl.LoadTexture("assets/character_idle.png");
    return Self{
        .run_animation = .{
            .texture = texture_run,
            .speed = ANIMATION_SPEED,
            .sprite_width = 64,
        },
        .idle_animation = .{
            .texture = texture_idle,
            .speed = ANIMATION_SPEED,
            .sprite_width = 64,
        },
        .entity = entity,
        .heart_projectile = HeartProjectile.init(entity.position_center),
        .sparkles = Sparkles.init(entity.position_center),
        .shield_skill = Shield.init(entity.position_center),
        .knight = Knight.init(entity.position_center),
        .moon = Moon.init(entity.position_center),
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
    self.knight.deinit();
    self.moon.deinit();
    self.heart_projectile.deinit();

    rl.UnloadTexture(self.run_animation.texture);
    rl.UnloadTexture(self.idle_animation.texture);
}

pub fn hit_enemy_with_skills(self: *Self, enemy_entity: *Entity) void {
    var dmg_sum: f32 = 0;
    var need_to_push = false;
    var push_vector = rm.Vector2Zero();

    for (self.active_skills.items) |skill_id| {
        switch (skill_id) {
            // TODO:  special cases ?
            .Shield => {},

            .Moon => {
                if (self.moon.is_collides(enemy_entity.collider)) {
                    dmg_sum += self.moon.dmg;
                }
            },
            .Knight => {
                if (rl.CheckCollisionRecs(enemy_entity.collider, self.knight.collider)) {
                    if (!self.knight.is_attacking) {
                        self.knight.play_attack_animation();
                    }
                    dmg_sum += self.knight.dmg;
                    need_to_push = true;
                    push_vector = self.knight.calc_push_vector();
                }
            },
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
        if (need_to_push) {
            enemy_entity.try_hit_and_push(dmg_sum, push_vector);
        } else {
            enemy_entity.try_hit(dmg_sum);
        }

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

// TODO: skills should init here - look sparkles example bug
pub fn add_skill(self: *Self, id: skillsInfo.SkillId) void {
    self.active_skills.append(id) catch h.oom();
}

pub fn add_upgrade(self: *Self, id: skillsInfo.UpgradeId) void {
    self.active_upgrades.append(id) catch h.oom();

    switch (id) {
        .MoonRange => self.moon.radius *= 1.1,
        .MoonStronger => self.moon.dmg *= 1.1,

        .KnightStronger => self.knight.dmg *= 1.1,
        .KnightFasterRotation => self.knight.rotation_timeout *= 0.9,
        .KnightBigger => self.knight.scale += 0.1,

        .HeartRange => self.heart_projectile.offset_from_center *= 1.1,
        .HeartFaster => self.heart_projectile.speed *= 1.1,
        .HeartStronger => self.heart_projectile.dmg *= 1.1,

        .ShieldEndurence => {
            self.entity.health += 10;
            self.entity.max_health += 10;
        },
        .ShieldFasterRestore => self.shield_skill.restore_timeout *= 0.9,

        .SparklesBigger => self.sparkles.size *= 1.3,
        .SparklesFasterSpawn => self.sparkles.fire_timeout *= 0.9,
        .SparklesStronger => self.sparkles.dmg *= 1.1,

        .MeteorsFasterSpawn => self.meteors.spawn_timeout *= 0.9,
        .MeteorsStronger => self.meteors.dmg *= 1.1,
    }
}

fn up_exp(self: *Self) void {
    self.exp += 1;
    if (self.exp > self.exp_needed_for_lvl) {
        self.exp = 0;
        self.lvl += 1;
        self.exp_needed_for_lvl *= 1.2;
        player_lvlup_ui.show(self.lvl);
    }
}

pub fn update(self: *Self) void {
    const frame_time = rl.GetFrameTime();
    const step = rutils.px_per_sec(MOVE_SPEED, frame_time);
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

    if (pos_delta.x < 0) {
        self.idle_animation.is_flip = true;
        self.run_animation.is_flip = true;
    } else if (pos_delta.x > 0) {
        self.idle_animation.is_flip = false;
        self.run_animation.is_flip = false;
    }
    self.transform = rutils.new_rect_with_center_pos(self.entity.position_center, SPRITE_DEST_SIZE, SPRITE_DEST_SIZE);
    const prev_is_moving = self.is_moving;
    if ((pos_delta.x == 0) and (pos_delta.y == 0)) {
        self.is_moving = false;
    } else {
        self.is_moving = true;
    }

    if (prev_is_moving != self.is_moving) {
        self.run_animation.reset();
        self.idle_animation.reset();
    }

    if (self.is_moving) {
        self.run_animation.update();
    } else {
        self.idle_animation.update();
    }

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
            .Moon => self.moon.update(self.entity.position_center),
            .Shield => self.shield_skill.update(self),
            .Heart => self.heart_projectile.update(self.entity.position_center),
            .Meteors => self.meteors.update(self.entity.position_center),
            .Sparkles => self.sparkles.update(self.entity.position_center),
            .Knight => self.knight.update(self.entity.position_center),
        }
    }
}

pub fn draw_skills(self: *const Self) void {
    for (self.active_skills.items) |skill_id| {
        switch (skill_id) {
            .Moon => self.moon.draw(),
            .Shield => self.shield_skill.draw(),
            .Heart => self.heart_projectile.draw(),
            .Meteors => self.meteors.draw(),
            .Sparkles => self.sparkles.draw(),
            .Knight => self.knight.draw(),
        }
    }
}

pub fn draw(self: *const Self) void {
    self.entity.draw();
    if (self.is_moving) {
        self.run_animation.draw(self.transform, self.entity.sprite_tint_color);
    } else {
        self.idle_animation.draw(self.transform, self.entity.sprite_tint_color);
    }
}

pub fn draw_exp_progress(self: *const Self) void {
    self.exp_progressbar.draw(self.exp, self.exp_needed_for_lvl);
}

pub fn draw_hp_bar(self: *const Self) void {
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
    pos.y -= 80;
    return rutils.new_rect_with_center_pos(pos, 70, 12);
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
