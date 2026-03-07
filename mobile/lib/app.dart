import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/hadith/hadith_detail_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/mosque/mosque_screen.dart';
import 'presentation/screens/qibla/qibla_screen.dart';
import 'presentation/screens/quran/quran_screen.dart';
import 'presentation/screens/quran/surah_detail_screen.dart';
import 'presentation/screens/ramadan/ramadan_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/widgets/bottom_nav_bar.dart';

class MuazzinApp extends ConsumerWidget {
  const MuazzinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final locale = Locale(settings.language);

    return MaterialApp.router(
      title: 'মুয়াজ্জিন',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: switch (settings.theme) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      locale: locale,
      supportedLocales: const [Locale('bn'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
    );
  }
}

// ── Router ────────────────────────────────────────────────────────────────────

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/qibla',
          builder: (context, state) => const QiblaScreen(),
        ),
        GoRoute(
          path: '/mosque',
          builder: (context, state) => const MosqueScreen(),
        ),
        GoRoute(
          path: '/quran',
          builder: (context, state) => const QuranScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/quran/:surahId',
      builder: (context, state) {
        final surahId = int.parse(state.pathParameters['surahId'] ?? '1');
        return SurahDetailScreen(surahNumber: surahId);
      },
    ),
    GoRoute(
      path: '/hadith/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id'] ?? '1');
        return HadithDetailScreen(hadithId: id);
      },
    ),
    GoRoute(
      path: '/ramadan',
      builder: (context, state) => const RamadanScreen(),
    ),
  ],
);

// ── Main scaffold with bottom nav ─────────────────────────────────────────────

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _currentIndex = 0;

  static const _routes = ['/', '/qibla', '/mosque', '/quran', '/settings'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: MuazzinBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          context.go(_routes[index]);
        },
      ),
    );
  }
}
