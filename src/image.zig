const std = @import("std");
const stbi = @cImport(@cInclude("stb_image.h"));
const lm = @import("linearmath.zig");

pub const Color = extern union {
    const Self = @This();

    r: u8,
    g: u8,
    b: u8,
    a: u8,

    pub const black = Self.rgb(0, 0, 0);
    pub const white = Self.rgb(1, 1, 1);
    pub const red = Self.rgb(1, 0, 0);
    pub const green = Self.rgb(0, 1, 0);
    pub const blue = Self.rgb(0, 0, 1);

    pub fn rgba(r: u8, g: u8, b: u8, a: u8) Self {
        return .{
            .r = r,
            .g = g,
            .b = b,
            .a = a,
        };
    }

    pub fn rgb(r: u8, g: u8, b: u8) Self {
        return .{
            .r = r,
            .g = g,
            .b = b,
            .a = 255,
        };
    }

    pub fn fromData(data: *const [4]u8) Self {
        return .{
            .r = data[0],
            .g = data[1],
            .b = data[2],
            .a = data[3],
        };
    }

    pub fn raw(self: Self) u32 {
        return (@as(u32, self.r) << 24) | 
               (@as(u32, self.g) << 16) | 
               (@as(u32, self.b) << 8)  | 
                         self.a;
    }

    pub fn toVec(self: Self) lm.Vec4 {
        return .init(
            @as(f32, @floatFromInt(self.r)) / 255.0, 
            @as(f32, @floatFromInt(self.g)) / 255.0, 
            @as(f32, @floatFromInt(self.b)) / 255.0, 
            @as(f32, @floatFromInt(self.a)) / 255.0,
        );
    }
};

pub const Image = struct {
    const Self = @This();

    data: [*]u8,
    width: u32,
    height: u32,
    channels: u32,

    pub fn init(path: [*]const u8) error{FailedToOpenImage}!Self {
        var x: c_int = 0;
        var y: c_int = 0;
        var channels: c_int = 0;

        const data = stbi.stbi_load(path, &x, &y, &channels, 4);
        if (data == null) {
            std.debug.print("Failed: {s}\n", .{stbi.stbi_failure_reason()});
            return error.FailedToOpenImage;
        }
        
        return .{
            .data = data,
            .width = @intCast(x),
            .height = @intCast(y),
            .channels = @intCast(channels),
        };
    }

    pub fn deinit(self: *const Self) void {
        stbi.stbi_image_free(self.data);
    }

    pub fn getPixel(self: Self, x: u32, y: u32) u32 {
        
    }
};
