// Check list for prod:
// - Coords system
// - Diff. resolutions

// Known bugs:
// - Spawning out of background
// - Meteor explosion on top (need to be on background)

const std = @import("std");
const debug = std.debug;
const fmt = std.fmt;
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");
const screen = @import("screen.zig");
const debug_info = @import("debug_info.zig");

const fonts = @import("gui/fonts.zig");
const Background = @import("background.zig");
const Player = @import("player.zig");
const Enemies = @import("enemies.zig");

// ---+---+--- helpers imports ---+---+---
const helpers = @import("helpers.zig");
const string = helpers.string;
const string_view = helpers.string_view;
const oom = helpers.oom;

const rutils = @import("rutils.zig");
const new_vector2 = rutils.new_vector2;
// ---+---+---+---+---+---

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer debug.assert(!gpa.detectLeaks());
    var allocator = gpa.allocator();

    rl.SetTraceLogLevel(rl.LOG_WARNING);
    screen.init();
    defer screen.deinit();

    fonts.load_fonts(allocator);
    defer fonts.unload_fonts();

    var camera = rl.Camera2D{
        .offset = screen.Center,
        .target = rm.Vector2Zero(),
        .rotation = 0.0,
        .zoom = screen.camera_zoom,
    };
    var camera_set = false;

    var background = Background.init();
    defer background.deinit();

    var player = Player.init(allocator, rutils.calc_rect_center(Background.transform));
    defer player.deinit();
    player.start();

    var player_pos = player.entity.position_center;
    var enemies = Enemies.spawn(allocator, player_pos);
    defer enemies.deinit();

    while (!rl.WindowShouldClose()) {

        // ------------------------------ UPDATE -------------------------------
        {
            if (rl.IsMouseButtonPressed(rl.MOUSE_RIGHT_BUTTON)) {
                camera.zoom = 0.1;
            }

            player.update();
            camera_follow_player(&camera, &player, &camera_set);
            enemies.update(&player);
        }

        // ------------------------------- DRAW -------------------------------
        rl.BeginDrawing();
        rl.ClearBackground(rl.BLACK);

        rl.BeginMode2D(camera);
        {
            background.draw();
            enemies.draw();
            player.draw();
            player.player_projectile.draw();
            player.sparkles.draw();
            player.player_meteors.draw();
            // TODO: hit text as sep. module
            player.entity.draw_hit_text();
        }
        rl.EndMode2D();

        player.draw_exp_progress();
        screen.draw_fps();
        debug_info.draw(&camera);

        rl.EndDrawing();
    }
}

fn camera_follow_player(camera: *rl.Camera2D, player: *const Player, camera_set: *bool) void {
    const camera_set_v = camera_set.*;
    var new_camera_target = player.entity.position_center;

    if (!camera_set_v) {
        camera.target = new_camera_target;
        camera_set.* = true;
        return;
    }

    camera.target = new_camera_target;
    const camera_rect = calc_camera_rect_in_world(camera.*);
    const out_of_rect_vec = rutils.calc_rect_out_of_rect(camera_rect, Background.transform);
    camera.target = rm.Vector2Subtract(camera.target, out_of_rect_vec);
}

fn calc_camera_rect_in_world(camera: rl.Camera2D) rl.Rectangle {
    const left_top = rl.GetScreenToWorld2D(rutils.new_vector2(0, 0), camera);
    const right_bottom = rl.GetScreenToWorld2D(rutils.new_vector2(screen.width, screen.height), camera);
    return rutils.new_rect_from_vec2(left_top, right_bottom);
}

fn matrix_cast(m: rl.Matrix) rm.Matrix {
    return .{
        .m0 = m.m0,
        .m1 = m.m1,
        .m2 = m.m2,
        .m3 = m.m3,
        .m4 = m.m4,
        .m5 = m.m5,
        .m6 = m.m6,
        .m7 = m.m7,
        .m8 = m.m8,
        .m9 = m.m9,
        .m10 = m.m10,
        .m11 = m.m11,
        .m12 = m.m12,
        .m13 = m.m13,
        .m14 = m.m14,
        .m15 = m.m15,
    };
}

fn print_matrix(m: rl.Matrix) void {
    debug.print("\n{d}\t{d}\t{d}\t{d}\n", .{ m.m0, m.m4, m.m8, m.m12 });
    debug.print("{d}\t{d}\t{d}\t{d}\n", .{ m.m1, m.m5, m.m9, m.m13 });
    debug.print("{d}\t{d}\t{d}\t{d}\n", .{ m.m2, m.m6, m.m10, m.m14 });
    debug.print("{d}\t{d}\t{d}\t{d}\n", .{ m.m3, m.m7, m.m11, m.m15 });
}

test {
    std.testing.refAllDecls(@This());
}
