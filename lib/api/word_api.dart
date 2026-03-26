import 'dart:convert';
import 'package:http/http.dart' as http;

class WordApi {
  static Future<List<String>> fetchRandomWords(int n) async {
    final uri = Uri.parse('https://random-word-api.herokuapp.com/word?number=$n');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final List<dynamic> arr = jsonDecode(res.body);
      return arr.map((e) => e.toString()).toList();
    } else {
      return List.generate(n, (i) => 'word${i + 1}');
    }
  }

  static Future<String> fetchDefinition(String word) async {
    try {
      final uri = Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List && data.isNotEmpty) {
          final meanings = data[0]['meanings'] as List<dynamic>?;
          if (meanings != null && meanings.isNotEmpty) {
            final defs = meanings[0]['definitions'] as List<dynamic>?;
            if (defs != null && defs.isNotEmpty) {
              return defs[0]['definition'].toString();
            }
          }
        }
      }
    } catch (_) {}
    return 'Definition not available';
  }
}
