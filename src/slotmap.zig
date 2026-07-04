const std = @import("std");

pub fn SlotMap(comptime T: type) type {
    return struct {
        const Self = @This();

        slots: []T,
        last: u64,  // Points to the last changed slot in the slotmap
        occupied: std.DynamicBitSet,
        free: std.Deque(u64),

        pub fn init(alloc: std.mem.Allocator) !Self {
            return .{
                .slots = &.{},
                .last = 0,
                .occupied = try .initEmpty(alloc, 0),
                .free = .empty,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator().free(self.slots);
            self.free.deinit(self.allocator());
            self.occupied.deinit();
        }

        fn allocator(self: *Self) std.mem.Allocator {
            return self.occupied.allocator;
        }

        pub fn resize(self: *Self, size: usize) !void {
            self.slots = try self.allocator().realloc(self.slots, size);
            try self.occupied.resize(size, false);
            std.debug.print("resized to {}\n", .{size});
        }

        fn resizeFit(self: *Self, fit: usize) !void {
            var size: usize = self.capacity();
            while (size < fit) {
                size = if (size == 0) 4 else size * 2;
            }
            if (size == self.capacity()) return;
            try self.resize(size);
        }

        pub fn capacity(self: *Self) usize {
            return self.slots.len;
        }

        pub fn setSlot(self: *Self, slot: u64, v: T) !void {
            try self.resizeFit(slot + 1);
            self.slots[slot] = v;
            self.occupied.set(slot);

            if (slot >= self.last) {
                const diff = slot - self.last;
                for (0..diff) |i| {
                    std.debug.print("added free slot {}\n", .{i + self.last});
                    try self.free.pushBack(self.allocator(), i + self.last);
                }
                self.last = slot + 1;
            }
        }

        pub fn getSlot(self: *Self, slot: u64) ?T {
            if (!self.isOccupied(slot)) return null;
            return self.slots[slot];
        }

        pub fn unsetSlot(self: *Self, slot: u64) !void {
            if (slot >= self.capacity()) return;
            self.occupied.unset(slot);
            
            if (self.last - 1 == slot) {
                self.last -= 1;
                std.debug.print("decrementing last\n", .{});
                return;
            }

            try self.free.pushBack(self.allocator(), slot);
        }

        fn getFreeSlot(self: *Self) u64 {
            if (self.free.len > 0) {
                return self.free.popFront().?;
            }

            const freeSlot = self.last;
            self.last += 1;
            return freeSlot;
        }

        // Adds value to the first availabe slot and returns the slot number
        pub fn add(self: *Self, v: T) !u64 {
            const freeSlot = self.getFreeSlot();
            try self.setSlot(freeSlot, v);
            return freeSlot;
        }

        pub fn isOccupied(self: *Self, slot: u64) bool {
            if (slot >= self.capacity()) return false;
            return self.occupied.isSet(slot);
        }
    };
}

const expect = std.testing.expect;

test "slotmap set" {
    var slotmap: SlotMap(u32) = try .init(std.testing.allocator);
    defer slotmap.deinit();

    try slotmap.setSlot(3, 5);

    try expect(slotmap.slots[3] == 5);
    try expect(slotmap.free.len == 3);
    try expect(slotmap.last == 4);
    try expect(slotmap.occupied.isSet(3));
}
