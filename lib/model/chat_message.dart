class ChatMessage {
  final String role; // user | assistant
  final String text;

  ChatMessage({
    required this.role,
    required this.text,
  });

  Map<String, String> toMap() {
    return {
      "role": role,
      "text": text,
    };
  }
}
