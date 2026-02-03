import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/glass_container.dart';
import 'package:animate_do/animate_do.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          FadeInDown(
            child: const Column(
              children: [
                Text(
                  'Master the Elements',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Choose a mode to start your mastery journey.',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  _ModeCard(
                    icon: '🗂️',
                    title: 'Flashcards',
                    desc: 'Memorize properties with flipped cards.',
                    onTap: () => context.read<AppState>().setMode(AppMode.flashcards),
                  ),
                  _ModeCard(
                    icon: '📝',
                    title: 'Quiz Mode',
                    desc: 'Test your knowledge with multiple choice.',
                    onTap: () => context.read<AppState>().setMode(AppMode.quiz),
                  ),
                   _ModeCard(
                    icon: '🪐',
                    title: 'Orbit Mode',
                    desc: 'Identify surrounding neighbors.',
                    onTap: () => context.read<AppState>().setMode(AppMode.neighbors),
                  ),
                  _ModeCard(
                    icon: '🧩',
                    title: 'Match Game',
                    desc: 'Race against the clock to pair items.',
                    onTap: () => context.read<AppState>().setMode(AppMode.match),
                  ),
                  _ModeCard(
                    icon: '📍',
                    title: 'Find It!',
                    desc: 'Locate elements on the blank table.',
                    onTap: () => context.read<AppState>().setMode(AppMode.findIt),
                  ),
                   _ModeCard(
                    icon: '📈',
                    title: 'Trend Master',
                    desc: 'Compare atomic properties.',
                    onTap: () => context.read<AppState>().setMode(AppMode.trend),
                  ),
                ],
              );
            }
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String icon;
  final String title;
  final String desc;
  final VoidCallback onTap;

  const _ModeCard({required this.icon, required this.title, required this.desc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: SizedBox(
        width: 300,
        child: GlassContainer(
          onTap: onTap,
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(desc, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
