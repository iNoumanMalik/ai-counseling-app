import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CounselingFloatingButton extends StatelessWidget {
  const CounselingFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 90,
      child: FloatingActionButton(
        backgroundColor: Colors.purpleAccent,
        shape: const CircleBorder(),
        onPressed: () {
          context.push('/counseling-chat'); // Navigate to ChatGPT page
        },
        child: const Icon(Icons.psychology, size: 28, color: Colors.white),
      ),
    );
  }
}
