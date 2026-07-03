const std = @import("std");
const engine = @import("root.zig");

pub const Entity = struct {
    id: u64,

    pub const invalid = std.math.maxInt(u64);
};

pub fn SlotMap(comptime T: type) type {
    return struct {
        const Self = @This();

        slots: std.ArrayList(T),
        occupied: std.DynamicBitSet,

        pub fn init() Self {
            return .{
                .slots = .empty,
                .occupied = .initEmpty(engine.allocator(), 0),
            };
        }

        pub fn setSlot(self: *Self, slot: u64, v: T) void {
            if (slot >= self.slots.count()) {
                const newSize = if (self.slots.capacity() == 0) 4 else self.slots.capacity() * 2;
                self.slots.resize(engine.allocator(), newSize);
                self.slots.expandToCapacity();
                self.occupied.resize(newSize, false);
            }

            self.slots.items[slot] = v;
            self.occupied.set(slot);
        }

        pub fn getSlot(self: *Self, slot: u64) ?T {
            if (!self.isOccupied(slot)) return null;
            return self.slots.items[slot];
        }

        pub fn isOccupied(self: *Self, slot: u64) bool {
            if (slot >= self.occupied.capacity()) return false;
            return self.occupied.isSet(slot);
        }
    };
}

pub const EntitySlot = struct {
};

pub const Ecs = struct {
    const Self = @This();

    count: u64,
    freeIds: std.Deque(u64),

    pub fn createEntity(self: *Self) Entity {
        const id: u64 = if (self.freeIds.len > 0) self.freeIds.popFront() else self.count;
        self.count += 1;

        return .{ .id = id };
    }

    pub fn destroyEntity(self: *Self, e: Entity) void {
        self.freeIds.pushBack(engine.allocator(), e.id);
    }

    pub fn exists(self: *Self, e: Entity) bool {
        
    }
};
