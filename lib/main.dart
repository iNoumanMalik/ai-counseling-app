import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'config/theme.dart';
import 'config/colors.dart';
import 'core/navigation/app_router.dart';
import 'core/utils/storage_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // This is auto-generated


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
    _initialLocation = _getInitialLocation();
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
