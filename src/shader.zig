const std = @import("std");
const gl = @cImport(@cInclude("glad/glad.h"));
const engine = @import("root.zig");

pub const ShaderError = error {
    CompilationFailed,
};

pub const ShaderModuleType = enum {
    Vertex,
    Fragment,
};

pub const ShaderModule = struct {
    const Self = @This();

    handle: c_uint,
    type: ShaderModuleType,

    pub fn init(path: []const u8, typee: ShaderModuleType) !Self {
        const self: Self = .{
            .handle = gl.glCreateShader(gl.GL_VERTEX_SHADER),
            .type = typee,
        };

        const io = try engine.io();
        const allocator = try engine.allocator();

        const file = try std.Io.Dir.cwd().openFile(io, "shader.vert", .{});
        defer file.close(io);

        const reader = file.reader(io, &.{});
        const contents = try reader.interface.allocRemaining(allocator, .limited(1234));

        const source = try file.readToEndAlloc(allocator, 1024 * 1024);
        defer allocator.free(source);
        
       // gl.glShaderSource(vert, 1, &vert_src.ptr, null);

        return self;
    }

    fn compile(self: *Self) ShaderError!void {
        gl.glCompileShader(self.handle);
        var success: c_int = undefined;
        gl.glGetShaderiv(self.handle, gl.GL_COMPILE_STATUS, &success);

        if (success == 0) {
            var msg: [512]u8 = undefined;
            var len: c_int = undefined;
            gl.glGetShaderInfoLog(self.handle, 512, &len, &msg);
            std.debug.print("Failed to compile shader\n{s}\n", .{msg[0..@intCast(len)]});
            return error.FailedToCompileShader;
        }
    }
};

pub const Shader = struct {
    
};
