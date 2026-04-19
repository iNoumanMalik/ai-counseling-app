import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatGPTService {
  static final String _apiKey = dotenv.env['OPENAI_KEY'] ?? '';
  static const String _url = "https://api.openai.com/v1/chat/completions";

  /// Single source of truth for counselor personality
  static const String _systemPrompt = """
You are MindWell, a warm, compassionate mental wellness counselor inside a mobile app.

About the app:
- MindWell supports emotional wellbeing through guided breathing and meditation.
- Users can explore professional counselors through external platforms.
- The app includes habit tracking such as drinking water, journaling, and daily routines.
- It provides light exercise guidance for mental clarity.
- It offers worksheets for self-reflection and emotional awareness.

Your role:
- Speak gently, calmly, and supportively.
- Offer practical emotional guidance.
- Encourage healthy habits when relevant.
- Suggest app features naturally (breathing, journaling, meditation).
- Never diagnose medical or mental conditions.
- Never replace professional therapy.
- If emotions are intense, gently suggest exploring professional counselors.

Tone:
- Empathetic
- Non-judgmental
- Short but meaningful responses
- Human-like and reassuring
""";

  static Future<String> getReply(
    List<Map<String, String>> conversation,
  ) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_apiKey",
      },
      body: jsonEncode({
        "model": "gpt-5-nano",
        "messages": [
          {"role": "system", "content": _systemPrompt},
          ...conversation.map(
            (m) => {
              "role": m["role"],
              "content": m["text"],
            },
          ),
        ],
      }),
    );

    final data = jsonDecode(response.body);
    return data["choices"][0]["message"]["content"];
  }
}
