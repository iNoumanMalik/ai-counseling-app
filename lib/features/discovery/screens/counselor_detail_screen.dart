import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/widgets/webview_modal.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../core/widgets/animated_background.dart';
import '../../../data/dummy/counselors_data.dart';
import '../../../data/models/counselor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/counselor_service.dart';
import '../../../core/utils/storage_service.dart';

class CounselorDetailScreen extends ConsumerWidget {
  final String counselorId;

  const CounselorDetailScreen({super.key, required this.counselorId});

  Counselor? _getCounselor() {
    try {
      return CounselorsData.allCounselors.firstWhere(
        (c) => c.id == counselorId,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _openUrl(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) {
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => WebViewModal(url: url, title: 'Book Online'),
    );
  }

  Future<void> _openWhatsApp(String? number, String name) async {
    if (number == null || number.isEmpty) {
      return;
    }
    final message = "Hi, I want to inquire about a counseling session.";
    final url = "https://wa.me/$number?text=${Uri.encodeComponent(message)}";
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counselor = _getCounselor();

    if (counselor == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Counselor Not Found'),
        ),
        body: const Center(
          child: Text('Counselor not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counselor Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: AnimatedBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile section
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.person_outline_rounded,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    )
                        .animate()
                        .scale(duration: 400.ms, curve: Curves.elasticOut)
                        .fadeIn(duration: 300.ms),
                    const SizedBox(height: 16),
                    Text(
                      counselor.name,
                      style: Theme.of(context).textTheme.displaySmall,
                    )
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 400.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      counselor.specialty,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.mediumGray,
                          ),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Info card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: counselor.city,
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      icon: Icons.work_outline,
                      label: AppStrings.counselorExperience,
                      value: '${counselor.experience} years',
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      icon: Icons.attach_money_outlined,
                      label: AppStrings.counselorFee,
                      value: counselor.fee,
                    ),
                    if (counselor.bio != null) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        counselor.bio!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 24),

              // Action buttons
              Text(
                'Book a Session',
                style: Theme.of(context).textTheme.titleLarge,
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms),
              const SizedBox(height: 16),

              // Save counselor
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await ref.read(counselorServiceProvider).saveCounselor(
                        counselorId: counselor.id,
                        name: counselor.name,
                        link: counselor.marhamUrl ?? '',
                      );
                    } catch (_) {
                      await StorageService.saveCounselor({
                        'id': counselor.id,
                        'name': counselor.name,
                        'link': counselor.marhamUrl ?? '',
                      });
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Counselor saved')),
                    );
                  },
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: const Text('Save Counselor'),
                ),
              )
                  .animate()
                  .fadeIn(delay: 450.ms, duration: 400.ms)
                  .slideX(begin: -0.2, end: 0),

              if (counselor.marhamUrl != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _openUrl(context, counselor.marhamUrl),
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(AppStrings.counselorBookMarham),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 400.ms)
                    .slideX(begin: -0.2, end: 0),
              const SizedBox(height: 12),

              const SizedBox(height: 12),

              if (counselor.whatsappNumber != null)
                // SizedBox(
                //   width: double.infinity,
                //   child: ElevatedButton.icon(
                //     onPressed: () => _openWhatsApp(
                //       counselor.whatsappNumber,
                //       counselor.name,
                //     ),
                //     icon: const Icon(Icons.chat_outlined),
                //     label: Text(AppStrings.counselorWhatsApp),
                //     style: ElevatedButton.styleFrom(
                //       padding: const EdgeInsets.symmetric(vertical: 16),
                //       backgroundColor: const Color(0xFF25D366), // WhatsApp green
                //     ),
                //   ),
                // )
                //     .animate()
                //     .fadeIn(delay: 700.ms, duration: 400.ms)
                //     .slideX(begin: -0.2, end: 0),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mediumGray,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

