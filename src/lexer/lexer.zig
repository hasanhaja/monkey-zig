const util = @import("util");
const string = util.string;
const token = @import("token");
const std = @import("std");
const expect = std.testing.expect;

pub const Lexer = struct {
    input: string,
    position: usize = 0,
    read_position: usize = 0,
    ch: u8 = 0,

    const Self = @This();

    pub fn init(input: string) Self {
        var l = Self{
            .input = input,
        };

        l.read_char();

        return l;
    }

    // Reads the next character if possible
    fn read_char(self: *Self) void {
        if (self.read_position >= self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.read_position];
        }

        self.position = self.read_position;
        self.read_position += 1;
    }

    fn skip_whitespace(self: *Self) void {
        while (self.ch == ' ' or self.ch == '\t' or self.ch == '\n' or self.ch == '\r') {
            self.read_char();
        }
    }

    pub fn next_token(self: *Self) token.Token {
        self.skip_whitespace();

        var tok = switch (self.ch) {
            '=' => blk: {
                if (self.peek_char() == '=') {
                    const ch = self.ch;
                    self.read_char();
                    const literal = [_]u8{ ch, self.ch };
                    break :blk token.Token{ .token_type = token.EQ, .literal = &literal };
                } else {
                    break :blk new_token(token.ASSIGN, self.ch);
                }
            },
            ';' => new_token(token.SEMICOLON, self.ch),
            '(' => new_token(token.LPAREN, self.ch),
            ')' => new_token(token.RPAREN, self.ch),
            '{' => new_token(token.LBRACE, self.ch),
            '}' => new_token(token.RBRACE, self.ch),
            ',' => new_token(token.COMMA, self.ch),
            '+' => new_token(token.PLUS, self.ch),
            '<' => new_token(token.LT, self.ch),
            '>' => new_token(token.GT, self.ch),
            '!' => blk: {
                if (self.peek_char() == '=') {
                    const ch = self.ch;
                    self.read_char();
                    const literal = [_]u8{ ch, self.ch };
                    break :blk token.Token{ .token_type = token.NOT_EQ, .literal = &literal };
                } else {
                    break :blk new_token(token.BANG, self.ch);
                }
            },
            '-' => new_token(token.MINUS, self.ch),
            '*' => new_token(token.ASTERISK, self.ch),
            '/' => new_token(token.SLASH, self.ch),
            0 => token.Token{ .token_type = token.EOF, .literal = "" },
            else => blk: {
                if (is_letter(self.ch)) {
                    const ident = self.read_identifier();
                    return token.Token{ .token_type = token.lookup_ident(ident), .literal = ident };
                } else if (is_digit(self.ch)) {
                    return token.Token{ .token_type = token.INT, .literal = self.read_number() };
                } else {
                    break :blk new_token(token.ILLEGAL, self.ch);
                }
            },
        };

        self.read_char();

        return tok;
    }

    fn peek_char(self: *Self) u8 {
        return if (self.read_position >= self.input.len) 0 else self.input[self.read_position];
    }

    fn read_number(self: *Self) string {
        const position = self.position;
        while (is_digit(self.ch)) {
            self.read_char();
        }
        return self.input[position..self.position];
    }

    fn read_identifier(self: *Self) string {
        const position = self.position;
        while (is_letter(self.ch)) {
            self.read_char();
        }
        return self.input[position..self.position];
    }
};

fn is_digit(ch: u8) bool {
    return '0' <= ch and ch <= '9';
}

// This is the place where we can introduct what characters are valid for variable names
fn is_letter(ch: u8) bool {
    return ('a' <= ch and ch <= 'z') or ('A' <= ch and ch <= 'Z') or ch == '_';
}

fn new_token(token_type: token.TokenType, ch: u8) token.Token {
    return token.Token{ .token_type = token_type, .literal = util.charToString(ch) };
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
        .{ .token_type = token.IDENT, .literal = "five" },
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

    const lexer = Lexer.init(input);

    for (tests) |e| {
        var tok = lexer.next_token();
        expect(tok.token_type == e.token_type);
        expect(tok.literal == e.literal);
    }
}
