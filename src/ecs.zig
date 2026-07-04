const std = @import("std");
const engine = @import("root.zig");
const SlotMap = @import("slotmap.zig").SlotMap;

pub const Entity = struct {
    id: u64,

    pub const invalid = std.math.maxInt(u64);
};

pub const EntitySlot = struct {
};

pub const Ecs = struct {
    const Self = @This();

    entities: SlotMap(EntitySlot),

    pub fn createEntity(self: *Self) Entity {
        const id: u64 = if (self.freeIds.len > 0) self.freeIds.popFront() else self.count;
        self.count += 1;

        return .{ .id = id };
    }

    pub fn destroyEntity(self: *Self, e: Entity) void {
        self.freeIds.pushBack(engine.allocator(), e.id);
    }

    fn component(comptime T: type) Component {
        
    }

    pub fn registerComponent(comptime T: type) void {

    }

    pub fn addComponent(comptime T: type, e: Entity) *T {

    }

    pub fn getComponent(comptime T: type, e: Entity) *T {
        
    }

    //pub fn exists(self: *Self, e: Entity) bool {}
};

pub const Transform = struct {
    pos: u32 = 0,
    size: u32 = 0,
    rot: u32 = 0,
};


pub const Component = struct {
    size: usize,
    onStart: *const fn(*anyopaque) void,
    onUpdate: *const fn(*anyopaque) void,
    onDestroy: *const fn(*anyopaque) void,
};
