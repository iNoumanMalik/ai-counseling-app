import 'package:go_router/go_router.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/discovery/screens/discovery_screen.dart';
import '../../features/discovery/screens/counselor_detail_screen.dart';
import '../../features/discovery/screens/counselor_category_screen.dart';
import '../../features/breathing/screens/breathing_screen.dart';
import '../../features/journal/screens/journal_screen.dart';
import '../../features/journal/screens/journal_entry_screen.dart';
import '../../features/habits/screens/habits_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/meditation/screens/meditation_screen.dart';
import '../../features/crisis/screens/sos_screen.dart';
import '../../features/worksheets/screens/worksheets_screen.dart';
import '../../features/worksheets/screens/worksheet_detail_screen.dart';
import '../../features/checkin/screens/checkin_screen.dart';
import '../../features/onboarding/screens/onboarding_complete_screen.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';

/// App routing configuration - routes only (no GoRouter instance)
  final appRoutes = [
    GoRoute(
      path: '/auth/signin',
      name: 'signin',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/auth/signup',
      name: 'signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/onboarding/complete',
      name: 'onboarding-complete',
      builder: (context, state) => const OnboardingCompleteScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/discovery',
      name: 'discovery',
      builder: (context, state) => const DiscoveryScreen(),
    ),
    GoRoute(
      path: '/discovery/category/:category',
      name: 'category',
      builder: (context, state) {
        final category = state.pathParameters['category']!;
        return CounselorCategoryScreen(category: category);
      },
    ),
    GoRoute(
      path: '/discovery/counselor/:id',
      name: 'counselor-detail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return CounselorDetailScreen(counselorId: id);
      },
    ),
    GoRoute(
      path: '/breathing',
      name: 'breathing',
      builder: (context, state) => const BreathingScreen(),
    ),
    GoRoute(
      path: '/journal',
      name: 'journal',
      builder: (context, state) => const JournalScreen(),
    ),
    GoRoute(
      path: '/journal/new',
      name: 'journal-new',
      builder: (context, state) => const JournalEntryScreen(),
    ),
    GoRoute(
      path: '/journal/:id',
      name: 'journal-entry',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return JournalEntryScreen(entryId: id);
      },
    ),
    GoRoute(
      path: '/habits',
      name: 'habits',
      builder: (context, state) => const HabitsScreen(),
    ),
    GoRoute(
      path: '/meditation',
      name: 'meditation',
      builder: (context, state) => const MeditationScreen(),
    ),
    GoRoute(
      path: '/worksheets',
      name: 'worksheets',
      builder: (context, state) => const WorksheetsScreen(),
    ),
    GoRoute(
      path: '/worksheets/:id',
      name: 'worksheet-detail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return WorksheetDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/checkin',
      name: 'checkin',
      builder: (context, state) => const CheckinScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/sos',
      name: 'sos',
      builder: (context, state) => const SosScreen(),
    ),
  ];

/// App router instance (deprecated - use routes directly)
@Deprecated('Use appRoutes instead')
final appRouter = GoRouter(routes: appRoutes);

