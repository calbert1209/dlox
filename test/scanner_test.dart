import 'package:test/test.dart';
import '../bin/scanner.dart';
import '../bin/token_type.dart';
import '../bin/lox.dart';

class MockLox implements ILox {
  final List<String> errors = [];

  @override
  void error(int line, String message) {
    errors.add('Line $line: $message');
  }

  @override
  Future<void> runFile(String path) {
    // TODO: implement runFile
    throw UnimplementedError();
  }

  @override
  void runPrompt() {
    // TODO: implement runPrompt
    throw UnimplementedError();
  }
}

void main() {
  group('Scanner', () {
    test('scans single-character tokens', () {
      final source = '(){},.-+;*';
      final mockLox = MockLox();
      final scanner = Scanner(source, mockLox);

      final tokens = scanner.scanTokens();

      expect(tokens.map((t) => t.type), [
        TokenType.leftParen,
        TokenType.rightParen,
        TokenType.leftBrace,
        TokenType.rightBrace,
        TokenType.comma,
        TokenType.dot,
        TokenType.minus,
        TokenType.plus,
        TokenType.semicolon,
        TokenType.star,
        TokenType.eof,
      ]);
    });

    test('reports unexpected characters', () {
      final source = '@';
      final mockLox = MockLox();
      final scanner = Scanner(source, mockLox);

      scanner.scanTokens();

      expect(
        mockLox.errors,
        contains('Line 1: Lexical error: unexpected character. 1:1'),
      );
    });
  });
}
