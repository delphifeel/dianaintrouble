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
var skills_pool_left: []skills.SkillId = undefined;
var upgrades_pool: []skills.SkillUpgradeId = undefined;
var allocator: std.mem.Allocator = undefined;
var game_paused: *bool = undefined;

var hovered_card_index: i32 = -1;
var transforms: [MAX_UPGRADES]rl.Rectangle = undefined;
var names: [MAX_UPGRADES]Text = undefined;
var descriptions: [MAX_UPGRADES]Text = undefined;

pub fn init(_allocator: std.mem.Allocator, _game_paused: *bool) void {
    allocator = _allocator;
    var prng = std.rand.DefaultPrng.init(0);
    rand_algo = prng.random();
    game_paused = _game_paused;

    const skills_ids = std.enums.values(skills.SkillId);
    skills_pool = allocator.dupe(skills.SkillId, skills_ids) catch h.oom();
    skills_pool_left = skills_pool;

    const upgrades_ids = std.enums.values(skills.SkillUpgradeId);
    upgrades_pool = allocator.dupe(skills.SkillUpgradeId, upgrades_ids) catch h.oom();
}

pub fn deinit() void {
    allocator.free(skills_pool);
    allocator.free(upgrades_pool);
}

const CARD_HEIGHT = screen.remy(50);
const CARD_WIDTH = screen.remx(20);
const CARD_GAP = screen.remx(8);
const CARD_NAME_Y_PADDING = screen.remy(2);

const PANEL_RECT = rutils.new_rect_in_center(rutils.calc_panel_size(MAX_UPGRADES, CARD_WIDTH, CARD_GAP), CARD_HEIGHT);

pub fn show(lvl: u32) void {
    game_paused.* = true;

    if (lvl == 2) {
        prepare_skills();
    } else {
        prepare_upgrades();
    }

    visible = true;
}

// TODO: remove heart cause its default for player
fn prepare_skills() void {
    if (skills_pool_left.len == 0) {
        return;
    }

    rand_algo.shuffle(skills.SkillId, skills_pool_left);
    for (0..MAX_UPGRADES) |i| {
        const skill_id = skills_pool_left[0];
        const skill = skills.find_skill_by_id(skill_id);

        const pos_x = rutils.calc_child_pos(i, PANEL_RECT.x, CARD_WIDTH, CARD_GAP);
        transforms[i] = rutils.new_rect(pos_x, PANEL_RECT.y, CARD_WIDTH, CARD_HEIGHT);

        const name_bounds = rutils.rect_with_padding(transforms[i], 0, CARD_NAME_Y_PADDING);
        names[i] = Text.init_aligned(skill.name, .Big, name_bounds, .Top);

        const description_bounds = transforms[i];
        descriptions[i] = Text.init_aligned(skill.description, .Medium, description_bounds, .AllCenter);

        skills_pool_left = skills_pool_left[1..];
        if (skills_pool_left.len == 0) {
            break;
        }
    }
}

fn prepare_upgrades() void {}

pub fn update() void {
    if (!visible) {
        return;
    }

    hovered_card_index = -1;
    for (transforms, 0..) |transform, i| {
        if (rl.CheckCollisionPointRec(rl.GetMousePosition(), transform)) {
            hovered_card_index = @intCast(i);

            if (rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT)) {
                visible = false;
                game_paused.* = false;
            }

            break;
        }
    }
}

pub fn draw() void {
    if (visible) {
        for (transforms, 0..) |transform, i| {
            const color = if (hovered_card_index == i) rl.DARKGREEN else rl.BROWN;
            rl.DrawRectangleRec(transform, color);
        }
        for (names) |name_text| {
            name_text.draw();
        }
        for (descriptions) |desc_text| {
            desc_text.draw();
        }
    }
}
