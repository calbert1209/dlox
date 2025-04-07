import 'dart:io';
import 'dart:convert';

class Lox {
  void runFile(String path) async {
    final file = File(path);
    final contents = await file.readAsString();
    run(contents);
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
      }
    }
  }

  void run(String source) {
    print("Would run: $source");
  }
}
