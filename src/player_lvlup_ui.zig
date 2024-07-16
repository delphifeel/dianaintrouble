const std = @import("std");
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");

// ---+---+--- helpers imports ---+---+---
const h = @import("helpers.zig");
const rutils = @import("rutils.zig");
const screen = @import("screen.zig");
const skills = @import("player_skills.zig");

const Text = @import("gui/text.zig");

pub var visible = false;

const MAX_UPGRADES = 3;

var rand_algo: std.rand.Random = undefined;
var skills_pool: []skills.SkillId = undefined;
var skills_pool_start_index: usize = 0;
var upgrades_pool: []skills.SkillUpgradeId = undefined;
var upgrades_pool_start_index: usize = 0;
var allocator: std.mem.Allocator = undefined;
var game_paused: *bool = undefined;

var transforms: [MAX_UPGRADES]rl.Rectangle = undefined;
var names: [MAX_UPGRADES]Text = undefined;

pub fn init(_allocator: std.mem.Allocator, _game_paused: *bool) void {
    allocator = _allocator;
    var prng = std.rand.DefaultPrng.init(0);
    rand_algo = prng.random();
    game_paused = _game_paused;

    const skills_ids = std.enums.values(skills.SkillId);
    skills_pool = allocator.dupe(skills.SkillId, skills_ids);

    const upgrades_ids = std.enums.values(skills.SkillUpgradeId);
    upgrades_pool = allocator.dupe(skills.SkillUpgradeId, upgrades_ids);
}

pub fn deinit() void {
    allocator.free(skills_pool);
    allocator.free(upgrades_pool);
}

const CARD_HEIGHT = screen.remy(50);
const CARD_WIDTH = screen.remx(20);
const CARD_GAP = screen.remx(8);

pub fn show(lvl: i32) void {
    game_paused.* = true;

    if (lvl == 2) {
        prepare_skills();
    } else {
        prepare_upgrades();
    }

    const panel_size = rutils.calc_panel_size(MAX_UPGRADES, CARD_WIDTH, CARD_GAP);
    const panel_rect = rutils.new_rect_in_center(panel_size, CARD_HEIGHT);
    for (0..MAX_UPGRADES) |i| {
        const pos_x = rutils.calc_child_pos(i, panel_rect.x, CARD_WIDTH, CARD_GAP);

        transforms[i] = rutils.new_rect(pos_x, panel_rect.y, CARD_WIDTH, CARD_HEIGHT);
        names[i] = Text.init_aligned("Hello", .Bigger, transforms[i], .AllCenter);
    }

    visible = true;
}

fn prepare_skills() void {
    // TODO: remove heart cause its default for player

    if (skills_pool_start_index == skills_pool.len) {
        return;
    }

    rand_algo.shuffle(skills.SkillId, skills_pool);
    for (skills_pool_start_index..(skills_pool_start_index + MAX_UPGRADES)) |i| {
        if (i == skills_pool.len) {
            break;
        }

        const skill_id = skills_pool[skills_pool_start_index];
        skills_pool_start_index += 1;
    }
}

fn prepare_skills() void {}

pub fn draw() void {
    if (visible) {
        for (transforms) |transform| {
            rl.DrawRectangleRec(transform, rl.BROWN);
        }
        for (names) |name_text| {
            name_text.draw();
        }
    }
}
