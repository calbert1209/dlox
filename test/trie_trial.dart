import '../bin/trie.dart';

class TrieSet<T> {
  Trie<T> trie = Trie<T>();

  TrieSet();

  bool has(String key) {
    return this.trie.get(key) != null;
  }
}

final _nonTokenDelimiters = {" ", "\t", "\n", ";"};

typedef Range = ({int start, int end});

bool matchPrefix(Range range, String text, String query) {
  final prefix = text.substring(range.start, range.start + query.length);
  return prefix == query;
}

bool prefixIsDigit(Range range, String text) {
  final prefix = text.substring(range.start, range.start + 1);
  return isDigit(prefix);
}

Range chomp(Range range, String text, List<String> hits, TrieSet<String> set) {
  var scan = text.substring(range.start, range.end);
  var next = text.substring(range.end, range.end + 1);

  if (_nonTokenDelimiters.contains(scan)) {
    return (start: range.end, end: range.end + 1);
  }

  if (set.has(scan) && set.has(next)) {
    hits.add('$scan:${set.trie.get(scan)}');
    return (start: range.end, end: range.end + 1);
  }

  if (set.has(scan) && scan.length == 1) {
    hits.add('$scan:Delimiter');
    return (start: range.end, end: range.end + 1);
  }

  if (set.has(next)) {
    hits.add('$scan:Identifier');
    return (start: range.end, end: range.end + 1);
  }

  return (start: range.start, end: range.end + 1);
}

Range chompString(
  Range range,
  String text,
  List<String> hits,
  TrieSet<String> set,
) {
  final initialDelimiter = text.substring(range.start, range.start + 1);
  var stringEnd = range.end;
  var nextChar = text.substring(stringEnd, stringEnd + 1);

  while (nextChar != initialDelimiter) {
    if (nextChar == "\n") {
      throw Exception("Syntax error, unexpected new-line character.");
    }

    stringEnd++;
    nextChar = text.substring(stringEnd, stringEnd + 1);
  }

  var scannedText = text.substring(range.start, stringEnd + 1);
  hits.add("$scannedText:String");

  return (start: stringEnd + 1, end: stringEnd + 2);
}

Range chompComment(Range range, String text) {
  var commentEnd = range.end;
  var nextChar = text.substring(commentEnd, commentEnd + 1);

  while (nextChar != "\n") {
    commentEnd++;
    nextChar = text.substring(commentEnd, commentEnd + 1);
  }

  return (start: commentEnd + 1, end: commentEnd + 2);
}

bool isDigit(String c) {
  if (c.length > 1) {
    throw Exception("Invalid argument: string has more than 1 character");
  }

  final codeUnit = c.codeUnitAt(0);
  return codeUnit >= 48 && codeUnit <= 57;
}

Range chompNumber(
  Range range,
  String text,
  List<String> hits,
  TrieSet<String> set,
) {
  var numberEnd = range.end;
  var nextChar = text.substring(numberEnd, numberEnd + 1);
  var hasDecimalPoint = false;

  while (isDigit(nextChar) || nextChar == ".") {
    if (hasDecimalPoint && nextChar == ".") {
      throw Exception(
        "Syntax Error, unexpected second decimal point in number",
      );
    }

    if (nextChar == ".") {
      hasDecimalPoint = true;
    }

    numberEnd++;
    nextChar = text.substring(numberEnd, numberEnd + 1);
  }

  var scannedText = text.substring(range.start, numberEnd);
  hits.add("$scannedText:Number");

  return (start: numberEnd, end: numberEnd + 1);
}

bool prefixIsBoolOperator(Range range, String text) {
  return [">", "<", "!", "="].any((query) => matchPrefix(range, text, query));
}

