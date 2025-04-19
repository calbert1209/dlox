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

    test('scans multi-character operators', () {
      final source = '!= == <= >=';
      final mockLox = MockLox();
      final scanner = Scanner(source, mockLox);

      final tokens = scanner.scanTokens();

      expect(tokens.map((t) => t.type), [
        TokenType.bangEqual,
        TokenType.equalEqual,
        TokenType.lessEqual,
        TokenType.greaterEqual,
        TokenType.eof,
      ]);
    });

    test('scans single forward-slash as TokenType.slash', () {
      final source = '/';
      final mockLox = MockLox();
      final scanner = Scanner(source, mockLox);

      final tokens = scanner.scanTokens();

      expect(tokens.map((t) => t.type), [TokenType.slash, TokenType.eof]);
    });

    test('ignores comments starting with //', () {
      final source = '// This is a comment\n/';
      final mockLox = MockLox();
      final scanner = Scanner(source, mockLox);

      final tokens = scanner.scanTokens();

      expect(tokens.map((t) => t.type), [TokenType.slash, TokenType.eof]);
    });
  });

  test('ignores spaces, tabs, and carriage returns', () {
    final source = ' \t\r';
    final mockLox = MockLox();
    final scanner = Scanner(source, mockLox);

    final tokens = scanner.scanTokens();

    // Only the EOF token should be present
    expect(tokens.map((t) => t.type), [TokenType.eof]);
  });

  test('increments line number for newlines', () {
    final source = '\n\n';
    final mockLox = MockLox();
    final scanner = Scanner(source, mockLox);

    scanner.scanTokens();

    // Verify that the line number is incremented correctly
    expect(scanner.line, 3); // Starts at 1, increments twice
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
}
