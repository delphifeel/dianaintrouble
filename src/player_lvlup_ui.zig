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
var skills_pool: std.ArrayList(skillsInfo.SkillId) = undefined;
var upgrades_pool: std.ArrayList(skillsInfo.UpgradeId) = undefined;
var allocator: std.mem.Allocator = undefined;
var game_paused: *bool = undefined;

var hovered_card_index: i32 = -1;
var is_showing_skills = false;
var visible_skills: [MAX_UPGRADES]skillsInfo.SkillId = undefined;
var visible_upgrades: [MAX_UPGRADES]skillsInfo.UpgradeId = undefined;

var visible_cards_count: u32 = 0;
var transforms: [MAX_UPGRADES]rl.Rectangle = undefined;
var names: [MAX_UPGRADES]Text = undefined;
var descriptions: [MAX_UPGRADES]Text = undefined;

const CARD_HEIGHT = screen.remy(50);
const CARD_WIDTH = screen.remx(20);
const CARD_GAP = screen.remx(8);
const CARD_NAME_Y_PADDING = screen.remy(2);
const PANEL_RECT = rutils.new_rect_in_center(rutils.calc_panel_size(MAX_UPGRADES, CARD_WIDTH, CARD_GAP), CARD_HEIGHT);

pub fn init(_allocator: std.mem.Allocator, _game_paused: *bool, player: *const Player) void {
    allocator = _allocator;
    var prng = std.rand.DefaultPrng.init(0);
    rand_algo = prng.random();
    game_paused = _game_paused;

    const skills_ids = std.enums.values(skillsInfo.SkillId);
    skills_pool = std.ArrayList(skillsInfo.SkillId).initCapacity(allocator, skills_ids.len) catch h.oom();
    for (skills_ids) |skill_id| {
        if (player.has_active_skill(skill_id)) {
            continue;
        }
        skills_pool.append(skill_id) catch h.oom();
    }

    upgrades_pool = std.ArrayList(skillsInfo.UpgradeId).initCapacity(allocator, 10) catch h.oom();
}

pub fn deinit() void {
    skills_pool.deinit();
    upgrades_pool.deinit();
}

pub fn show(lvl: u32) void {
    if ((lvl == 2) or (lvl % 8 == 0)) {
        if (skills_pool.items.len == 0) {
            return;
        }
        prepare_skills();
    } else {
        prepare_upgrades();
    }

    game_paused.* = true;
    visible = true;
}

fn prepare_skills() void {
    is_showing_skills = true;
    visible_cards_count = 0;

    rand_algo.shuffle(skillsInfo.SkillId, skills_pool.items);

    for (skills_pool.items, 0..) |skill_id, i| {
        visible_cards_count += 1;
        visible_skills[i] = skill_id;
        const skill = skillsInfo.find_skill_by_id(skill_id);

        const pos_x = rutils.calc_child_pos(i, PANEL_RECT.x, CARD_WIDTH, CARD_GAP);
        transforms[i] = rutils.new_rect(pos_x, PANEL_RECT.y, CARD_WIDTH, CARD_HEIGHT);

        const name_bounds = rutils.rect_with_padding(transforms[i], 0, CARD_NAME_Y_PADDING);
        names[i] = Text.init_aligned(skill.name, .Big, name_bounds, .Top);

        const description_bounds = transforms[i];
        descriptions[i] = Text.init_aligned(skill.description, .Medium, description_bounds, .AllCenter);

        if (i == MAX_UPGRADES - 1) {
            break;
        }
    }
}

fn prepare_upgrades() void {
    is_showing_skills = false;
    visible_cards_count = 0;
    rand_algo.shuffle(skillsInfo.UpgradeId, upgrades_pool.items);

    for (upgrades_pool.items, 0..) |id, i| {
        visible_cards_count += 1;
        visible_upgrades[i] = id;
        const upgrade = skillsInfo.find_upgrade_by_id(id);

        const pos_x = rutils.calc_child_pos(i, PANEL_RECT.x, CARD_WIDTH, CARD_GAP);
        transforms[i] = rutils.new_rect(pos_x, PANEL_RECT.y, CARD_WIDTH, CARD_HEIGHT);

        const name_bounds = rutils.rect_with_padding(transforms[i], 0, CARD_NAME_Y_PADDING);
        names[i] = Text.init_aligned(upgrade.info.name, .Big, name_bounds, .Top);

        const description_bounds = transforms[i];
        descriptions[i] = Text.init_aligned(upgrade.info.description, .Medium, description_bounds, .AllCenter);

        if (i == MAX_UPGRADES - 1) {
            break;
        }
    }
}

pub fn update(player: *Player) void {
    if (!visible) {
        return;
    }

    hovered_card_index = -1;
    for (0..visible_cards_count) |i| {
        const transform = transforms[i];
        if (rl.CheckCollisionPointRec(rl.GetMousePosition(), transform)) {
            hovered_card_index = @intCast(i);

            if (rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT)) {
                if (is_showing_skills) {
                    const skill_to_add = visible_skills[i];

                    // filter related upgrades
                    for (skillsInfo.all_upgrades.kvs) |iter| {
                        const upgrade = iter.value;

                        if (player.has_active_skill(upgrade.related_skill)) {
                            continue;
                        }

                        if (upgrade.related_skill == skill_to_add) {
                            upgrades_pool.append(upgrade.info.id) catch h.oom();
                        }
                    }

                    _ = skills_pool.swapRemove(i);
                    player.add_skill(skill_to_add);
                } else {
                    const upgade_to_add = visible_upgrades[i];
                    player.add_upgrade(upgade_to_add);
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
        for (0..visible_cards_count) |i| {
            const transform = transforms[i];
            const color = if (hovered_card_index == i) rl.DARKGREEN else rl.BROWN;
            rl.DrawRectangleRec(transform, color);

            const name = names[i];
            name.draw();

            const description = descriptions[i];
            description.draw();
        }
    }
}