Range chompBoolOperator(
  Range range,
  String text,
  List<String> hits,
  TrieSet<String> set,
) {
  var scan = text.substring(range.start, range.start + 1);
  var next = text.substring(range.start + 1, range.start + 2);
  switch (scan) {
    case "!":
      if (next == "=") {
        hits.add("$scan$next:NOT_EQUAL");
        return (start: range.start + 2, end: range.start + 3);
      }

      hits.add("$scan:NOT");
      return (start: range.start + 1, end: range.start + 2);

    case ">":
      if (next == "=") {
        hits.add("$scan$next:GT_EQUAL");
        return (start: range.start + 2, end: range.start + 3);
      }

      hits.add("$scan:GT");
      return (start: range.start + 1, end: range.start + 2);

    case "<":
      if (next == "=") {
        hits.add("$scan$next:LT_EQUAL");
        return (start: range.start + 2, end: range.start + 3);
      }

      hits.add("$scan:LT");
      return (start: range.start + 1, end: range.start + 2);

    case "=":
      if (next == "=") {
        hits.add("$scan$next:DBL_EQUAL");
        return (start: range.start + 2, end: range.start + 3);
      }

      hits.add("$scan:EQUAL");
      return (start: range.start + 1, end: range.start + 2);
    default:
      return (start: range.start + 1, end: range.start + 2);
  }
}

const Map<String, String> _tokenMap = {
  "(": "OPEN_PAREN",
  ")": "CLOSE_PAREN",
  "{": "OPEN_BRACE",
  "}": "CLOSE_BRACE",
  "=": "EQUAL",
  "\n": "NEW_LINE",
  " ": "SPACE",
  ";": "SEMI_COLON",
  "\"": "DBL_QUOTE",
  ",": "COMMA",
  ".": "DOT",
  "-": "MINUS",
  "+": "PLUS",
  "/": "SLASH",
  "*": "STAR",
  "function": "FUNCTION",
  "var": "VAR",
  "if": "IF",
};

void main() {
  var trieSet = TrieSet<String>();
  for (var entry in _tokenMap.entries) {
    trieSet.trie.put(entry.key, entry.value);
  }

  var sample = """(
  function functionallyDo() {
    // This is a comment
    print("Hello world!", 3.14);
    
    var h2o = Math.random() * 100 / 10;

    if (h2o >= 5) {
      print("other stuff");
    }  
  }
)();
""";

  var scanRange = (start: 0, end: 1);

  List<String> hits = [];

  while (scanRange.end < sample.length) {
    if (prefixIsDigit(scanRange, sample)) {
      // Number
      scanRange = chompNumber(scanRange, sample, hits, trieSet);
    } else if (prefixIsBoolOperator(scanRange, sample)) {
      scanRange = chompBoolOperator(scanRange, sample, hits, trieSet);
    } else if (matchPrefix(scanRange, sample, '//')) {
      // Comment
      scanRange = chompComment(scanRange, sample);
    } else if (matchPrefix(scanRange, sample, "\"") ||
        matchPrefix(scanRange, sample, "'")) {
      // String Literal
      scanRange = chompString(scanRange, sample, hits, trieSet);
    } else {
      scanRange = chomp(scanRange, sample, hits, trieSet);
    }
  }

  for (var item in hits) {
    print(item.replaceAll('\n', '↳'));
  }
}

/*
(function(){\n
  print("hello world!");
})();

(         delimiter   OPEN_PAREN    single character delimiter
f         null
fu        null
...
function  keyword     FUNCTION      keyword match, followed by delimiter
(         delimiter   OPEN_PAREN    single character delimiter
)         delimiter   CLOSE_PAREN   single character delimiter
{         delimiter   OPEN_BRACE    single character delimiter
↳         delimiter   NEW_LINE      single character delimiter
␠         delimiter   WHITE_SPACE   single character delimiter
␠         delimiter   WHITE_SPACE   single character delimiter
p         null
pr        null
...
print     identifier  IDENTIFIER    no keyword match, followed by delimiter
(         delimiter   OPEN_PAREN    single character delimiter
"         null                      (signals start of string literal)
"H        null
...
"Hello world!" literal  STRING      bound by quotation marks
)         delimiter   CLOSE_PAREN   single character delimiter
;         delimiter   SEMI_COLON    single character delimiter
↳         delimiter   NEW_LINE      single character delimiter
}         delimiter   CLOSE_BRACE    single character delimiter
)         delimiter   CLOSE_PAREN   single character delimiter
(         delimiter   OPEN_PAREN    single character delimiter
)         delimiter   CLOSE_PAREN   single character delimiter
;         delimiter   SEMI_COLON    single character delimiter
 */
