const std = @import("std");
const expectEqual = std.testing.expectEqual;
const expectEqualStrings = std.testing.expectEqualStrings;
const lexer = @import("./lexer/lexer.zig");
const Lexer = lexer.Lexer;
const token = @import("./token/token.zig");

pub fn main() !void {
    var my_lexer = lexer.Lexer.init("}");
    const test_token = my_lexer.next_token();
    std.debug.print("next_token: {any}\n", .{test_token});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try expectEqual(@as(i32, 42), list.pop());
}

test "Test next token" {
    const input =
        \\let five = 5;
        \\
        \\let ten = 10;
        \\
        \\let add = fn(x, y) {
        \\  x + y;
        \\};
        \\
        \\let result = add(five, ten);
        \\!-/*5;
        \\5 < 10 > 5;
        \\
        \\if (5 < 10) {
        \\  return true;
        \\} else {
        \\  return false;
        \\}
        \\
        \\10 == 10;
        \\10 != 9;
    ;

    const tests = [_]token.Token{
        .{ .token_type = token.LET, .literal = "let" },
        .{ .token_type = token.IDENT, .literal = "fives" },
        .{ .token_type = token.ASSIGN, .literal = "=" },
        .{ .token_type = token.INT, .literal = "5" },
        .{ .token_type = token.SEMICOLON, .literal = ";" },
        .{ .token_type = token.LET, .literal = "let" },
        .{ .token_type = token.IDENT, .literal = "ten" },
        .{ .token_type = token.ASSIGN, .literal = "=" },
        .{ .token_type = token.INT, .literal = "10" },
        .{ .token_type = token.SEMICOLON, .literal = ";" },
        .{ .token_type = token.LET, .literal = "let" },
        .{ .token_type = token.IDENT, .literal = "add" },
        .{ .token_type = token.ASSIGN, .literal = "=" },
        .{ .token_type = token.FUNCTION, .literal = "fn" },
        .{ .token_type = token.LPAREN, .literal = "(" },
        .{ .token_type = token.IDENT, .literal = "x" },
        .{ .token_type = token.COMMA, .literal = "," },
        .{ .token_type = token.IDENT, .literal = "y" },
        .{ .token_type = token.RPAREN, .literal = ")" },
        .{ .token_type = token.LBRACE, .literal = "{" },
        .{ .token_type = token.IDENT, .literal = "x" },
        .{ .token_type = token.PLUS, .literal = "+" },
        .{ .token_type = token.IDENT, .literal = "y" },
        .{ .token_type = token.SEMICOLON, .literal = ";" },
        .{ .token_type = token.RBRACE, .literal = "}" },
        .{ .token_type = token.SEMICOLON, .literal = ";" },
        .{ .token_type = token.LET, .literal = "let" },
        .{ .token_type = token.IDENT, .literal = "result" },
        .{ .token_type = token.ASSIGN, .literal = "=" },
        .{ .token_type = token.IDENT, .literal = "add" },
        .{ .token_type = token.LPAREN, .literal = "(" },
        .{ .token_type = token.IDENT, .literal = "five" },
        .{ .token_type = token.COMMA, .literal = "," },
        .{ .token_type = token.IDENT, .literal = "ten" },
        .{ .token_type = token.RPAREN, .literal = ")" },
        .{ .token_type = token.SEMICOLON, .literal = ";" },
        .{ .token_type = token.BANG, .literal = "!" },
        .{ .token_type = token.MINUS, .literal = "-" },
        .{ .token_type = token.SLASH, .literal = "/" },
        .{ .token_type = token.ASTERISK, .literal = "*" },
        .{ .token_type = token.INT, .literal = "5" },
        .{ .token_type = token.SEMICOLON, .literal = ";" },
        .{ .token_type = token.INT, .literal = "5" },
        .{ .token_type = token.LT, .literal = "<" },
        .{ .token_type = token.INT, .literal = "10" },
        .{ .token_type = token.GT, .literal = ">" },
        .{ .token_type = token.INT, .literal = "5" },
        .{ .token_type = token.SEMICOLON, .literal = ";" },
        .{ .token_type = token.IF, .literal = "if" },
        .{ .token_type = token.LPAREN, .literal = "(" },
        .{ .token_type = token.INT, .literal = "5" },
        .{ .token_type = token.LT, .literal = "<" },
        .{ .token_type = token.INT, .literal = "10" },
        .{ .token_type = token.RPAREN, .literal = ")" },
        .{ .token_type = token.LBRACE, .literal = "{" },
        .{ .token_type = token.RETURN, .literal = "return" },
        .{ .token_type = token.TRUE, .literal = "true" },
        .{ .token_type = token.SEMICOLON, .literal = ";" },
        .{ .token_type = token.RBRACE, .literal = "}" },
        .{ .token_type = token.ELSE, .literal = "else" },
        .{ .token_type = token.LBRACE, .literal = "{" },
        .{ .token_type = token.RETURN, .literal = "return" },
        .{ .token_type = token.FALSE, .literal = "false" },
        .{ .token_type = token.SEMICOLON, .literal = ";" },
        .{ .token_type = token.RBRACE, .literal = "}" },
        .{ .token_type = token.INT, .literal = "10" },
        .{ .token_type = token.EQ, .literal = "==" },
        .{ .token_type = token.INT, .literal = "10" },
        .{ .token_type = token.SEMICOLON, .literal = ";" },
        .{ .token_type = token.INT, .literal = "10" },
        .{ .token_type = token.NOT_EQ, .literal = "!=" },
        .{ .token_type = token.INT, .literal = "9" },
        .{ .token_type = token.SEMICOLON, .literal = ";" },
        .{ .token_type = token.EOF, .literal = "" },
    };

    var my_lexer = Lexer.init(input);

    for (tests) |e| {
        var tok = my_lexer.next_token();
        try expectEqualStrings(tok.token_type, e.token_type);
        try expectEqualStrings(tok.literal, e.literal);
    }
}
