import 'dart:io';
import 'dart:convert';

abstract class ILox {
  void error(int line, String message);
  Future<void> runFile(String path);
  void runPrompt();
}

class Lox implements ILox {
  bool hadError = false;

  @override
  void error(int line, String message) {
    _report(line, "", message);
  }

  void _report(int line, String where, String message) {
    print("[line $line] Error $where: $message");
    hadError = true;
  }

  @override
  Future<void> runFile(String path) async {
    final file = File(path);
    final contents = await file.readAsString();
    _run(contents);

    // Indicate an error in the exit code.
    if (hadError) {
      exit(65);
    }
  }

  void runPrompt() {
    print("repl mode");

    while (true) {
      stdout.write("> ");
      final input = stdin.readLineSync(encoding: utf8);
      if (input == null) {
        break;
      }
      // Process the input
      if (input.isNotEmpty) {
        _run(input);
        hadError = false;
      }
    }
  }

  void _run(String source) {
    print("Would run: $source");
  }
}
