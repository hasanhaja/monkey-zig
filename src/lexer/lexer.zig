const string = @import("../util.zig").string;
const token = @import("../token/token.zig");
const std = @import("std");

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
    while (
      self.ch == ' ' or self.ch == '\t' or self.ch == '\n' or self.ch == '\r'
    ) {
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

    std.debug.print("Before return: {any}\n", .{tok.literal});
    defer std.debug.print("After return: {any}\n", .{tok.literal});

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
  const literal = [_]u8{ ch };
  return token.Token{ .token_type = token_type, .literal = &literal};
}
