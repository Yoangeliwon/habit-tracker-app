import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Fetches users from JSONPlaceholder — their names are used as habit suggestions
  static Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/users'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to fetch habit suggestions');
  }

  // Fetches a motivational quote — used to motivate users on the home screen
  static Future<String> fetchMotivationalQuote() async {
    try {
      final response = await http.get(
        Uri.parse('https://zenquotes.io/api/random'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final quote = data[0]['q'];
        final author = data[0]['a'];
        return '"$quote" — $author';
      }
    } catch (_) {}

    return '"Small steps every day lead to big results."';
  }
}
