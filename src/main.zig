const std = @import("std");
const lexer = @import("lexer");

pub fn main() !void {
    var my_lexer = lexer.Lexer.init("}");
    const test_token = my_lexer.next_token();
    std.debug.print("next_token: {any}\n", .{test_token});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
