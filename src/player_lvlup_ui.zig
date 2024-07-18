const std = @import("std");
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");
const h = @import("helpers.zig");
const rutils = @import("rutils.zig");

const screen = @import("screen.zig");
const skillsInfo = @import("player_skills_info.zig");
const Text = @import("gui/text.zig");
const Player = @import("player.zig");

pub var visible = false;

const MAX_UPGRADES = 3;

var rand_algo: std.rand.Random = undefined;
var skills_pool_buffer: []skillsInfo.SkillId = undefined;
var skills_pool: []skillsInfo.SkillId = undefined;
var upgrades_pool_buffer: []skillsInfo.UpgradeId = undefined;
var upgrades_pool: []skillsInfo.UpgradeId = undefined;
var allocator: std.mem.Allocator = undefined;
var game_paused: *bool = undefined;

var hovered_card_index: i32 = -1;
var is_showing_skills = false;
var visible_skills: [MAX_UPGRADES]skillsInfo.SkillId = undefined;
var visible_upgrades: [MAX_UPGRADES]skillsInfo.UpgradeId = undefined;
var transforms: [MAX_UPGRADES]rl.Rectangle = undefined;
var names: [MAX_UPGRADES]Text = undefined;
var descriptions: [MAX_UPGRADES]Text = undefined;

pub fn init(_allocator: std.mem.Allocator, _game_paused: *bool) void {
    allocator = _allocator;
    var prng = std.rand.DefaultPrng.init(0);
    rand_algo = prng.random();
    game_paused = _game_paused;

    const skills_ids = std.enums.values(skillsInfo.SkillId);
    skills_pool_buffer = allocator.dupe(skillsInfo.SkillId, skills_ids) catch h.oom();
    skills_pool = skills_pool_buffer;

    const upgrades_ids = std.enums.values(skillsInfo.UpgradeId);
    upgrades_pool_buffer = allocator.dupe(skillsInfo.UpgradeId, upgrades_ids) catch h.oom();
    upgrades_pool = upgrades_pool_buffer;
}

pub fn deinit() void {
    allocator.free(skills_pool_buffer);
    allocator.free(upgrades_pool_buffer);
}

const CARD_HEIGHT = screen.remy(50);
const CARD_WIDTH = screen.remx(20);
const CARD_GAP = screen.remx(8);
const CARD_NAME_Y_PADDING = screen.remy(2);

const PANEL_RECT = rutils.new_rect_in_center(rutils.calc_panel_size(MAX_UPGRADES, CARD_WIDTH, CARD_GAP), CARD_HEIGHT);

pub fn show(lvl: u32) void {
    if (lvl == 2 or (lvl % 8 == 0)) {
        if (skills_pool.len == 0) {
            return;
        }
        prepare_skills();
    } else {
        if (upgrades_pool.len == 0) {
            return;
        }
        prepare_upgrades();
    }

    game_paused.* = true;
    visible = true;
}

// TODO: remove heart cause its default for player
fn prepare_skills() void {
    is_showing_skills = true;
    rand_algo.shuffle(skillsInfo.SkillId, skills_pool);
    for (0..MAX_UPGRADES) |i| {
        const skill_id = skills_pool[0];
        visible_skills[i] = skill_id;
        const skill = skillsInfo.find_skill_by_id(skill_id);

        const pos_x = rutils.calc_child_pos(i, PANEL_RECT.x, CARD_WIDTH, CARD_GAP);
        transforms[i] = rutils.new_rect(pos_x, PANEL_RECT.y, CARD_WIDTH, CARD_HEIGHT);

        const name_bounds = rutils.rect_with_padding(transforms[i], 0, CARD_NAME_Y_PADDING);
        names[i] = Text.init_aligned(skill.name, .Big, name_bounds, .Top);

        const description_bounds = transforms[i];
        descriptions[i] = Text.init_aligned(skill.description, .Medium, description_bounds, .AllCenter);

        skills_pool = skills_pool[1..];
        if (skills_pool.len == 0) {
            break;
        }
    }
}

fn prepare_upgrades() void {
    is_showing_skills = false;
    rand_algo.shuffle(skillsInfo.UpgradeId, upgrades_pool);

    var showing_count: i32 = 0;
    for (0..MAX_UPGRADES) |i| {
        if (showing_count == MAX_UPGRADES) {
            break;
        }

        const upgrade_id = upgrades_pool[0];
        visible_upgrades[i] = upgrade_id;
        const upgrade = skillsInfo.find_upgrade_by_id(upgrade_id);

        const pos_x = rutils.calc_child_pos(i, PANEL_RECT.x, CARD_WIDTH, CARD_GAP);
        transforms[i] = rutils.new_rect(pos_x, PANEL_RECT.y, CARD_WIDTH, CARD_HEIGHT);

        const name_bounds = rutils.rect_with_padding(transforms[i], 0, CARD_NAME_Y_PADDING);
        names[i] = Text.init_aligned(upgrade.info.name, .Big, name_bounds, .Top);

        const description_bounds = transforms[i];
        descriptions[i] = Text.init_aligned(upgrade.info.description, .Medium, description_bounds, .AllCenter);

        upgrades_pool = upgrades_pool[1..];
        if (upgrades_pool.len == 0) {
            break;
        }
    }
}

pub fn update(player: *Player) void {
    if (!visible) {
        return;
    }

    hovered_card_index = -1;
    for (transforms, 0..) |transform, i| {
        if (rl.CheckCollisionPointRec(rl.GetMousePosition(), transform)) {
            hovered_card_index = @intCast(i);

            if (rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT)) {
                if (is_showing_skills) {
                    player.add_skill(visible_skills[i]);
                } else {
                    player.add_upgrade(visible_upgrades[i]);
                }
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
