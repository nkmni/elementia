import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/glass_container.dart';
import '../theme/app_theme.dart';

class TrendView extends StatelessWidget {
  const TrendView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.trendPair.length < 2) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('Streak: ${state.trendStreak}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 48),
          const Text('Which has the HIGHER:', style: TextStyle(fontSize: 18, color: Colors.white60)),
          Text(
             state.trendProperty == 'electronegativity' ? 'Electronegativity' : 'Atomic Mass',
             style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.accentTertiary),
          ),
          const SizedBox(height: 48),
          
           if (state.trendFeedback.isNotEmpty)
            Text(state.trendFeedback, style: const TextStyle(fontSize: 24, color: AppTheme.accentSecondary)),

          const SizedBox(height: 24),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TrendCard(item: state.trendPair[0]),
                const SizedBox(width: 32),
                _TrendCard(item: state.trendPair[1]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final dynamic item;
  const _TrendCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<AppState>().answerTrend(item),
      child: SizedBox(
        width: 200,
        height: 300,
        child: GlassContainer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.symbol, style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(item.name, style: const TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
