const std = @import("std");
const gl = @cImport(@cInclude("glad/glad.h"));

// V is vertex type
pub fn VertexArray(comptime V: type) type {
    return struct {
        const Self = @This();

        handle: c_uint,

        inline fn addAttribs(target: c_uint, obj: type) void {
            _ = target;
            const fields = std.meta.fields(obj);
            inline for (fields) |field| {
                switch (@typeInfo(field.type)) {
                    .@"struct" => {
                        std.debug.print("struct: {s}\n", .{@typeName(field.type)});
                    },
                    .array => { // TODO: clump together into one pointer
                        std.debug.print("array: {s}\n", .{@typeName(field.type)});
                    },
                    else => @compileError("Unsupported vertex attribute type"),
                }
            }
        }

        pub fn init() Self {
            var self: Self = .{
                .handle = 0,
            };
            gl.glGenVertexArrays(1, &self.handle);
            addAttribs(self.handle, V);
            return self;
        }

        pub fn deinit() void {}

        pub fn update() void {}

        pub fn bind() void {}
    };
}
