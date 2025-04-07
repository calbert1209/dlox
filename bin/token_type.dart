enum TokenType {
  // Single-character tokens.
  leftParen,
  rightParen,
  leftBrace,
  rightBrace,
  comma,
  dot,
  minus,
  plus,
  semicolon,
  slash,
  star,

  // One or two character tokens.
  bang,
  bangEqual,
  equal,
  equalEqual,
  greater,
  greaterEqual,
  less,
  lessEqual,

  // Literals.
  identifier,
  string,
  number,

  // Keywords.
  and,
  classKeyword,
  elseKeyword,
  falseKeyword,
  fun,
  forKeyword,
  ifKeyword,
  nil,
  or,
  print,
  returnKeyword,
  superKeyword,
  thisKeyword,
  trueKeyword,
  varKeyword,
  whileKeyword,

  eof,
}
