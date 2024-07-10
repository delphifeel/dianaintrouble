const std = @import("std");
const rl = @import("raylib.zig");
const rm = @import("raymath.zig");
const screen = @import("screen.zig");
const Background = @import("background.zig");

pub const TARGET_FPS = 120;

// if it outside background boundaries - spawn nearest pos inside background
pub fn find_nearest_rect_inside_world(src_rect: rl.Rectangle) rl.Rectangle {
    var new_transform = src_rect;
    const r2 = Background.transform;
    if (new_transform.x < r2.x) {
        new_transform.x = r2.x;
    }
    if (new_transform.y < r2.y) {
        new_transform.y = r2.y;
    }
    if (new_transform.x + new_transform.width > r2.x + r2.width) {
        new_transform.x = r2.x + r2.width - new_transform.width;
    }
    if (new_transform.y + new_transform.height > r2.y + r2.height) {
        new_transform.y = r2.y + r2.height - new_transform.height;
    }

    return new_transform;
}

pub fn rand_coord_in_range(init_pos: rl.Vector2, min: f32, max: f32) rl.Vector2 {
    const side = rl.GetRandomValue(1, 4);

    var v: f32 = 0;
    // left
    if (side == 1) {
        v = rand_f(min, max);
        const new_x = init_pos.x - v;
        v = rand_f(-max, max);
        const new_y = init_pos.y + v;
        return new_vector2(new_x, new_y);
    }
    // right
    if (side == 2) {
        v = rand_f(min, max);
        const new_x = init_pos.x + v;
        v = rand_f(-max, max);
        const new_y = init_pos.y + v;
        return new_vector2(new_x, new_y);
    }
    // top
    if (side == 3) {
        v = rand_f(-max, max);
        const new_x = init_pos.x + v;
        v = rand_f(min, max);
        const new_y = init_pos.y - v;
        return new_vector2(new_x, new_y);
    }
    // bottom
    if (side == 4) {
        v = rand_f(-max, max);
        const new_x = init_pos.x + v;
        v = rand_f(min, max);
        const new_y = init_pos.y + v;
        return new_vector2(new_x, new_y);
    }
    unreachable;
}

pub fn print_rect(rect: rl.Rectangle) void {
    std.debug.print("{d} : {d} : {d} : {d}\n", .{ rect.x, rect.y, rect.width, rect.height });
}

pub inline fn distance_by_speed(speed: f32, last_frame_time: f32) f32 {
    // d = v * t
    return speed * last_frame_time;
}

pub fn is_rect_out_of_rect(r1: rl.Rectangle, r2: rl.Rectangle) bool {
    if (r1.x < r2.x) {
        return true;
    }
    if (r1.y < r2.y) {
        return true;
    }
    if (r1.x + r1.width > r2.x + r2.width) {
        return true;
    }
    if (r1.y + r1.height > r2.y + r2.height) {
        return true;
    }

    return false;
}

pub fn move_rect(old_rect: rl.Rectangle, offset: rl.Vector2) rl.Rectangle {
    var rect = old_rect;
    rect.x += offset.x;
    rect.y += offset.y;
    return rect;
}

pub fn grow_rect_from_center(old_rect: rl.Rectangle, delta_x: f32, delta_y: f32) rl.Rectangle {
    var rect = old_rect;
    rect.width += delta_x;
    rect.height += delta_y;
    rect.x -= delta_x / 2;
    rect.y -= delta_y / 2;
    return rect;
}

pub fn change_rect_pos(rect: *rl.Rectangle, pos: rl.Vector2) void {
    rect.x = pos.x;
    rect.y = pos.y;
}

pub fn new_vector2(x: f32, y: f32) rl.Vector2 {
    return rl.Vector2{ .x = x, .y = y };
}

pub fn new_rect(x: f32, y: f32, width: f32, height: f32) rl.Rectangle {
    return rl.Rectangle{ .x = x, .y = y, .width = width, .height = height };
}

pub fn new_rect_in_center(width: f32, height: f32) rl.Rectangle {
    return new_rect(screen.Center.x - width / 2, screen.Center.y - height / 2, width, height);
}

pub fn new_rect_at_bottom(width: f32, height: f32) rl.Rectangle {
    return new_rect(screen.Center.x - width / 2, screen.Center.y * 2 - height, width, height);
}

pub fn new_rect_at_left(width: f32, height: f32) rl.Rectangle {
    return new_rect(0, screen.Center.y - height / 2, width, height);
}

pub fn new_rect_at_top(width: f32, height: f32) rl.Rectangle {
    return new_rect(screen.Center.x - width / 2, 0, width, height);
}

pub fn new_rect_at_right(width: f32, height: f32) rl.Rectangle {
    return new_rect(screen.Center.x * 2 - width, screen.Center.y - height / 2, width, height);
}

pub inline fn new_rect_with_pos(pos: rl.Vector2, width: f32, height: f32) rl.Rectangle {
    return new_rect(pos.x, pos.y, width, height);
}

pub inline fn rect_pos(rect: rl.Rectangle) rl.Vector2 {
    return new_vector2(rect.x, rect.y);
}

// pub fn CalcItemsSize(itemsCount int, itemSize float32, itemSpaceBetween float32) float32 {
// 	countFloat := float32(itemsCount)
// 	return countFloat*itemSize + (countFloat-1)*itemSpaceBetween
// }

// pub fn CalcItemPos(index int, startPos float32, itemSize float32, itemSpaceBetween float32) float32 {
// 	return startPos + float32(index)*(itemSpaceBetween+itemSize)
// }

pub fn calc_rect_center(rect: rl.Rectangle) rl.Vector2 {
    return new_vector2(rect.x + rect.width / 2, rect.y + rect.height / 2);
}

pub fn rect_with_padding(old_rect: rl.Rectangle, x_padding: f32, y_padding: f32) rl.Rectangle {
    var rect = old_rect;
    rect.x += x_padding;
    rect.width -= x_padding * 2;

    rect.y += y_padding;
    rect.height -= y_padding * 2;
    return rect;
}

// pub fn RectWithPaddingEx(rect rl.Rectangle, top float32, right float32, bottom float32, left float32) rl.Rectangle {
// 	rect.X += left
// 	rect.Width -= right + left

// 	rect.Y += top
// 	rect.Height -= top + bottom
// 	return rect
// }

test "rand value" {
    const max = 500;
    const min = 300;
    const init_pos = new_vector2(0, 0);
    var v_f: f32 = -0.01;

    var v = (max - min) * v_f;
    var new_x = init_pos.x;
    if (v < 0) {
        new_x += -min + v;
    } else {
        new_x += min + v;
    }
    v_f = 0.5;
    v = (max - min) * v_f;
    var new_y = init_pos.y;
    if (v < 0) {
        new_y += -min + v;
    } else {
        new_y += min + v;
    }

    std.debug.print("{d}:{d}", .{ new_x, new_y });
}

// NOTE: no seed for now
var seed_set = true;

fn rand_f(min: f32, max: f32) f32 {
    const min_i: i32 = @intFromFloat(min);
    const max_i: i32 = @intFromFloat(max);
    const v = rl.GetRandomValue(min_i, max_i);
    const v_f: f32 = @floatFromInt(v);
    return v_f;
}
