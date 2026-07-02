const std = @import("std");
const engine = @import("root.zig");
const input = @import("input.zig");

pub const KeyEvent = struct {
    keyCode: input.Key,
    action: input.InputAction,
};

pub const MouseButtonEvent = struct {
    btn: input.MouseButton,
    action: input.InputAction,
};

pub const MouseEvent = union(enum) {
    button: MouseButtonEvent,
    // move: TODO move event
};

pub const WindowEvent = enum {
    resize,
};

pub const Event = union(enum) {
    key: KeyEvent,
    mouse: MouseEvent,
    window: WindowEvent,
    // render: RenderEvent,
};

pub const Listener = struct {
    context: *anyopaque,
    callback: *const fn (*anyopaque, Event) void,
};

pub const EventManager = struct {
    const Self = @This();

    events: std.Deque(Event),
    listeners: std.ArrayList(Listener),

    pub fn init() Self {
        return .{
            .events = .empty,
            .listeners = .empty,
        };
    }

    pub fn deinit(self: *Self) void {
        self.events.deinit(engine.allocator());
        self.listeners.deinit(engine.allocator());
    }

    pub fn publish(self: *Self, e: Event) !void {
        try self.events.pushBack(engine.allocator(), e);
    }

    // Polls all events on each event listener
    pub fn poll(self: *Self) !void {
        while (self.events.len > 0) {
            const event: Event = self.events.popFront() orelse continue;
            for (self.listeners.items) |listener| {
                listener.callback(listener.context, event);
            }
        }
    }

    pub fn addListener(self: *Self, listener: Listener) !void {
        try self.listeners.append(engine.allocator(), listener);
    }
};
