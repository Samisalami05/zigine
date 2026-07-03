const std = @import("std");
const glfw = @import("c.zig").glfw;
const events = @import("events.zig");
const input = @import("input.zig");
const engine = @import("root.zig");
const lm = @import("linearmath.zig");
const core = @import("core.zig");

pub const Window = struct {
    const Self = @This();

    handle: ?*glfw.struct_GLFWwindow,
    
    pub fn init(width: u32, height: u32) !Self {
        var self: Self = .{ .handle = null };
        self.handle = glfw.glfwCreateWindow(@intCast(width), @intCast(height), "zigine", null, null);
        if (self.handle == null) return error.FailedToCreateWindow;

        glfw.glfwMakeContextCurrent(self.handle);
        glfw.glfwSwapInterval(1); // Enable vsync
        
        self.setCallbacks();

        return self;
    }

    fn setCallbacks(self: *Self) void {
        _ = glfw.glfwSetKeyCallback(self.handle, keyCallback);
        _ = glfw.glfwSetMouseButtonCallback(self.handle, mouseButtonCallback);
        _ = glfw.glfwSetCursorPosCallback(self.handle, mousePosCallback);
        _ = glfw.glfwSetScrollCallback(self.handle, mouseScrollCallback);
        _ = glfw.glfwSetFramebufferSizeCallback(self.handle, framebufferSizeCallback);
    }

    pub fn size(self: Self) core.Size {
        var width: c_int = 0;
        var height: c_int = 0;
        glfw.glfwGetFramebufferSize(self.handle, &width, &height);
        return .{ .width = @intCast(width), .height = @intCast(height) };
    }

    pub fn deinit(self: *Self) void {
        glfw.glfwDestroyWindow(self.handle);
    }

    pub fn shouldClose(self: *Self) bool {
        return glfw.glfwWindowShouldClose(self.handle) != 0;
    }

    pub fn swapBuffers(self: *Self) void {
        glfw.glfwSwapBuffers(self.handle);
    }

    pub fn pollEvents(self: *Self) void {
        _ = self;
        glfw.glfwPollEvents();
    }
};

fn keyCallback(window: ?*glfw.struct_GLFWwindow, key: c_int, scancode: c_int, action: c_int, mods: c_int) callconv(.c) void {
    const event: events.KeyEvent = .{
        .action = .fromGLFW(action),
        .keyCode = .fromGLFW(key),
    };

    engine.get().eventman.publish(.{ .key = event }) catch {};

    _ = window;
    _ = scancode;
    _ = mods;

    // TODO: add mods
}

fn mouseButtonCallback(window: ?*glfw.struct_GLFWwindow, button: c_int, action: c_int, mods: c_int) callconv(.c) void {
    const event: events.MouseEvent = .{
        .button = .{
            .btn = .fromGLFW(button),
            .action = .fromGLFW(action),
        }
    };

    engine.get().eventman.publish(.{ .mouse = event }) catch {};

    _ = window;
    _ = mods;
}

fn mousePosCallback(window: ?*glfw.struct_GLFWwindow, xpos: f64, ypos: f64) callconv(.c) void {
    const event: events.MouseEvent = .{
        .move = .{
            .x = @floatCast(xpos),
            .y = @floatCast(ypos),
        },
    };

    engine.get().eventman.publish(.{.mouse = event}) catch {};

    _ = window;
}

fn mouseScrollCallback(window: ?*glfw.struct_GLFWwindow, xoffset: f64, yoffset: f64) callconv(.c) void {
    const event: events.MouseEvent = .{
        .scroll = .{
            .x = @floatCast(xoffset),
            .y = @floatCast(yoffset),
        },
    };

    engine.get().eventman.publish(.{.mouse = event}) catch {};

    _ = window;
}

fn framebufferSizeCallback(window: ?*glfw.struct_GLFWwindow, width: c_int, height: c_int) callconv(.c) void {
    const event: events.WindowEvent = .{
        .resize = .{
            .width = @intCast(width),
            .height = @intCast(height),
        },
    };

    engine.get().eventman.publish(.{ .window = event }) catch {};

    _ = window;
}




