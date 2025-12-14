import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/colors.dart';
import '../core/widgets/animated_background.dart';
import '../model/chat_message.dart';
import '../services/chatgpt_service.dart';

class CounselorChatScreen extends StatefulWidget {
  const CounselorChatScreen({super.key});

  @override
  State<CounselorChatScreen> createState() => _CounselorChatScreenState();
}

class _CounselorChatScreenState extends State<CounselorChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(role: "user", text: text));
      _loading = true;
    });

    _controller.clear();

    final reply = await ChatGPTService.getReply(
      _messages.map((m) => m.toMap()).toList(),
    );

    setState(() {
      _loading = false;
      _messages.add(ChatMessage(role: "assistant", text: reply));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MindWell Counselor")),
      body: AnimatedBackground(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg.role == "user";

                  final bubble = Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: isUser ? AppColors.secondaryGradient : null,
                      color: isUser ? null : AppColors.white.withValues(alpha: 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: (isUser ? AppColors.secondary : AppColors.dark900).withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: isUser ? AppColors.dark900 : AppColors.dark900,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 200.ms)
                      .slideY(begin: 0.1, end: 0);

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: bubble,
                  );
                },
              ),
            ),

            if (_loading)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const _TypingDots(),
                ).animate().fadeIn(duration: 200.ms),
              ),

            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.85),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.glassShadow,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
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
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingDots extends StatelessWidget {
  const _TypingDots();
  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.mediumGray,
        shape: BoxShape.circle,
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot.animate(onPlay: (c) => c.repeat()).shimmer(duration: 800.ms),
        const SizedBox(width: 4),
        dot.animate(onPlay: (c) => c.repeat()).shimmer(duration: 800.ms),
        const SizedBox(width: 4),
        dot.animate(onPlay: (c) => c.repeat()).shimmer(duration: 800.ms),
      ],
    );
  }
}
