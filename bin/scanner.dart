import 'token.dart';
import 'token_type.dart';
import 'lox.dart';

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

  _addToken(TokenType type, [dynamic literal]) {
    var text = _source.substring(_start, _current);
    _tokens.add(Token(type, text, literal, _line));
  }

  _scanToken() {
    var c = _advance();
    switch (c) {
      case '(':
        _addToken(TokenType.leftParen);
        break;
      case ')':
        _addToken(TokenType.rightParen);
        break;
      case '{':
        _addToken(TokenType.leftBrace);
        break;
      case '}':
        _addToken(TokenType.rightBrace);
        break;
      case ',':
        _addToken(TokenType.comma);
        break;
      case '.':
        _addToken(TokenType.dot);
        break;
      case '-':
        _addToken(TokenType.minus);
        break;
      case '+':
        _addToken(TokenType.plus);
        break;
      case ';':
        _addToken(TokenType.semicolon);
        break;
      case '*':
        _addToken(TokenType.star);
        break;
      default:
        _lox.error(
          _line,
          'Lexical error: unexpected character. $_line:$_current',
        );
    }
  }
}
