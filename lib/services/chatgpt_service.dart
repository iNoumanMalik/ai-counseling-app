import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class ChatGPTService {
  static String _apiKey = dotenv.env['OPENAI_KEY'] ?? '';
  static const String _url =
      "https://api.openai.com/v1/chat/completions";

  static Future<String> askCounselor(String userMessage) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_apiKey",
      },
      body: jsonEncode({
        "model": "gpt-4.1",
        "messages": [
          {
            "role": "system",
            "content":
                "You are a warm, compassionate counseling coach. "
                "You speak softly, give practical emotional guidance, "
                "and avoid medical or diagnostic claims."
          },
          {
            "role": "user",
            "content": userMessage
          }
        ]
      }),
    );

    final json = jsonDecode(response.body);

    return json["choices"][0]["message"]["content"];
  }
}
