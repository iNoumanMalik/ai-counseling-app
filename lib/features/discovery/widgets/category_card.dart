import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/colors.dart';

class CategoryCard extends StatelessWidget {
  final String category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Anxiety':
        return AppColors.moodAnxious;
      case 'Depression':
        return AppColors.moodSad;
      case 'Trauma':
        return AppColors.primary;
      case 'Relationship':
        return Colors.pink.shade300;
      case 'Child Psychology':
        return AppColors.secondary;
      case 'Grief':
        return Colors.grey.shade400;
      case 'Stress Management':
        return AppColors.accent;
      case 'Marriage Counseling':
        return Colors.purple.shade300;
      default:
        return AppColors.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Anxiety':
        return Icons.psychology_outlined;
      case 'Depression':
        return Icons.cloud_outlined;
      case 'Trauma':
        return Icons.healing_outlined;
      case 'Relationship':
        return Icons.favorite_outline;
      case 'Child Psychology':
        return Icons.child_care_outlined;
      case 'Grief':
        return Icons.eco_outlined;
      case 'Stress Management':
        return Icons.balance_outlined;
      case 'Marriage Counseling':
        return Icons.family_restroom_outlined;
      default:
        return Icons.people_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(category);
    final icon = _getCategoryIcon(category);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: AppColors.white,
              ),
              const SizedBox(height: 12),
              Text(
                category,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 300.ms,
        );
  }
}

