import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'config/theme.dart';
import 'presentation/auth/auth_screen.dart';
import 'presentation/shell/app_shell.dart';
import 'presentation/onboarding/onboarding_screen.dart';
import 'l10n/app_localizations.dart';

final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error catching
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
    print('Platform: ${DefaultFirebaseOptions.currentPlatform.apiKey.substring(0, 10)}...');
  } catch (e) {
    print('Firebase init error: $e');
    runApp(ErrorApp(error: e.toString()));
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('language') ?? 'en';
  runApp(
    ProviderScope(
      overrides: [localeProvider.overrideWith((ref) => Locale(savedLang))],
      child: const UrPlantApp(),
    ),
  );
}

class ErrorApp extends StatelessWidget {
  final String error;
  const ErrorApp({super.key, required this.error});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Firebase Error', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(error, style: const TextStyle(fontSize: 14, color: Colors.red), textAlign: TextAlign.center),
            ]),
          ),
        ),
      ),
    );
  }
}

class UrPlantApp extends ConsumerWidget {
  const UrPlantApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp(
      title: 'UrPlant',
      debugShowCheckedModeBanner: false,
      theme: UrPlantTheme.light,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('km')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  Future<bool> _shouldShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_complete') != true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: _shouldShowOnboarding(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data == true) {
          return const OnboardingScreen();
        }
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (userSnapshot.hasData) return const AppShell();
            return const AuthScreen();
          },
        );
      },
    );
  }
}
