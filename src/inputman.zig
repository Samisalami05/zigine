const std = @import("std");
const glfw = @cImport(@cInclude("GLFW/glfw3.h"));

pub const Key = @import("keys.zig").Key;

pub fn BitSet(comptime size: usize) type { return std.StaticBitSet(size); }

pub const InputManager = struct {
    const Self = @This();

    currKeys: BitSet(Key.count()),
    prevKeys: BitSet(Key.count()),

    pub fn init() Self {
        return .{
            .currKeys = .empty,
            .prevKeys = .empty,
        };
    }

    pub fn isKeyDown(self: Self, key: Key) bool {
        return self.currKeys.isSet(@intFromEnum(key));
    }

    pub fn keyCallback(window: ?*glfw.struct_GLFWwindow, key: c_int, scancode: c_int, action: c_int, mods: c_int) callconv(.c) void {
        const index = @intFromEnum(Key.fromGLFW(key));
        
        _ = window;
        _ = scancode;
        _ = mods;
        _ = action;
        _ = index;

    }
};
