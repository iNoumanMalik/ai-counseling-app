import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CounselorChatScreen extends StatefulWidget {
  const CounselorChatScreen({super.key});

  @override
  State<CounselorChatScreen> createState() => _CounselorChatScreenState();
}

class _CounselorChatScreenState extends State<CounselorChatScreen> {
  final List<Map<String, String>> messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  static const String _apiKey = "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";

  Future<void> sendMessage(String text) async {
    setState(() { _loading = true; });

    

    messages.add({"role": "user", "text": text});
    _controller.clear();

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_apiKey",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {"role": "system", "content": "You are a warm, supportive counseling coach."},
          ...messages.map((m) => {
            "role": m["role"],
            "content": m["text"],
          }),
        ]
      }),
    );

    final data = jsonDecode(response.body);
    final String reply = data["choices"][0]["message"]["content"];

    setState(() {
      _loading = false;
      messages.add({"role": "assistant", "text": reply});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MindWell Counselor")),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: messages.map((m) {
                final isMe = m["role"] == "user";
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blueAccent : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      m["text"]!,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "How are you feeling today?",
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  if (_controller.text.trim().isNotEmpty) {
                    sendMessage(_controller.text.trim());
                  }
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
