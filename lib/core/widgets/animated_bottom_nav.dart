import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/colors.dart';

/// Animated bottom navigation bar
class AnimatedBottomNav extends StatelessWidget {
  final int currentIndex;

  const AnimatedBottomNav({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/discovery');
        break;
      case 2:
        context.go('/habits');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTap(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.mediumGray,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        items: [
          BottomNavigationBarItem(
            icon: _AnimatedIcon(
              icon: Icons.home_rounded,
              isSelected: currentIndex == 0,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _AnimatedIcon(
              icon: Icons.search_rounded,
              isSelected: currentIndex == 1,
            ),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: _AnimatedIcon(
              icon: Icons.check_circle_outline_rounded,
              isSelected: currentIndex == 2,
            ),
            label: 'Habits',
          ),
          BottomNavigationBarItem(
            icon: _AnimatedIcon(
              icon: Icons.person_outline_rounded,
              isSelected: currentIndex == 3,
            ),
            label: 'Profile',
          ),
        ],
      ),
    )
        .animate()
        .slideY(
          begin: 1,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOut,
        )
        .fadeIn(duration: 300.ms);
  }
}

class _AnimatedIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const _AnimatedIcon({required this.icon, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Icon(icon)
        .animate(target: isSelected ? 1 : 0)
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.2, 1.2),
          duration: 200.ms,
        )
        .then()
        .scale(
          begin: const Offset(1.2, 1.2),
          end: const Offset(1, 1),
          duration: 200.ms,
        );
  }
}

