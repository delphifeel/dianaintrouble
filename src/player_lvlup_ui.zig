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

const MAX_VISIBLE_CARDS = 3;

var rand_algo: std.rand.Random = undefined;
var skills_pool: std.ArrayList(skillsInfo.SkillId) = undefined;
var upgrades_pool: std.ArrayList(skillsInfo.UpgradeId) = undefined;
var allocator: std.mem.Allocator = undefined;
var game_paused: *bool = undefined;

var hovered_card_index: i32 = -1;
const Card = struct {
    id: union(enum) {
        skill: skillsInfo.SkillId,
        upgrade: skillsInfo.UpgradeId,
    },
    transform: rl.Rectangle,
    name: Text,
    description: Text,
};
var cards: [MAX_VISIBLE_CARDS]Card = undefined;
var cards_count: usize = 0;

const CARD_HEIGHT = screen.remy(50);
const CARD_WIDTH = screen.remx(20);
const CARD_GAP = screen.remx(8);
const CARD_NAME_Y_PADDING = screen.remy(2);
const PANEL_RECT = rutils.new_rect_in_center(rutils.calc_panel_size(
    MAX_VISIBLE_CARDS,
    CARD_WIDTH,
    CARD_GAP,
), CARD_HEIGHT);

pub fn init(_allocator: std.mem.Allocator, _game_paused: *bool, player: *const Player) void {
    allocator = _allocator;
    var prng = std.rand.DefaultPrng.init(0);
    rand_algo = prng.random();
    game_paused = _game_paused;

    const skills_ids = std.enums.values(skillsInfo.SkillId);
    skills_pool = std.ArrayList(skillsInfo.SkillId).initCapacity(allocator, skills_ids.len) catch h.oom();
    upgrades_pool = std.ArrayList(skillsInfo.UpgradeId).initCapacity(allocator, 10) catch h.oom();

    for (skills_ids) |skill_id| {
        if (player.has_active_skill(skill_id)) {
            add_skill_upgrades_to_pool(skill_id);
            continue;
        }
        skills_pool.append(skill_id) catch h.oom();
    }
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
    cards_count = 0;

    rand_algo.shuffle(skillsInfo.SkillId, skills_pool.items);

    for (skills_pool.items, 0..) |skill_id, i| {
        cards_count += 1;
        const skill = skillsInfo.find_skill_by_id(skill_id);
        const pos_x = rutils.calc_child_pos(i, PANEL_RECT.x, CARD_WIDTH, CARD_GAP);
        const transform = rutils.new_rect(pos_x, PANEL_RECT.y, CARD_WIDTH, CARD_HEIGHT);
        const name_bounds = rutils.rect_with_padding(transform, 0, CARD_NAME_Y_PADDING);

        cards[i] = .{
            .id = .{ .skill = skill_id },
            .transform = transform,
            .name = Text.init_aligned(skill.name, .Big, name_bounds, .Top),
            .description = Text.init_aligned(skill.description, .Medium, transform, .AllCenter),
        };

        if (i == MAX_VISIBLE_CARDS - 1) {
            break;
        }
    }
}

fn prepare_upgrades() void {
    cards_count = 0;
    rand_algo.shuffle(skillsInfo.UpgradeId, upgrades_pool.items);

    for (upgrades_pool.items, 0..) |id, i| {
        cards_count += 1;
        const upgrade = skillsInfo.find_upgrade_by_id(id) orelse unreachable;
        const pos_x = rutils.calc_child_pos(i, PANEL_RECT.x, CARD_WIDTH, CARD_GAP);
        const transform = rutils.new_rect(pos_x, PANEL_RECT.y, CARD_WIDTH, CARD_HEIGHT);
        const name_bounds = rutils.rect_with_padding(transform, 0, CARD_NAME_Y_PADDING);

        cards[i] = .{
            .id = .{ .upgrade = id },
            .transform = transform,
            .name = Text.init_aligned(upgrade.name, .Big, name_bounds, .Top),
            .description = Text.init_aligned(upgrade.description, .Medium, transform, .AllCenter),
        };

        if (i == MAX_VISIBLE_CARDS - 1) {
            break;
        }
    }
}

pub fn update(player: *Player) void {
    if (!visible) {
        return;
    }

    hovered_card_index = -1;

    for (0..cards_count) |i| {
        const transform = cards[i].transform;
        if (rl.CheckCollisionPointRec(rl.GetMousePosition(), transform)) {
            hovered_card_index = @intCast(i);

            if (rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT)) {
                switch (cards[i].id) {
                    .skill => |skill_to_add| {
                        add_skill_upgrades_to_pool(skill_to_add);

                        _ = skills_pool.swapRemove(i);
                        player.add_skill(skill_to_add);
                    },
                    .upgrade => |upgrade_to_add| {
                        player.add_upgrade(upgrade_to_add);
                    },
                }

                visible = false;
                game_paused.* = false;
            }

            break;
        }
    }
}

fn add_skill_upgrades_to_pool(skill_id: skillsInfo.SkillId) void {
    const skill_info = skillsInfo.find_skill_by_id(skill_id);
    for (skill_info.upgrades) |*upgrade| {
        upgrades_pool.append(upgrade.id) catch h.oom();
    }
}

pub fn draw() void {
    if (visible) {
        for (0..cards_count) |i| {
            const color = if (hovered_card_index == i) rl.DARKGREEN else rl.BROWN;
            rl.DrawRectangleRec(cards[i].transform, color);

            cards[i].name.draw();
            cards[i].description.draw();
        }
    }
}
