const std = @import("std");
const string = @import("../util.zig").string;

pub const TokenType = string;

pub const keywords = std.ComptimeStringMap(TokenType, .{
    .{ "fn", FUNCTION },
    .{ "let", LET },
    .{ "true", TRUE },
    .{ "false", FALSE },
    .{ "return", RETURN },
    .{ "if", IF },
    .{ "else", ELSE },
});

pub const Token = struct {
    token_type: TokenType,
    literal: string,
};

pub fn lookup_ident(ident: string) TokenType {
    return keywords.get(ident) orelse ident;
}

pub const ILLEGAL = "ILLEGAL";
pub const EOF = "EOF";

// Identifiers + literals
pub const IDENT = "IDENT";
pub const INT = "INT";

// Operators
pub const ASSIGN = "=";
pub const PLUS = "+";
pub const MINUS = "-";
pub const BANG = "!";
pub const ASTERISK = "*";
pub const SLASH = "/";

pub const LT = "<";
pub const GT = ">";

pub const EQ = "==";
pub const NOT_EQ = "!=";

// Delimiters
pub const COMMA = ",";
pub const SEMICOLON = ";";

pub const LPAREN = "(";
pub const RPAREN = ")";
pub const LBRACE = "{";
pub const RBRACE = "}";

// Keywords
pub const FUNCTION = "FUNCTION";
pub const LET = "LET";
pub const TRUE = "TRUE";
pub const FALSE = "FALSE";
pub const IF = "IF";
pub const ELSE = "ELSE";
pub const RETURN = "RETURN";
