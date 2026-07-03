const std = @import("std");
const lm = @import("linearmath.zig");

pub const Size = struct {
    const Self = @This();

    width: u32,
    height: u32,

    pub fn toIVec2(self: Self) lm.IVec2 {
        return .{ 
            .x = @intCast(self.width),
            .y = @intCast(self.height),
        };
    }
};

pub const Rect = struct {
    const Self = @This();

    x: f32,
    y: f32,
    width: f32,
    height: f32,

    pub fn pos(self: Self) lm.Vec2 {
        return .{
            .x = self.x,
            .y = self.y,
        };
    }

    pub fn center(self: Self) lm.Vec2 {
        return .{
            .x = self.x + self.width / 2,
            .y = self.y + self.height / 2,
        };
    }

    pub fn size(self: Self) lm.Vec2 {
        return .{
            .x = self.width,
            .y = self.height,
        };
    }
};
