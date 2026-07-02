const std = @import("std");
const gl = @cImport(@cInclude("glad/glad.h"));

const Image = @import("image.zig").Image;
const Color = @import("image.zig").Color;

pub const TextureFormat = enum {
    const Self = @This();

    depth,
    depthStencil,
    r,
    rg,
    rgb,
    rgba,

    pub fn fromImg(img: Image) Self {
        return switch (img.channels) {
            1    => .r,
            2    => .rg,
            3    => .rgb,
            4    => .rgba,
            else => .rgba,
        };
    }

    pub fn toGL(self: Self) gl.GLint {
        return switch (self) {
            .r            => gl.GL_RED,
            .rg           => gl.GL_RG,
            .rgb          => gl.GL_RGB,
            .rgba         => gl.GL_RGBA,
            .depth        => gl.GL_DEPTH_COMPONENT,
            .depthStencil => gl.GL_DEPTH_STENCIL,
        };
    }
};

pub const TextureWrapping = enum {
    const Self = @This();

    repeat,
    mirroredRepeat,
    clampToEdge,
    clampToBorder,

    pub fn toGL(self: Self) c_int {
        return switch (self) {
            .repeat         => gl.GL_REPEAT,
            .mirroredRepeat => gl.GL_MIRRORED_REPEAT,
            .clampToEdge    => gl.GL_CLAMP_TO_EDGE,
            .clampToBorder  => gl.GL_CLAMP_TO_BORDER
        };
    }
};

pub const TextureFiltering = enum {
    const Self = @This();
    
    nearest,
    linear,
    nearestMipmapNearest, // Takes the nearest mipmap
    linearMipmapNearest,  // Takes the nearest mipmap
    nearestMipmapLinear,  // Linearly interpolates between the two mipmaps
    linearMipmapLinear,   // Linearly interpolates between the two mipmaps

    pub fn toGL(self: Self) c_int {
        return switch (self) {
            .nearest              => gl.GL_NEAREST,
            .linear               => gl.GL_LINEAR,
            .nearestMipmapNearest => gl.GL_NEAREST_MIPMAP_NEAREST,
            .linearMipmapNearest  => gl.GL_LINEAR_MIPMAP_NEAREST,
            .nearestMipmapLinear  => gl.GL_NEAREST_MIPMAP_LINEAR,
            .linearMipmapLinear   => gl.GL_LINEAR_MIPMAP_LINEAR,
        };
    }
};

pub const TextureOptions = struct {
    const Self = @This();

    format: TextureFormat,
    wrapX: TextureWrapping,
    wrapY: TextureWrapping,
    //wrapZ: TextureWrapping, // TODO: add z axis for 3D textures
    filterMin: TextureFiltering, // Used when minimizing
    filterMag: TextureFiltering, // Used when magnifying
    
    pub const default: Self = .{
        .format = .rgba,
        .wrapX = .repeat,
        .wrapY = .repeat,
        .filterMin = .linear,
        .filterMag = .linear,
    };

    pub fn apply(self: Self, target: c_uint, handle: c_uint) void {
        gl.glBindTexture(target, handle);
        gl.glTexParameteri(target, gl.GL_TEXTURE_WRAP_S, self.wrapX.toGL());	
        gl.glTexParameteri(target, gl.GL_TEXTURE_WRAP_T, self.wrapY.toGL());
        //gl.glTexParameteri(target, gl.GL_TEXTURE_WRAP_R, gl.GL_REPEAT); // 3D
        gl.glTexParameteri(target, gl.GL_TEXTURE_MIN_FILTER, self.filterMin.toGL());
        gl.glTexParameteri(target, gl.GL_TEXTURE_MAG_FILTER, self.filterMag.toGL());
    }
};

pub const Texture2D = struct {
    const Self = @This();

    handle: c_uint,
    options: TextureOptions,
    width: u32,
    height: u32,

    pub fn init(path: [*]const u8) !Self {
        const img: Image = try .init(path);
        defer img.deinit();
        return fromImg(img);
    }

    pub fn fromImg(img: Image) Self {
        var options: TextureOptions = .default;
        options.format = .fromImg(img);
        return fromRaw(img.data, img.width, img.height, options);
    }

    pub fn fromRaw(data: [*]const u8, w: u32, h: u32, options: TextureOptions) Self {
        var self: Self = .{
            .handle = 0,
            .options = options,
            .width = 0,
            .height = 0,
        };
        gl.glGenTextures(1, &self.handle);
        gl.glBindTexture(gl.GL_TEXTURE_2D, self.handle);

        options.apply(gl.GL_TEXTURE_2D, self.handle);

        gl.glTexImage2D(gl.GL_TEXTURE_2D, 0, options.format.toGL(), @intCast(w), @intCast(h), 0, @intCast(options.format.toGL()), gl.GL_UNSIGNED_BYTE, data);
        gl.glGenerateMipmap(gl.GL_TEXTURE_2D);
        return self;
    }

    pub fn updateOptions(self: Self) void {
        self.options.apply(gl.GL_TEXTURE_2D, self.handle);
    }

    pub fn deinit(self: Self) void {
        gl.glDeleteTextures(1, &self.handle);
    }

    pub fn bind(self: Self, unit: u32) void {
        var max: c_int = 0;
        gl.glGetIntegerv(gl.GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, &max);
        if (unit >= @as(u32, @intCast(max))) {
            std.debug.print("Error: Cant bind texture to unit {}: There are only {} units availabe\n", .{unit, max});
            return;
        }
        gl.glActiveTexture(@as(c_uint, @intCast(gl.GL_TEXTURE0 + @as(c_int, @intCast(unit)))));
        gl.glBindTexture(gl.GL_TEXTURE_2D, self.handle);
    }
};  
