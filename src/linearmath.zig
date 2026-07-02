const std = @import("std");

pub const Vec2 = struct {
    const Self = @This();

    x: f32,
    y: f32,

    pub const zero = Vec2{ .x = 0.0, .y = 0.0 };
    pub const one = Vec2{ .x = 1.0, .y = 1.0 };

    pub fn sqrMagnitude(self: *const Self) f32 {
        return self.x * self.x + self.y * self.y;
    }

    pub fn magnitude(self: *const Self) f32 {
        return std.math.sqrt(self.sqrMagnitude());
    }

    pub fn normalize(self: *Self) void {
        const mag = self.magnitude();

        if (mag == 0) {
            self = .zero;
            return;
        }

        self.x /= mag;
        self.y /= mag;
    }

    pub fn normalized(self: *const Self) Vec2 {       
        var v: Vec2 = self;
        v.normalize();
        return v;
    }

    pub fn dot(self: *const Self, v: Vec2) f32 {
        return self.x * v.x + self.y * v.y;
    }

    pub fn addAssign(self: *Self, v: anytype) void {
        const T = @TypeOf(v);
        if (T == Vec2) {
            self.x += v.x;
            self.y += v.y;
            return;
        }
        switch (@typeInfo(T)) {
            .float, .comptime_float, .comptime_int, .int => {
                self.x += v;
                self.y += v;
            },    
            else => @compileError("Vec2.add() not implemented for " ++ @typeName(T)),
        }
    }

    pub fn subAssign(self: *Self, v: anytype) void {
        const T = @TypeOf(v);
        if (T == Vec2) {
            self.x -= v.x;
            self.y -= v.y;
            return;
        }
        switch (@typeInfo(T)) {
            .float, .comptime_float, .comptime_int, .int => {
                self.x -= v;
                self.y -= v;
            },    
            else => @compileError("Vec2.sub() not implemented for " ++ @typeName(T)),
        }

    }
    
    pub fn mulAssign(self: *Self, v: anytype) void {
        const T = @TypeOf(v);
        if (T == Vec2) {
            self.x *= v.x;
            self.y *= v.y;
            return;
        }
        switch (@typeInfo(T)) {
            .float, .comptime_float, .comptime_int, .int => {
                self.x *= v;
                self.y *= v;
            },    
            else => @compileError("Vec2.mul() not implemented for " ++ @typeName(T)),
        }

    }

    pub fn divAssign(self: *Self, v: anytype) void {
        const T = @TypeOf(v);
        if (T == Vec2) {
            self.x = if (v.x == 0) self.x else self.x / v.x;
            self.y = if (v.y == 0) self.y else self.y / v.y;
            return;
        }
        switch (@typeInfo(T)) {
            .float, .comptime_float, .comptime_int, .int => {
                self.x = if (v == 0) self.x else self.x / v;
                self.y = if (v == 0) self.y else self.y / v;
            },    
            else => @compileError("Vec2.add() not implemented for " ++ @typeName(T)),
        }
    }

    pub fn add(self: Self, v: anytype) Self {
        const ret = self.clone();
        ret.addAssign(v);
        return ret;
    }

    pub fn sub(self: Self, v: anytype) Self {
        const ret = self.clone();
        ret.subAssign(v);
        return ret;
    }

    pub fn mul(self: Self, v: anytype) Self {
        const ret = self.clone();
        ret.mulAssign(v);
        return ret;
    }

    pub fn div(self: Self, v: anytype) Self {
        const ret = self.clone();
        ret.divAssign(v);
        return ret;
    }

    pub fn clone(self: Self) Self {
        return .{self.x, self.y};
    }
};

