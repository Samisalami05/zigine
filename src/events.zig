const std = @import("std");
const engine = @import("root.zig");
const input = @import("input.zig");
const glfw = @import("c.zig").glfw;
const Window = @import("window.zig").Window;

pub const KeyEvent = struct {
    keyCode: input.Key,
    action: input.InputAction,
};

pub const MouseButtonEvent = struct {
    btn: input.MouseButton,
    action: input.InputAction,
};

pub const MouseMoveEvent = struct {
    x: f32,
    y: f32,
};

pub const MouseScrollEvent = struct {
    x: f32,
    y: f32,
};

pub const MouseEvent = union(enum) {
    button: MouseButtonEvent,
    move: MouseMoveEvent,
    scroll: MouseScrollEvent,
};

pub const WindowResizeEvent = struct {
    width: u32,
    height: u32,
};

pub const WindowEvent = union(enum) {
    resize: WindowResizeEvent,
    // move: WindowMoveEvent,
};

pub const Event = union(enum) {
    key: KeyEvent,
    mouse: MouseEvent,
    window: WindowEvent,
    // render: RenderEvent,
};

pub const Listener = struct {
    context: *anyopaque,
    callback: union(enum) {
        event: *const fn (*anyopaque, Event) void,
        key: *const fn (*anyopaque, KeyEvent) void,
        mouse: *const fn (*anyopaque, MouseEvent) void,
        window: *const fn (*anyopaque, WindowEvent) void,
    },
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
                callListener(listener, event);
            }
        }
    }

    fn callListener(l: Listener, e: Event) void {
        switch (l.callback) {
            .event => |callback| callback(l.context, e),
            .key => |callback| {
                switch (e) {
                    .key => |event| callback(l.context, event),
                    else => {}
                }
            },
            .mouse => |callback| {
                switch (e) {
                    .mouse => |event| callback(l.context, event),
                    else => {}
                }
            },
            .window => |callback| {
                switch (e) {
                    .window => |event| callback(l.context, event),
                    else => {}
                }
            },
        }
    }

    pub fn addListener(self: *Self, listener: Listener) !void {
        try self.listeners.append(engine.allocator(), listener);
    }
};
