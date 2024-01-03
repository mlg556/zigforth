const std = @import("std");

const STACK_CAPACITY = 1024;
const LINE_BUF_SIZE = 64;
const Word = i64;

const Err = error{
    STACK_OVERFLOW,
    STACK_UNDERFLOW,
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

pub fn main() !void {
    const stdin = std.io.getStdIn();
    const stdout = std.io.getStdOut();
    const writer = stdout.writer();

    var stack = Stack{};
    _ = stack;
    var line_buf: [LINE_BUF_SIZE]u8 = undefined;

    while (true) {
        try writer.print(">> ", .{});
        const line = (try nextLine(stdin.reader(), &line_buf)).?;
        var tokens = std.mem.tokenizeScalar(u8, line, ' ');
        var i: u8 = 0;

        while (tokens.next()) |token| {
            try writer.print("token {d}: {s}\n", .{ i, token });
            i += 1;
        }
    }
}
