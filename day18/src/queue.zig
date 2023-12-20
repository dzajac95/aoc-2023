const std = @import("std");
const mem = std.mem;

pub fn Queue(comptime T: type) type {
    return struct {
        items: []T,
        first: usize,
        last: usize,
        count: usize,
        capacity: usize,
        allocator: mem.Allocator,

        const Self = @This();
        const default_capacity: usize = 100;

        pub fn init(allocator: mem.Allocator) !Self {
            return Self{
                .items = try allocator.alloc(T, default_capacity),
                .first = 0,
                .last = 0,
                .count = 0,
                .capacity = default_capacity,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: Self) void {
            self.allocator.free(self.items);
        }

        pub fn enqueue(self: *Self, item: T) !void {
            try self.ensureCapacity(self.count + 1);
            self.items[self.last] = item;
            self.last = (self.last + 1) % self.capacity;
            self.count += 1;
        }

        pub fn ensureCapacity(self: *Self, capacity: usize) !void {
            if (self.capacity >= capacity)
                return;
            var newCapacity = self.capacity;
            while (newCapacity < capacity) {
                newCapacity +|= newCapacity / 2 + 8; // yoinked from ArrayList
            }

            var newSlice = try self.allocator.alloc(T, newCapacity);
            if (self.count > 0) {
                if (self.first < self.last) {
                    @memcpy(newSlice[0..self.count], self.items[self.first..self.last]);
                } else {
                    const midpoint = self.capacity - self.first;
                    @memcpy(newSlice[0..midpoint], self.items[self.first..]);
                    @memcpy(newSlice[midpoint..][0..self.last], self.items[0..self.last]);
                }
            }
            self.allocator.free(self.items);
            self.items = newSlice;
            self.first = 0;
            self.last = self.count;
            self.capacity = newCapacity;
        }

        pub fn dequeue(self: *Self) ?T {
            if (self.count != 0) {
                const item = self.items[self.first];
                self.first = (self.first + 1) % self.capacity;
                self.count -= 1;
                return item;
            } else {
                return null;
            }
        }
    };
}
