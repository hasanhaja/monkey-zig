const std = @import("std");
const token = @import("./token/token.zig");
const lexer = @import("./lexer/lexer.zig");

pub fn main() !void {
  var my_lexer = lexer.Lexer.init(")");
  const test_token = my_lexer.next_token();
  std.debug.print("At invocation: {any}\n", .{test_token.literal});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
