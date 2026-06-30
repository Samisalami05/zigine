const std = @import("std");
const math = std.math;
const lm = @import("linearmath.zig");

const Camera = struct {
    const Self = @This();

    pos: lm.Vec3,
    pitch: f32,
    yaw: f32,

    fov: f32,
    width: u16,
    height: u16,

    near: f32,
    far: f32,

    pub fn init(width: u16, height: u16) Self {
        return .{
            .pos = .zero,
            .pitch = 0,
            .yaw = 0,

            .fov = 70,
            .width = width,
            .height = height,

            .near = 0.1,
            .far = 200,
        };
    }

    pub fn aspect(self: Self) f32 {
        return @as(f32, @floatFromInt(self.width)) / @as(f32, @floatFromInt(self.height));
    }

    pub fn view(self: Self) lm.Mat4 {
        const dest = self.pos.add(self.forward());
        return .lookat(self.pos, dest);
    }

    // Useful for rendering skyboxes and stuff
    pub fn viewNoTranslate(self: Self) lm.Mat4 {
        return .lookat(.zero, self.forward());
    }

    pub fn proj(self: Self) lm.Mat4 {
        return .projection(self.fov, self.aspect(), self.near, self.far);
    }

    pub fn forward(self: Self) lm.Vec3 {
        return .init(
            math.cos(self.pitch) * math.sin(self.yaw),
            math.sin(self.pitch),
            -math.cos(self.pitch) * math.cos(self.yaw)
        );
    }

    pub fn right(self: Self) lm.Vec3 {
        const f = self.forward();
        const u: lm.Vec3 = .up;
        return f.cross(u).normalized();
    }

    pub fn up(self: Self) lm.Vec3 {
        const r = self.right();
        const f = self.forward();
        return r.cross(f).normalized();
    }
};
