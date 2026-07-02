const std = @import("std");
const glfw = @import("c.zig").glfw;


const input = @import("input.zig");
const events = @import("events.zig");
const engine = @import("root.zig");

pub fn BitSet(comptime size: usize) type { return std.StaticBitSet(size); }

pub const InputManager = struct {
    const Self = @This();

    currKeys: BitSet(input.Key.count()),
    prevKeys: BitSet(input.Key.count()),

    pub fn init() Self {
        return .{
            .currKeys = .empty,
            .prevKeys = .empty,
        };
    }

    pub fn isKeyDown(self: Self, key: input.Key) bool {
        return self.currKeys.isSet(@intFromEnum(key));
    }

    pub fn keyCallback(win: ?*glfw.struct_GLFWwindow, key: c_int, scancode: c_int, action: c_int, mods: c_int) callconv(.c) void {
        const event: events.KeyEvent = .{
            .action = .fromGLFW(action),
            .keyCode = .fromGLFW(key),
        };

        std.debug.print("{s} {s}\n", .{
            std.enums.tagName(input.InputAction, event.action) orelse return,
            std.enums.tagName(input.Key, event.keyCode) orelse return}
        );

        engine.get().eventman.publish(.{ .key = event }) catch {};

        _ = win;
        _ = scancode;
        _ = mods;

        // TODO: add mods
    }

    pub fn mouseButtonCallback(window: ?*glfw.struct_GLFWwindow, button: c_int, action: c_int, mods: c_int) callconv(.c) void {
        const event: events.MouseEvent = .{
            .button = .{
                .btn = .fromGLFW(button),
                .action = .fromGLFW(action),
            }
        };

        std.debug.print("{s} {s}\n", .{
            std.enums.tagName(input.InputAction, event.button.action) orelse return,
            std.enums.tagName(input.MouseButton, event.button.btn) orelse return}
        );

        engine.get().eventman.publish(.{ .mouse = event }) catch {};

        _ = window;
        _ = mods;
        
    }
};
