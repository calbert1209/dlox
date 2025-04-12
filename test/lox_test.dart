import 'package:test/test.dart';
import '../bin/lox.dart';

void main() {
  group('Lox', () {
    test('records errors correctly', () {
      final lox = Lox();

      lox.error(1, 'Test error message');

      expect(lox.hadError, true);
    });

    // test('runFile throws UnimplementedError', () async {
    //   final lox = Lox();

    //   expect(() => lox.runFile('test_file.lox'), throwsUnimplementedError);
    // });

    // test('runPrompt throws UnimplementedError', () {
    //   final lox = Lox();

    //   expect(() => lox.runPrompt(), throwsUnimplementedError);
    // });
  });
}
