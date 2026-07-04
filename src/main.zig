const std = @import("std");
const engine = @import("opengl_zig");

pub const Transform = struct {
    pos: u32 = 0,
    size: u32 = 0,
    rot: u32 = 0,
};

const Component = struct {
    size: usize,
};

pub fn main(init: std.process.Init) !void {
    var map = std.StringHashMap(Component).init(init.gpa);
    defer map.deinit();

    const name = @typeName(Transform);
    const size = @sizeOf(Transform);

    try map.put(name, .{.size = size});

    //try engine.init(init);
    //defer engine.get().deinit();
    //try engine.run();
}
