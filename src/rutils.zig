const rl = @import("raylib.zig");
const rm = @import("raymath.zig");
const screen = @import("screen.zig");

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
    return new_rect(0, screen.Center.y - height / 2, width, height);
}

pub fn new_rect_at_right(width: f32, height: f32) rl.Rectangle {
    return new_rect(screen.Center.x * 2 - width, screen.Center.y - height / 2, width, height);
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

// pub fn RectWithPadding(rect rl.Rectangle, xPadding float32, yPadding float32) rl.Rectangle {
// 	rect.X += xPadding
// 	rect.Width -= xPadding * 2

// 	rect.Y += yPadding
// 	rect.Height -= yPadding * 2
// 	return rect
// }

// pub fn RectWithPaddingEx(rect rl.Rectangle, top float32, right float32, bottom float32, left float32) rl.Rectangle {
// 	rect.X += left
// 	rect.Width -= right + left

// 	rect.Y += top
// 	rect.Height -= top + bottom
// 	return rect
// }
