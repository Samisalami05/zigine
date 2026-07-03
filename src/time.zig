const std = @import("std");
const glfw = @import("c.zig").glfw;
const engine = @import("root.zig");

pub fn time() f64 {
    return engine.timeman().curr;
}

pub fn deltaTime() f64 {
    return engine.timeman().delta;
}

pub const TimeManager = struct {
    const Self = @This();

    last: f64,
    curr: f64,
    delta: f64,

    pub fn init() Self {
        return .{
            .last = glfw.glfwGetTime(),
            .curr = glfw.glfwGetTime(),
            .delta = 0,
        };
    }

    // Should be called at the beginning of the frame
    pub fn update(self: *Self) void {
        self.last = self.curr;
        self.curr = glfw.glfwGetTime();
        self.delta = self.curr - self.last;
    }
};

