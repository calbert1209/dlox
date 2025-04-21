import 'dart:math';

class Node<T> {
  final Map<String, Node<T>> next = <String, Node<T>>{};
  T? value;

  Node([this.value]);
}

class Trie<T> {
  static const R = 256;

  Node<T> _root = Node();

  // Retrieve /////////////////////////////

  T? get(String key) {
    var node = _get(_root, key, 0);
    if (node == null) return null;
    return node.value;
  }

  Node<T>? _get(Node<T>? node, String key, int depth) {
    if (node == null) return null;

    if (depth == key.length) return node;

    String c = key[depth];
    return _get(node.next[c], key, depth + 1);
  }

  // Insert /////////////////////////////

  void put(String key, T value) {
    _root = _put(_root, key, value, 0);
  }

  Node<T> _put(Node<T>? node, String key, T value, int depth) {
    node ??= Node<T>();

    if (depth == key.length) {
      node.value = value;
      return node;
    }

    String c = key[depth];
    node.next[c] = _put(node.next[c], key, value, depth + 1);
    return node;
  }

  // Keys /////////////////////////////

  List<String> keys() {
    return keysWithPrefix("");
  }

  List<String> keysWithPrefix(String prefix) {
    final keys = List<String>.empty(growable: true);
    _collect(_get(_root, prefix, 0), prefix, keys);

    return keys;
  }

  void _collect(Node<T>? node, String prefix, List<String> keys) {
    if (node == null) return;

    if (node.value != null) {
      keys.add(prefix);
    }

    for (var c in node.next.keys) {
      _collect(node.next[c], prefix + c, keys);
    }
  }
}

void main(List<String> args) {
  var trie = Trie<String>();
  for (var value in [
    "she",
    "sells",
    "sea",
    "shells",
    "by",
    "the",
    "sea",
    "shore",
    ";",
  ]) {
    trie.put(value, value.toUpperCase());
  }

  var sample = "shellszorg;fongbythe";
  for (var i = 0; i < sample.length; i++) {
    var limit = min(sample.length, i + 7);
    var value = "";
    for (var j = i; j < limit; j++) {
      var substr = sample.substring(i, j);
      var inTrie = trie.get(substr);
      if (inTrie != null) {
        value = inTrie;
      }
      print(substr);
    }
    print(value);
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

/*


 */
