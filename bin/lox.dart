import 'dart:io';
import 'dart:convert';

class Lox {
  bool hadError = false;

  void error(int line, String message) {
    report(line, "", message);
  }

  void report(int line, String where, String message) {
    print("[line $line] Error $where: $message");
    hadError = true;
  }

  void runFile(String path) async {
    final file = File(path);
    final contents = await file.readAsString();
    run(contents);

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
        run(input);
        hadError = false;
      }
    }
  }

  void run(String source) {
    print("Would run: $source");
  }
}
