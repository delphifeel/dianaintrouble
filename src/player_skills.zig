const std = @import("std");
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");

// ---+---+--- helpers imports ---+---+---
const h = @import("helpers.zig");
const rutils = @import("rutils.zig");
// ---+---+---+---+---+---

pub const SkillId = enum {
    Heart,
    Meteors,
    Sparkles,
};
pub const Skill = struct {
    id: SkillId,
    name: h.string_view,
    description: h.string_view,
};

pub fn find_skill_by_id(skill_id: SkillId) Skill {
    return all.get(@tagName(skill_id)).?;
}

const all = std.ComptimeStringMap(Skill, .{
    .{ @tagName(.Heart), .{
        .id = .Heart,
        .name = "Heart",
        .description = "Heart going around player",
    } },
    .{ @tagName(.Meteors), .{
        .id = .Meteors,
        .name = "Meteors",
        .description = "Meteors",
    } },
    .{ @tagName(.Sparkles), .{
        .id = .Sparkles,
        .name = "Sparkles",
        .description = "Sparkles",
    } },
});

pub const SkillUpgrade = struct {
    upgrade_info: Skill,
    related_skill: SkillId,
};

pub const SkillUpgradeId = enum {
    FasterHeart,
    FasterMeteors,
    FasterSparkles,
};

pub const upgrades = std.ComptimeStringMap(SkillUpgrade, .{
    .{ @tagName(.FasterHeart), .{
        .id = .FasterHeart,
        .name = "Faster Heart",
        .description = "Heart moving faster",
    } },
    .{ @tagName(.FasterMeteors), .{
        .id = .FasterMeteors,
        .name = "Faster Meteors",
        .description = "Meteors falling faster",
    } },
    .{ @tagName(.FasterSparkles), .{
        .id = .FasterSparkles,
        .name = "Faster Sparkles",
        .description = "Faster spawn of sparkles",
    } },
});
