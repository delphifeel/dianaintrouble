// Check list for prod:
// - Coords system
// - Diff. resolutions

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
    rl.SetTargetFPS(rutils.TARGET_FPS);

    fonts.load_fonts(allocator);
    defer fonts.unload_fonts();

    var camera = rl.Camera2D{
        .offset = screen.Center,
        .target = rm.Vector2Zero(),
        .rotation = 0.0,
        .zoom = screen.camera_zoom,
    };

    var background = Background.init();
    defer background.deinit();

    var player = Player.init(rutils.calc_rect_center(Background.transform));
    defer player.deinit();

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
            camera.target = player.entity.position_center;

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
        }
        rl.EndMode2D();

        player.draw_exp_progress();
        screen.draw_fps();
        debug_info.draw(&camera);

        rl.EndDrawing();
    }
}

test {
    std.testing.refAllDecls(@This());
}
