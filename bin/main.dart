import 'dart:io';
import 'lox.dart';

void main(List<String> argv) {
  var lox = Lox();
  if (argv.length > 1) {
    print("Usage: lox [script]");
    exit(64);
  } else if (argv.length == 1) {
    lox.runFile(argv[0]);
  } else {
    lox.runPrompt();
  }
}
