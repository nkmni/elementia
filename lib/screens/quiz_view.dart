import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/glass_container.dart';
import '../theme/app_theme.dart';

class QuizView extends StatelessWidget {
  const QuizView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final q = state.currentQuizQuestion;

    if (q == null) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('Score: ${state.quizScore}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 48),
          const Text('What matches this element?', style: TextStyle(fontSize: 18, color: Colors.white60)),
          const SizedBox(height: 16),
          // We only show one property (Symbol or Name) based on what the options ARE NOT
          // If options are Names, show Symbol.
          Text(
            state.quizOptions.contains(q.name) ? q.symbol : q.name,
            style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: AppTheme.accentPrimary),
          ),
          const SizedBox(height: 48),
          
          if (state.quizFeedback.isNotEmpty)
            Text(state.quizFeedback, style: const TextStyle(fontSize: 24, color: AppTheme.accentSecondary)),

          const SizedBox(height: 24),
          
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
              children: state.quizOptions.map((opt) {
                return GlassContainer(
                  onTap: () => context.read<AppState>().answerQuiz(opt),
                  child: Center(
                    child: Text(opt, style: const TextStyle(fontSize: 20)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
