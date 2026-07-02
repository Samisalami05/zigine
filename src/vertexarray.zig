const std = @import("std");
const gl = @import("c.zig").gl;

// V is vertex type
pub fn VertexArray(comptime V: type) type {
    return struct {
        const Self = @This();

        handle: c_uint,
        attributes: usize,

        fn typeToGL(type_: type) c_uint {
            return switch (type_) {
                i8   => gl.GL_BYTE,
                i16  => gl.GL_SHORT,
                i32  => gl.GL_INT,
                u8   => gl.GL_UNSIGNED_BYTE,
                u16  => gl.GL_UNSIGNED_SHORT,
                u32  => gl.GL_UNSIGNED_INT,
                f32  => gl.GL_FLOAT,
                bool => gl.GL_BOOL,
                else => std.math.maxInt(c_uint),
            };
        }

        pub fn init() Self {
            var self: Self = .{
                .handle = 0,
                .attributes = 0,
            };
            gl.glGenVertexArrays(1, &self.handle);
            //addAttribs(self.handle, 0, V);
            return self;
        }

        pub fn deinit(self: *Self) void {
            gl.glDeleteVertexArrays(1, &self.handle);
        }

        pub fn addAttribute(self: *Self, count: u32, type_: type, normalized: bool, offset: usize) void {
            self.bind();

            gl.glVertexAttribPointer(
                @intCast(self.attributes),
                @intCast(count),
                typeToGL(type_),
                if (normalized) 1 else 0,
                @sizeOf(V),
                @ptrFromInt(offset),
            );

            gl.glEnableVertexAttribArray(@intCast(self.attributes));

            self.attributes += 1;
        }

        pub fn bind(self: *Self) void {
            gl.glBindVertexArray(self.handle);
        }
    };
}
