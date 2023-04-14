const std = @import("std");
const Allocator = std.mem.Allocator;
const io = std.io;

const lexer = @import("../lexer/lexer.zig");
const token = @import("../token/token.zig");

const PROMPT = ">> ";

fn read_line(allocator: Allocator, reader: anytype) ![]u8 {
    var line = try reader.readUntilDelimiterAlloc(allocator, '\n', 1024);

    // trim windows only carriage return character
    if (@import("builtin").os.tag == .windows) {
        return std.mem.trimRight(u8, line, "\r");
    } else {
        return line;
    }
}

pub const Repl = struct {
    allocator: Allocator,

    const Self = @This();

    pub fn init(allocator: Allocator) Self {
        return Self{
            .allocator = allocator,
        };
    }

    pub fn start(self: *Self, std_in: anytype, std_out: anytype) !void {
        while (true) {
            try std_out.writeAll(PROMPT);
            var line = try read_line(self.allocator, std_in.reader());
            defer self.allocator.free(line);

            var lex = lexer.Lexer.init(line);

            var next = lex.next_token();
            while (!std.mem.eql(u8, next.token_type, token.EOF)) : (next = lex.next_token()) {
                try std_out.writer().print(
                    "[type: {s}, literal: {s}]\n",
                    .{ next.token_type, next.literal },
                );
            }
        }
    }
};
