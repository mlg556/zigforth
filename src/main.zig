const std = @import("std");

pub fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();

        list: std.ArrayList(T) = undefined,

        pub fn init(self: *Self, allocator: std.mem.Allocator) void {
            self.list = std.ArrayList(T).init(allocator);
        }

        pub fn deinit(self: *Self) void {
            self.list.deinit();
        }

        pub fn size(self: *Self) usize {
            return self.list.items.len;
        }

        pub fn isEmpty(self: *Self) bool {
            return self.size() == 0;
        }

        pub fn peek(self: *Self) T {
            return self.list.getLastOrNull();
        }

        pub fn push(self: *Self, x: T) !void {
            try self.list.append(x);
        }

        pub fn pop(self: *Self) ?T {
            return self.list.popOrNull();
        }
    };
}
pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const allocator: std.mem.Allocator = init: {
        // use an array as the "heap"
        var buffer: [1024]u8 = undefined;
        var fba = std.heap.FixedBufferAllocator.init(&buffer);
        break :init fba.allocator();
    };

    // dict
    // a dict of String -> String
    // var dict = std.StringHashMap([]const u8).init(allocator);
    // try dict.put("a", "1");
    // //var val = dict.get("b") orelse "NOTFOUND";
    // var val = dict.get("b");
    // if (val) |v| {
    //     try stdout.print("found: {s} \n", .{v});
    // } else {
    //     try stdout.print("not found", .{});
    // }

    var stack = Stack(i32){};
    stack.init(allocator);
    defer stack.deinit();

    // try stack.push(1);
    // try stack.push(3);

    var x = stack.pop();
    _ = x;

    try stdout.print("{?:}", .{stack.list});

    // for (stack.list.items) |item| {
    //     try stdout.print("{} ", .{item});
    // }

    // try stdout.print("{s}", stack.stack.?);
    //stdout.print("not found", .{});

}
