import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'config/theme.dart';
import 'config/colors.dart';
import 'core/navigation/app_router.dart';
import 'core/utils/storage_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // This is auto-generated
import 'services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  try {
  UserCredential userCred = await FirebaseAuth.instance.signInAnonymously();
  print('Signed in anonymously as: ${userCred.user?.uid}');
} catch (e) {
  print('Anonymous sign-in failed: $e');
}

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}


class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final Future<String> _initialLocation;

  @override
  void initState() {
    super.initState();
    _initAuth();
    _initialLocation = _getInitialLocation();
  }

  void _initAuth() {
    // Ensure an authenticated user exists (anonymous sign-in)
    // Do not block UI; sign-in happens in background
    final auth = ref.read(authServiceProvider);
    auth.ensureSignedIn();
  }

  Future<String> _getInitialLocation() async {
    final isOnboardingComplete = await StorageService.isOnboardingComplete();
    return isOnboardingComplete ? '/home' : '/onboarding';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _initialLocation,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return MaterialApp(
            home: Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.backgroundGradient,
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          );
        }

        final router = GoRouter(
          initialLocation: snapshot.data!,
          routes: appRoutes,
        );

        return MaterialApp.router(
          title: 'MindWell',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: router,
        );
      },
    );
  }
}
