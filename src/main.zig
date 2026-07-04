const std = @import("std");
const engine = @import("opengl_zig");

pub const Transform = struct {
    const Self = @This();

    pos: u32 = 0,
    size: u32 = 0,
    rot: u32 = 0,

    pub fn start(self: *Self) void {
        self.pos = 3;
    }

    pub fn update() void {

    }
};

const Component = struct {
    const Self = @This();

    size: usize,
    start: ?*const fn(*anyopaque) void,


    pub fn init(comptime T: type) Self {
        var self: Self = .{
            .size = @sizeOf(T),
            .start = null,
        };

        if (@hasDecl(T, "start")) {
            self.start = struct {
                fn call(ctx: *anyopaque) void {
                    const obj: *T = @ptrCast(@alignCast(ctx));
                    obj.start();
                }
            }.call;
        }

        return self;
    }
};

const ComponentStorage = struct {
    const Self = @This();

    map: std.StringHashMap(Component),

    pub fn init(alloc: std.mem.Allocator) Self {
        return .{
            .map = .init(alloc),
        };
    }

    pub fn deinit(self: *Self) void {
        self.map.deinit();
    }

    pub fn registerComponent(self: *Self, comptime T: type) !void {
        if (self.map.contains(@typeName(T))) {
            return error.ComponentAlreadyRegistered;
        }

        const comp: Component = .init(T);


        try self.map.put(@typeName(T), comp);
    }

    pub fn addComponent(self: *Self, comptime T: type) *T {
        
    }
};

pub fn main(init: std.process.Init) !void {
    var storage: ComponentStorage = .init(init.gpa);
    defer storage.deinit();

    try storage.registerComponent(Transform);

    var t: Transform = .{};

    var iter = storage.map.iterator();
    while (iter.next()) |comp| {
        if (comp.value_ptr.start != null) {
            comp.value_ptr.start.?(@ptrCast(&t));
        }
        std.debug.print("{}\n", .{comp.value_ptr.size});
    }

    std.debug.print("{}\n", .{t.pos});

    //try engine.init(init);
    //defer engine.get().deinit();
    //try engine.run();
}
