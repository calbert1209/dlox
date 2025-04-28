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
      contains('Line 1: Lexical error: unexpected character. "@" 1:1'),
    );
  });

  group('Scanner - Numbers and Identifiers', () {
    test('scans integer numbers', () {
      final source = '12345';
      final mockLox = MockLox();
      final scanner = Scanner(source, mockLox);

      final tokens = scanner.scanTokens();

      expect(tokens.map((t) => t.type), [TokenType.number, TokenType.eof]);
      expect(tokens[0].literal, 12345); // Verify the literal value
    });

    test('scans floating-point numbers', () {
      final source = '123.45';
      final mockLox = MockLox();
      final scanner = Scanner(source, mockLox);

      final tokens = scanner.scanTokens();

      expect(tokens.map((t) => t.type), [TokenType.number, TokenType.eof]);
      expect(tokens[0].literal, 123.45); // Verify the literal value
    });

    test('scans identifiers', () {
      final source = 'variableName';
      final mockLox = MockLox();
      final scanner = Scanner(source, mockLox);

      final tokens = scanner.scanTokens();

      expect(tokens.map((t) => t.type), [TokenType.identifier, TokenType.eof]);
      expect(tokens[0].lexeme, 'variableName'); // Verify the identifier name
    });

    test('scans keywords as identifiers', () {
      final source = 'if else while someIdentifier';
      final mockLox = MockLox();
      final scanner = Scanner(source, mockLox);

      final tokens = scanner.scanTokens();

      expect(tokens.map((t) => t.type), [
        TokenType.ifKeyword,
        TokenType.elseKeyword,
        TokenType.whileKeyword,
        TokenType.identifier,
        TokenType.eof,
      ]);
    });
  });
}
