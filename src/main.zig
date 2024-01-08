const std = @import("std");
const fmt = std.fmt;
const eql = std.mem.eql;
const isDigit = std.ascii.isDigit;

const STACK_CAPACITY = 1024;
const LINE_BUF_SIZE = 64;
const ALLOC_BUF_SIZE = 1024;

const Word = i32;

var compile_mode = false; // are we in compile mode : ___ ;
var token_idx: u32 = 0; // which token is this

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

    pub fn show(self: Stack) void {
        // std.debug.print("Stack: [", .{});

        for (0..self.stack_size) |i| {
            std.debug.print("{d} ", .{self.stack[i]});
        }

        // std.debug.print("]", .{});
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

const Parser = struct {
    stack: Stack,
    dict: std.StringHashMap([]const u8),
    curr_word: []const u8,

    pub fn init(d: std.StringHashMap([]const u8)) Parser {
        var p: Parser = undefined;
        p.stack = Stack{};
        p.dict = d;

        return p;
    }

    fn processToken(p: *Parser, token: []const u8, idx: u32) !void {
        const first_char = token[0];
        // probably a number, try to parse
        if (isDigit(first_char)) {
            const num = try fmt.parseInt(Word, token, 0);
            try p.stack.push(num);
        }

        if (first_char == 's') {
            p.stack.show();
        }

        if (eql(u8, token, "+")) {
            var a = try p.stack.pop();
            var b = try p.stack.pop();

            try p.stack.push(a + b);
        }

        if (eql(u8, token, ".")) {
            var a = try p.stack.pop();
            std.debug.print("{d}\n", .{a});
        }

        if (eql(u8, token, ":")) {
            // we in compile mode
            compile_mode = true;
        }

        if (eql(u8, token, ";")) {
            // out of compile mode
            compile_mode = false;
        }

        // save this word
        if (idx == 1 and compile_mode) {

            //try dict.put(key: K, value: V)
        }
    }
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

pub fn main() !void {
    const stdin = std.io.getStdIn();
    const stdout = std.io.getStdOut();
    const writer = stdout.writer();

    var line_buf: [LINE_BUF_SIZE]u8 = undefined;

    const allocator: std.mem.Allocator = init: {
        // use an array as the "heap"
        var buffer: [ALLOC_BUF_SIZE]u8 = undefined;
        var fba = std.heap.FixedBufferAllocator.init(&buffer);
        break :init fba.allocator();
    };

    var dictionary = std.StringHashMap([]const u8).init(allocator);

    var parser = Parser.init(dictionary);

    while (true) {
        try writer.print(">> ", .{});
        const line = (try nextLine(stdin.reader(), &line_buf)).?;
        var tokens = std.mem.tokenizeScalar(u8, line, ' ');
        token_idx = 0;

        while (tokens.next()) |token| {
            const ret = parser.processToken(token, token_idx);

            // check if void before printing?
            try writer.print("{!}\n", .{ret});

            token_idx += 1;
        }
    }
}

test "test" {}
