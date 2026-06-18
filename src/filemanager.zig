const std = @import("std");
const engine = @import("root.zig");

// NOTE: returned string needs to be freed after use
pub fn readEntireFile(path: []const u8) ![]u8 {
    const io = engine.io();
    const file = try std.Io.Dir.cwd().openFile(io, path, .{});
    defer file.close(io);

    var reader = file.reader(io, &.{});
    return try reader.interface.allocRemaining(engine.allocator(), .limited(1024 * 256));
}