// TODO: make vector abstract with comptime type and count
pub const Vec3 = struct {
    const Self = @This();

    x: f32,
    y: f32,
    z: f32,

    pub fn init(x: f32, y: f32, z: f32) Self {
        return Self {
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub const zero = Vec3{ .x = 0.0, .y = 0.0, .z = 0.0 };
    pub const one = Vec3{ .x = 1.0, .y = 1.0, .z = 1.0 };

    pub const up = Vec3{ .x = 0.0, .y = 1.0, .z = 0.0 };
    pub const down = Vec3{ .x = 0.0, .y = -1.0, .z = 0.0 };
    pub const right = Vec3{ .x = 1.0, .y = 0.0, .z = 0.0 };
    pub const left = Vec3{ .x = -1.0, .y = 0.0, .z = 0.0 };
    pub const forward = Vec3{ .x = 0.0, .y = 0.0, .z = 1.0 };
    pub const backward = Vec3{ .x = 0.0, .y = 0.0, .z = -1.0 };


    pub fn xy(self: *const Self) Vec2 {
        return Vec2{ self.x, self.y };
    }

    pub fn xz(self: *const Self) Vec2 {
        return Vec2{ self.x, self.z };
    }

    pub fn yz(self: *const Self) Vec2 {
        return Vec2{ self.y, self.z };
    }

    pub fn sqrMagnitude(self: *const Self) f32 {
        return self.x * self.x + self.y * self.y + self.z * self.z;
    }

    pub fn magnitude(self: *const Self) f32 {
        return std.math.sqrt(self.sqrMagnitude());
    }

    pub fn normalize(self: *Self) void {
        const mag = self.magnitude();

        if (mag == 0) {
            self.* = .zero;
            return;
        }

        self.x /= mag;
        self.y /= mag;
        self.z /= mag;
    }

    pub fn normalized(self: *const Self) Vec3 {       
        var v: Vec3 = self.*;
        v.normalize();
        return v;
    }

    pub fn dot(self: *const Self, v: Vec3) f32 {
        return self.x * v.x + self.y * v.y + self.z * v.z;
    }

    pub fn cross(self: Self, v: Vec3) Self {
	return .init(
            self.y*v.z - self.z*v.y,
            self.z*v.x - self.x*v.z,
            self.x*v.y - self.y*v.x
        );
    }

    pub fn inverse(self: *Self) void {
        self.mulAssign(-1);
    }

    pub fn inversed(self: Self) Self {
        return .init(-self.x, -self.y, -self.z);
    }

    pub fn addAssign(self: *Self, v: anytype) void {
        const T = @TypeOf(v);
        if (T == Vec3) {
            self.x += v.x;
            self.y += v.y;
            self.z += v.z;
            return;
        }
        switch (@typeInfo(T)) {
            .float, .comptime_float, .comptime_int, .int => {
                self.x += v;
                self.y += v;
                self.z += v;
            },    
            else => @compileError("Vec3.add() not implemented for " ++ @typeName(T)),
        }
    }

    pub fn subAssign(self: *Self, v: anytype) void {
        const T = @TypeOf(v);
        if (T == Vec3) {
            self.x -= v.x;
            self.y -= v.y;
            self.z -= v.z;
            return;
        }
        switch (@typeInfo(T)) {
            .float, .comptime_float, .comptime_int, .int => {
                self.x -= v;
                self.y -= v;
                self.z -= v;
            },    
            else => @compileError("Vec3.sub() not implemented for " ++ @typeName(T)),
        }

    }
    
    pub fn mulAssign(self: *Self, v: anytype) void {
        const T = @TypeOf(v);
        if (T == Vec3) {
            self.x *= v.x;
            self.y *= v.y;
            self.z *= v.z;
            return;
        }
        switch (@typeInfo(T)) {
            .float, .comptime_float, .comptime_int, .int => {
                self.x *= v;
                self.y *= v;
                self.z *= v;
            },    
            else => @compileError("Vec3.mul() not implemented for " ++ @typeName(T)),
        }
    }

    pub fn divAssign(self: *Self, v: anytype) void {
        const T = @TypeOf(v);
        if (T == Vec3) {
            self.x = if (v.x == 0) self.x else self.x / v.x;
            self.y = if (v.y == 0) self.y else self.y / v.y;
            self.z = if (v.z == 0) self.z else self.z / v.z;
            return;
        }
        switch (@typeInfo(T)) {
            .float, .comptime_float, .comptime_int, .int => {
                self.x = if (v == 0) self.x else self.x / v;
                self.y = if (v == 0) self.y else self.y / v;
                self.z = if (v == 0) self.z else self.z / v;
            },    
            else => @compileError("Vec3.add() not implemented for " ++ @typeName(T)),
        }
    }

    pub fn add(self: Self, v: anytype) Self {
        var ret = self.clone();
        ret.addAssign(v);
        return ret;
    }

    pub fn sub(self: Self, v: anytype) Self {
        var ret = self.clone();
        ret.subAssign(v);
        return ret;
    }

    pub fn mul(self: Self, v: anytype) Self {
        var ret = self.clone();
        ret.mulAssign(v);
        return ret;
    }

    pub fn div(self: Self, v: anytype) Self {
        var ret = self.clone();
        ret.divAssign(v);
        return ret;
    }

    pub fn clone(self: Self) Self {
        return .init(self.x, self.y, self.z);
    }
};

pub const Vec4 = struct {
    const Self = @This();

    x: f32,
    y: f32,
    z: f32,
    w: f32,

    pub fn init(x: f32, y: f32, z: f32, w: f32) Self {
        return .{
            .x = x,
            .y = y,
            .z = z,
            .w = w,
        };
    }
};

pub const Mat4 = struct {
    const Self = @This();

    data: [16]f32,

    // Creates a indentity matrix
    pub fn init() Self {
        var self: Self = .{
            .data = std.mem.zeroes([16]f32),
        };

        for (0..4) |i| {
            self.setElem(i, i, 1.0);
	}

        return self;
    }

    pub fn projection(fov: f32, aspect: f32, near: f32, far: f32) Self {
        var self: Self = .{
            .data = std.mem.zeroes([16]f32),
        };

        const wow = std.math.tan(fov * 0.5 * (std.math.pi / 180.0));
	const t = wow * near;
	const b = -t;
	const r = t * aspect;
	const l = -r;

	self.data[0]  = 2 * near / (r - l);
        self.data[5]  = 2 * near / (t - b);
        self.data[8]  = (r + l) / (r - l);
        self.data[9]  = (t + b) / (t - b);
        self.data[10] = -(far + near) / (far - near);
        self.data[14] = -2 * far * near / (far - near);
        self.data[11] = -1;

        return self;
    }

    pub fn lookat(eye: Vec3, target: Vec3) Self {
	var self = init();

	const f: Vec3 = target.sub(eye).normalized();
	const r: Vec3 = f.cross(.init(0.0, 1.0, 0.0)).normalized();
	const u: Vec3 = r.cross(f);

        self.data[0] = r.x;
        self.data[1] = u.x;
        self.data[2] = -f.x;

        self.data[4] = r.y;
        self.data[5] = u.y;
        self.data[6] = -f.y;

        self.data[8] = r.z;
        self.data[9] = u.z;
        self.data[10] = -f.z;

        self.data[12] = -r.dot(eye);
        self.data[13] = -u.dot(eye);
        self.data[14] =  f.dot(eye);

	return self;
    }

    pub fn getElem(self: *Self, x: usize, y: usize) f32 {
        return self.data[x * 4 + y]; // column major (what opengl uses)
    }

    pub fn setElem(self: *Self, x: usize, y: usize, v: f32) void {
        self.data[x * 4 + y] = v;
    }

    pub fn addElem(self: *Self, x: usize, y: usize, v: f32) void {
        self.setElem(x, y, self.getElem(x, y) + v);
    }

    pub fn mul(self: Self, v: Self) Self {
	const res = init();

	for (0..4) |y| {
            for (0..4) |x| {			
                var e: f32 = 0;
                for (0..4) |i| {
                    e += self.getElem(i, y) * v.getElem(x, i);
                }
                res.setElem(x, y, e);
            }
	}

        return res;
    }

    pub fn translate(self: *Self, v: Vec3) void {
        self.addElem(3, 0, 
            self.getElem(0, 0) * v.x +
            self.getElem(1, 0) * v.y +
            self.getElem(2, 0) * v.z
        );

        self.addElem(3, 1, 
            self.getElem(0, 1) * v.x +
            self.getElem(1, 1) * v.y +
            self.getElem(2, 1) * v.z
        );

        self.addElem(3, 2, 
            self.getElem(0, 2) * v.x +
            self.getElem(1, 2) * v.y +
            self.getElem(2, 2) * v.z
        );
    }

    pub fn rotateX(a: f32) Self {
        const ret = init();

        ret.setElem(1, 1,  std.math.cos(a));
        ret.setElem(2, 1, -std.math.sin(a));
        ret.setElem(1, 2,  std.math.sin(a));
        ret.setElem(2, 2,  std.math.cos(a));

        return ret;
    }

    pub fn rotateY(a: f32) Self {
        const ret = init();

        ret.setElem(0, 0,  std.math.cos(a));
        ret.setElem(2, 0, -std.math.sin(a));
        ret.setElem(0, 2,  std.math.sin(a));
        ret.setElem(2, 2,  std.math.cos(a));

        return ret;
    }

    pub fn rotateZ(a: f32) Self {
        const ret = init();

        ret.setElem(0, 0,  std.math.cos(a));
        ret.setElem(1, 0, -std.math.sin(a));
        ret.setElem(0, 1,  std.math.sin(a));
        ret.setElem(1, 1,  std.math.cos(a));

        return ret;
    }

    pub fn rotate(self: *Self, v: Vec3) void {
        const rz = rotateX(v.z);
        const ry = rotateX(v.y);
        const rx = rotateX(v.x);

        self = self.mul(rz);
        self = self.mul(ry);
        self = self.mul(rx);
    }
};
