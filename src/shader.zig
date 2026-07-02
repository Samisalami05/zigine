const std = @import("std");
const gl = @import("c.zig").gl;
const engine = @import("root.zig");
const lm = @import("linearmath.zig");

pub const ShaderError = error {
    FailedToCompile,
    FailedToAssemble,
    InvalidModule,
};

pub const ShaderType = enum {
    Vertex,
    Fragment,
};

pub const ShaderModule = struct {
    const Self = @This();

    handle: c_uint,
    type: ShaderType,

    fn glTypeConv(type_: ShaderType) c_uint {
        return switch (type_) {
            ShaderType.Fragment => gl.GL_FRAGMENT_SHADER,
            ShaderType.Vertex   => gl.GL_VERTEX_SHADER,
        };
    }

    pub fn init(path: []const u8, type_: ShaderType) !Self {

        const source = try engine.fm.readEntireFile(path);
        defer engine.allocator().free(source);

        return try initRaw(source, type_);
    }

    pub fn initRaw(source: []const u8, type_: ShaderType) !Self {
        var self: Self = .{
            .handle = gl.glCreateShader(glTypeConv(type_)),
            .type = type_,
        };

        gl.glShaderSource(self.handle, 1, &source.ptr, null);
        try self.compile();

        return self;
    }

    pub fn deinit(self: *Self) void {
        gl.glDeleteShader(self.handle);
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
            return error.FailedToCompile;
        }
    }
};

pub const Shader = struct {
    const Self = @This();

    handle: c_uint,
    modules: std.ArrayList(ShaderModule),
    assembled: bool,
    
    pub fn init() Self {
        return Self {
            .handle = gl.glCreateProgram(),
            .modules = .empty,
            .assembled = false,
        };
    }

    pub fn deinit(self: *Self) void {
        self.disassemble();
        gl.glDeleteProgram(self.handle);
        self.modules.deinit(engine.allocator());
        self.assembled = false;
    }

    pub fn addModule(self: *Self, module: ShaderModule) (ShaderError || std.mem.Allocator.Error)!void {
        if (gl.glIsShader(module.handle) == 0) return error.InvalidModule;
        try self.modules.append(engine.allocator(), module);
    }

    pub fn assemble(self: *Self) !void {
        for (self.modules.items) |module| {
            gl.glAttachShader(self.handle, module.handle);
        }
        gl.glLinkProgram(self.handle);
        
        var success: c_int = undefined;
        gl.glGetProgramiv(self.handle, gl.GL_LINK_STATUS, &success);

        if (success == 0) {
            var msg: [512]u8 = undefined;
            var len: c_int = undefined;
            gl.glGetProgramInfoLog(self.handle, 512, &len, &msg);
            std.debug.print("Failed to link program {}\n{s}\n", .{self.handle, msg[0..@intCast(len)]});
            return error.FailedToLinkProgram;
        }
        self.assembled = true;
    }

    pub fn setI32(self: *Self, name: []const u8, v: i32) void {
        const loc = gl.glGetUniformLocation(self.handle, name.ptr);
        gl.glUniform1i(loc, v);
    }
    
    pub fn setU32(self: *Self, name: []const u8, v: u32) void {
        const loc = gl.glGetUniformLocation(self.handle, name.ptr);
        gl.glUniform1ui(loc, v);
    }


    pub fn setF32(self: *Self, name: []const u8, v: f32) void {
        const loc = gl.glGetUniformLocation(self.handle, name.ptr);
        gl.glUniform1f(loc, v);
    }

    pub fn setF64(self: *Self, name: []const u8, v: f64) void {
        const loc = gl.glGetUniformLocation(self.handle, name.ptr);
        gl.glUniform1d(loc, v);
    }

    pub fn setMat4(self: *Self, name: []const u8, v: lm.Mat4) void {
        const loc = gl.glGetUniformLocation(self.handle, name.ptr);
        gl.glUniformMatrix4fv(loc, 1, gl.GL_FALSE, &v.data);
    }

    pub fn disassemble(self: *Self) void {
        if (!self.assembled) return;
        for (self.modules.items) |*module| {
            module.deinit();
        }
        self.modules.clearRetainingCapacity();
        self.assembled = false;
    }

    pub fn isAssembled(self: *Self) bool {
        return self.assembled;
    }

    pub fn bind(self: *Self) void {
        gl.glUseProgram(self.handle);
    }
};
