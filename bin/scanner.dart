import 'dart:ffi';

import 'token.dart';
import 'token_type.dart' show TokenType;
import 'lox.dart';

class Char {
  static const String space = ' ';
  static const String carriageReturn = '\r';
  static const String tab = '\t';
  static const String newLine = '\n';
  static const String doubleQuotation = '"';
  static const Set<String> digit = {
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
  };
}

abstract class IScanner {
  List<Token> scanTokens();
}

class Scanner implements IScanner {
  final String _source;
  final ILox _lox;
  final List<Token> _tokens = [];
  int _start = 0;
  int _current = 0;
  int _line = 1;

  Scanner(this._source, this._lox);

  bool get _isAtEnd {
    return _current >= _source.length;
  }

  /// Implements Nystrom's `peek()` method.
  /// Does not consume next character.
  String get _peek {
    if (_isAtEnd) return String.fromCharCode(0);
    return _source[_current];
  }

  int get line {
    return _line;
  }

  @override
  List<Token> scanTokens() {
    while (!_isAtEnd) {
      _start = _current;
      _scanToken();
    }
    _tokens.add(Token(TokenType.eof, '', null, _line));

    return _tokens;
  }

  String _advance() {
    return _source[_current++];
  }

  void _addToken(TokenType type, [dynamic literal]) {
    var text = _source.substring(_start, _current);
    _tokens.add(Token(type, text, literal, _line));
  }

  /// Implements Nystrom's `match()` method.
  /// Consumes the next character if it matches the expected value.
  bool _nextIs(String expected) {
    if (_isAtEnd) return false;
    if (_source[_current] != expected) return false;

    _current++;
    return true;
  }

  bool _isDigit(c) => Char.digit.contains(c);

  /// Implements Nystrom's `string()` method.
  void _scanString() {
    while (_peek != Char.doubleQuotation && _isAtEnd) {
      if (_peek == Char.newLine) _line++;
      _advance();
    }

    if (_isAtEnd) {
      _lox.error(_line, "Unterminated string.");
      return;
    }

    // Advance cursor to closing double quotation mark.
    _advance();

    // Trim the surrounding quotes.
    // TODO: To support escape sequences like `\n`, escape them here.
    var value = _source.substring(_start + 1, _current - 1);
    _addToken(TokenType.string, value);
  }

  /// Implements Nystrom's `peekNext()`.
  /// Returns the next character if available, without consuming it.
  String _peekNext() {
    if (_isAtEnd) return String.fromCharCode(0);
    return _source[_current + 1];
  }

  /// Implements Nystrom's `number()` method.
  void _scanNumber() {
    // capture initial digits.
    while (_isDigit(_peek)) {
      _advance();
    }

    // capture decimal point.
    if (_peek == "." && _isDigit(_peekNext())) {
      _advance();
    }

    // capture digits after decimal point.
    while (_isDigit(_peek)) {
      _advance();
    }

    var value = double.parse(_source.substring(_start, _current));
    _addToken(TokenType.number, value);
  }

  _scanToken() {
    var c = _advance();
    switch (c) {
      case '(':
        _addToken(TokenType.leftParen);
      case ')':
        _addToken(TokenType.rightParen);
      case '{':
        _addToken(TokenType.leftBrace);
      case '}':
        _addToken(TokenType.rightBrace);
      case ',':
        _addToken(TokenType.comma);
      case '.':
        _addToken(TokenType.dot);
      case '-':
        _addToken(TokenType.minus);
      case '+':
        _addToken(TokenType.plus);
      case ';':
        _addToken(TokenType.semicolon);
      case '*':
        _addToken(TokenType.star);
      case '!':
        _addToken(_nextIs('=') ? TokenType.bangEqual : TokenType.bang);
      case '=':
        _addToken(_nextIs('=') ? TokenType.equalEqual : TokenType.equal);
      case '<':
        _addToken(_nextIs('=') ? TokenType.lessEqual : TokenType.less);
      case '>':
        _addToken(_nextIs('=') ? TokenType.greaterEqual : TokenType.greater);
      case '/':
        if (_nextIs('/')) {
          // Ignore all characters up to the next new-line char.
          while (_peek != '\n' && !_isAtEnd) {
            _advance();
          }
        } else {
          _addToken(TokenType.slash);
        }

      case Char.doubleQuotation:
        _scanString();

      case Char.space:
      case Char.carriageReturn:
      case Char.tab:
        // Ignore whitespace.
        break;

      case Char.newLine:
        _line++;

      default:
        if (_isDigit(c)) {
          _scanNumber();
        }
        _lox.error(
          _line,
          'Lexical error: unexpected character. $_line:$_current',
        );
    }
  }
}
