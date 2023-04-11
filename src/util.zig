pub const string = []const u8;

// This lives in memory until the program finishes executing, and the method returns a pointer to this string literal
const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ/,.<>{}()*!+=-;";

// TODO Could I use the ordinal values instead of using a loop to scan for the character?
pub fn charToString(char: u8) string {
    for (chars) |e, i| {
        if (e == char) {
            return chars[i..][0..1];
        }
    }
    @panic("charToString(): letter is not part of ASCII");
}
