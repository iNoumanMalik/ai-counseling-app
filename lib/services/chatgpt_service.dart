import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatGPTService {
  static const String _apiKey = "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";
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
