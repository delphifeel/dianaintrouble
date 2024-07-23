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
    Shield,
};

// TODO: we need max values (speed, dmg etc) for upgrades
pub const UpgradeId = enum {
    FasterHeart,
    StrongerHeart,
    MeteorsFasterSpawn,
    StrongerMeteors,
    SparklesFasterSpawn,
    StrongerSparkles,
    SparklesBigger,
};

pub const Skill = struct {
    id: SkillId,
    name: h.string_view,
    description: h.string_view,
    upgrades: []const Upgrade,
};

pub const Upgrade = struct {
    id: UpgradeId,
    name: h.string_view,
    description: h.string_view,
};

pub fn find_skill_by_id(id: SkillId) Skill {
    return all_skills.get(@tagName(id)).?;
}

// TODO: need more performant way
pub fn find_upgrade_by_id(id: UpgradeId) ?Upgrade {
    for (all_skills.kvs) |kv| {
        for (kv.value.upgrades) |upgrade| {
            if (upgrade.id == id) {
                return upgrade;
            }
        }
    }
    return null;
}

const all_skills = std.ComptimeStringMap(Skill, .{
    .{ @tagName(.Shield), .{
        .id = .Shield,
        .name = "Shield",
        .description = "Shield",
        .upgrades = &.{},
    } },
    .{ @tagName(.Heart), .{
        .id = .Heart,
        .name = "Heart",
        .description = "Heart going around player",
        .upgrades = &.{
            .{
                .id = .FasterHeart,
                .name = "Faster Heart",
                .description = "Faster Heart",
            },
            .{
                .id = .StrongerHeart,
                .name = "StrongerHeart",
                .description = "StrongerHeart",
            },
        },
    } },
    .{ @tagName(.Meteors), .{
        .id = .Meteors,
        .name = "Meteors",
        .description = "Meteors",
        .upgrades = &.{
            .{
                .id = .MeteorsFasterSpawn,
                .name = "Faster Meteors Spawn",
                .description = "Faster Meteors Spawn",
            },
            .{
                .id = .StrongerMeteors,
                .name = "StrongerMeteors",
                .description = "StrongerMeteors",
            },
        },
    } },
    .{ @tagName(.Sparkles), .{
        .id = .Sparkles,
        .name = "Sparkles",
        .description = "Sparkles",
        .upgrades = &.{
            .{
                .id = .SparklesFasterSpawn,
                .name = "Faster Sparkles Spawn",
                .description = "Faster Sparkles Spawn",
            },
            .{
                .id = .StrongerSparkles,
                .name = "StrongerSparkles",
                .description = "StrongerSparkles",
            },
            .{
                .id = .SparklesBigger,
                .name = "Sparkles Bigger",
                .description = "Sparkles Bigger",
            },
        },
    } },
});

comptime {
    const upgrades = std.enums.values(UpgradeId);

    for (upgrades) |upgrade_to_find| {
        if (find_upgrade_by_id(upgrade_to_find) == null) {
            @compileError("There is upgrade not set to skill: " ++ @tagName(upgrade_to_find));
        }
    }
}
