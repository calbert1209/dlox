import 'token.dart';
import 'token_type.dart' show TokenType;
import 'lox.dart';

class Char {
  static const String space = ' ';
  static const String carriageReturn = '\r';
  static const String tab = '\t';
  static const String newLine = '\n';
  static const String doubleQuotation = '"';
  static const String quotation = "'";
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
  static final alphaChar = RegExp(r'^[a-zA-Z_]+$');
}

Map<String, TokenType> _keywordTokenMap = {
  "and": TokenType.and,
  "class": TokenType.classKeyword,
  "else": TokenType.elseKeyword,
  "false": TokenType.falseKeyword,
  "for": TokenType.forKeyword,
  "fun": TokenType.fun,
  "if": TokenType.ifKeyword,
  "nil": TokenType.nil,
  "or": TokenType.or,
  "print": TokenType.print,
  "return": TokenType.returnKeyword,
  "super": TokenType.superKeyword,
  "this": TokenType.thisKeyword,
  "true": TokenType.trueKeyword,
  "var": TokenType.varKeyword,
  "while": TokenType.whileKeyword,
};

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

  List<Token> get tokens {
    return _tokens;
  }

  bool get _isAtEnd {
    return _current >= _source.length;
  }

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

  /// Consumes the next character if it matches the expected value.
  bool _match(String expected) {
    if (_isAtEnd) return false;
    if (_source[_current] != expected) return false;

    _current++;
    return true;
  }

  bool _isDigit(c) => Char.digit.contains(c);

  bool _isAlpha(c) => Char.alphaChar.hasMatch(c);

  bool _isAlphaNumeric(c) => _isAlpha(c) || _isDigit(c);

  void _string(String delimiter) {
    print(_source[_current]);
    while (_peek != delimiter && !_isAtEnd) {
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

  void _identifier() {
    while (_isAlphaNumeric(_peek)) {
      _advance();
    }

    var text = _source.substring(_start, _current);
    var tokenType = _keywordTokenMap[text] ?? TokenType.identifier;

    _addToken(tokenType);
  }

  /// Returns the next character if available, without consuming it.
  String _peekNext() {
    if (_isAtEnd) return String.fromCharCode(0);
    return _source[_current + 1];
  }

  void _number() {
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
        _addToken(_match('=') ? TokenType.bangEqual : TokenType.bang);
      case '=':
        _addToken(_match('=') ? TokenType.equalEqual : TokenType.equal);
      case '<':
        _addToken(_match('=') ? TokenType.lessEqual : TokenType.less);
      case '>':
        _addToken(_match('=') ? TokenType.greaterEqual : TokenType.greater);
      case '/':
        if (_match('/')) {
          // Ignore all characters up to the next new-line char.
          while (_peek != '\n' && !_isAtEnd) {
            _advance();
          }
        } else {
          _addToken(TokenType.slash);
        }

      case Char.doubleQuotation:
        _string(Char.doubleQuotation);

      case Char.quotation:
        _string(Char.quotation);

      case Char.space:
      case Char.carriageReturn:
      case Char.tab:
        // Ignore whitespace.
        break;

      case Char.newLine:
        _line++;

      default:
        if (_isDigit(c)) {
          _number();
          break;
        }
        if (_isAlpha(c)) {
          _identifier();
          break;
        }
        _lox.error(
          _line,
          'Lexical error: unexpected character. "$c" $_line:$_current',
        );
    }
  }
}
