const std = @import("std");
const fmt = std.fmt;

const STACK_CAPACITY = 1024;
const LINE_BUF_SIZE = 64;
const ALLOC_BUF_SIZE = 1024;

const Word = i32;

const Err = error{
    STACK_OVERFLOW,
    STACK_UNDERFLOW,
    UNKNOWN_WORD,
};

const Stack = struct {
    stack: [STACK_CAPACITY]Word = undefined,
    stack_size: usize = 0,

    pub fn push(self: *Stack, operand: Word) !void {
        if (self.stack_size >= STACK_CAPACITY)
            return Err.STACK_OVERFLOW;

        self.stack[self.stack_size] = operand;
        self.stack_size += 1;
    }

    pub fn pop(self: *Stack) !Word {
        if (self.stack_size == 0)
            return Err.STACK_UNDERFLOW;

        self.stack_size -= 1;
        return self.stack[self.stack_size];
    }

    pub fn show(self: Stack, out: anytype) !void {
        try out.print("Stack: [", .{});

        for (0..self.stack_size) |i| {
            try out.print("{d} ", .{self.stack[i]});
        }

        try out.print("]", .{});
    }
};

// taken from https://ziglearn.org/chapter-2/#readers-and-writers
fn nextLine(reader: anytype, buffer: []u8) !?[]const u8 {
    var line = (try reader.readUntilDelimiterOrEof(
        buffer,
        '\n',
    )) orelse return null;
    // trim annoying windows-only carriage return character
    if (@import("builtin").os.tag == .windows) {
        return std.mem.trimRight(u8, line, "\r");
    } else {
        return line;
    }
}

fn processToken(token: []const u8) !void {
    // try to parse integer
    if (fmt.parseInt(Word, token, 0)) |num| {
        std.debug.print("{d}\n", .{num});
    } else |err| {
        return err;
    }

    // std.debug.print("{d}\n", .{ret});
}

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

pub fn main() !void {
    const stdin = std.io.getStdIn();
    const stdout = std.io.getStdOut();
    const writer = stdout.writer();

    var stack = Stack{};
    _ = stack;
    var line_buf: [LINE_BUF_SIZE]u8 = undefined;

    const allocator: std.mem.Allocator = init: {
        // use an array as the "heap"
        var buffer: [ALLOC_BUF_SIZE]u8 = undefined;
        var fba = std.heap.FixedBufferAllocator.init(&buffer);
        break :init fba.allocator();
    };

    var dict = std.StringHashMap([]const u8).init(allocator);
    _ = dict;

    while (true) {
        try writer.print(">> ", .{});
        const line = (try nextLine(stdin.reader(), &line_buf)).?;
        var tokens = std.mem.tokenizeScalar(u8, line, ' ');
        var i: u8 = 0;

        while (tokens.next()) |token| {
            const ret = processToken(token);

            // check if void before printing?
            try writer.print("{!}\n", .{ret});

            i += 1;
        }
    }
}

test "test" {}
