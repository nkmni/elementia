import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard.dart';
// Import activity screens
import 'screens/flashcards_view.dart';
import 'screens/quiz_view.dart';
import 'screens/match_view.dart';
import 'screens/find_it_view.dart';
import 'screens/trend_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const ElementiaApp(),
    ),
  );
}

class ElementiaApp extends StatelessWidget {
  const ElementiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Elementia',
      theme: AppTheme.darkTheme,
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      body: Stack(
        children: [
          // Background Blobs
          const Positioned(top: -100, left: -100, child: Blob(color: AppTheme.accentPrimary, size: 400)),
          const Positioned(bottom: -100, right: -100, child: Blob(color: AppTheme.accentSecondary, size: 300)),
          
          SafeArea(
            child: Column(
              children: [
                const AppHeader(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _getView(state.currentMode),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getView(AppMode mode) {
    switch (mode) {
      case AppMode.flashcards: return const FlashcardsView();
      case AppMode.quiz: return const QuizView();
      case AppMode.match: return const MatchView();
      case AppMode.findIt: return const FindItView();
      case AppMode.trend: return const TrendView();
      default: return const Dashboard();
    }
  }
}

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Elementia', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: () => context.read<AppState>().setMode(AppMode.dashboard),
            child: const Text('Dashboard'),
          ),
        ],
      ),
    );
  }
}

class Blob extends StatelessWidget {
  final Color color;
  final double size;
  const Blob({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(size),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.4), blurRadius: 100, spreadRadius: 50),
        ],
      ),
    );
  }
}
