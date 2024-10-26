const rl = @import("raylib.zig");
const Background = @import("background.zig");
const rutils = @import("rutils.zig");

// pub const width: f32 = 1920;
// pub const height: f32 = 1080;

pub const width: f32 = 1600;
pub const height: f32 = 900;
// pub const width: f32 = 1200;
// pub const height: f32 = 675;
// pub const width: f32 = 600;
// pub const height: f32 = 340;
// pub const width: f32 = 200;
// pub const height: f32 = 100;

pub const camera_zoom: f32 = width / (Background.transform.width / 2);

pub const Center = rl.Vector2{ .x = width / 2, .y = height / 2 };

pub fn init() void {
    rl.InitWindow(width, height, "Project D");
    rl.SetTargetFPS(rutils.TARGET_FPS);
}

pub fn deinit() void {
    rl.CloseWindow();
}

pub fn draw_fps() void {
    rl.DrawFPS(width - 150, 10);
}

pub fn remx(v: f32) f32 {
    return width / 100 * v;
}

pub fn remy(v: f32) f32 {
    return height / 100 * v;
}
