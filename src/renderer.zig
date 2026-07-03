const std = @import("std");
const cam = @import("camera.zig");
const gl = @import("c.zig").gl;
const events = @import("events.zig");

pub const Renderer = struct {
    const Self = @This();

    camera: cam.Camera,

    pub fn init() Self {
        return .{
            .camera = .init(1280, 720),
        };
    }

    pub fn attach(self: *Self, eventman: *events.EventManager) !void {
        try eventman.addListener(.{
            .context = @ptrCast(@alignCast(self)),
            .callback = .{
                .window = resizeCallback,
            },
        });
    }

    fn resizeCallback(ctx: *anyopaque, event: events.WindowEvent) void {
        const self: *Self = @ptrCast(@alignCast(ctx));

        switch (event) {
            .resize => |e| {
                gl.glViewport(0, 0, @intCast(e.width), @intCast(e.height));
                self.camera.resize(e.width, e.height);
                std.debug.print("resized: {} {}\n", .{e.width, e.height});
            }
        }
    }
};
