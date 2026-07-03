const std = @import("std");
const glfw = @import("c.zig").glfw;

const input = @import("input.zig");
const events = @import("events.zig");
const engine = @import("root.zig");

pub const InputManager = struct {
    const Self = @This();

    currKeys: std.StaticBitSet(input.Key.count()),
    prevKeys: std.StaticBitSet(input.Key.count()),

    pub fn init() !Self {
        const self: Self = .{
            .currKeys = .empty,
            .prevKeys = .empty,
        };

        return self;
    }

    pub fn attach(self: *Self, eventman: *events.EventManager) !void {
        try eventman.addListener(.{
            .context = @ptrCast(@alignCast(self)),
            .callback = .{
                .key = keyCallback,
            },
        });
    }

    // Should be called at the end of the frame but before event polling
    pub fn update(self: *Self) void {
        self.prevKeys = self.currKeys;
    }

    fn keyCallback(ctx: *anyopaque, event: events.KeyEvent) void {
        var self: *Self = @ptrCast(@alignCast(ctx));
        if (event.action == .repeat) return;

        const index = @intFromEnum(event.keyCode);
        self.currKeys.setValue(index, event.action == .down);
    }

    pub fn isKeyDown(self: *Self, key: input.Key) bool {
        const state = self.currKeys.isSet(@intFromEnum(key));
        return state;
    }

    pub fn isKeyPressed(self: *Self, key: input.Key) bool {
        const index = @intFromEnum(key);
        return self.currKeys.isSet(index) and !self.prevKeys.isSet(index);
    }

    pub fn isKeyReleased(self: *Self, key: input.Key) bool {
        const index = @intFromEnum(key);
        return !self.currKeys.isSet(index) and self.prevKeys.isSet(index);
    }
};
