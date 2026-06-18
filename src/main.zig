const std = @import("std");
const engine = @import("opengl_zig");


pub fn main(init: std.process.Init) !void {
    engine.init(init);
    try engine.run();
}
