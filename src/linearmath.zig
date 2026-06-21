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

    pub fn add(self: *Self, v: anytype) void {
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

    pub fn sub(self: *Self, v: anytype) void {
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
    
    pub fn mul(self: *Self, v: anytype) void {
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

    pub fn div(self: *Self, v: anytype) void {
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

};

// TODO: make vector abstract with comptime type and count
pub const Vec3 = struct {
    const Self = @This();

    x: f32,
    y: f32,
    z: f32,

    pub const zero = Vec3{ .x = 0.0, .y = 0.0, .z = 0.0 };
    pub const one = Vec3{ .x = 1.0, .y = 1.0, .z = 1.0 };

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
            self = .zero;
            return;
        }

        self.x /= mag;
        self.y /= mag;
        self.z /= mag;
    }

    pub fn normalized(self: *const Self) Vec3 {       
        var v: Vec3 = self;
        v.normalize();
        return v;
    }

    pub fn dot(self: *const Self, v: Vec3) f32 {
        return self.x * v.x + self.y * v.y + self.z * v.z;
    }

    pub fn add(self: *Self, v: anytype) void {
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

    pub fn sub(self: *Self, v: anytype) void {
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
    
    pub fn mul(self: *Self, v: anytype) void {
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

    pub fn div(self: *Self, v: anytype) void {
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
};
