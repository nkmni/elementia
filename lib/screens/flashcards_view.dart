import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../state/app_state.dart';
import '../widgets/glass_container.dart';
import '../theme/app_theme.dart';

class FlashcardsView extends StatelessWidget {
  const FlashcardsView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text('Card ${state.flashcardIndex + 1} / ${state.elements.length}', 
              style: const TextStyle(fontSize: 18, color: Colors.white60)),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () => context.read<AppState>().flipFlashcard(),
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: state.isFlipped ? 180 : 0),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, double val, child) {
                    final isBack = val >= 90;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(val * pi / 180),
                      child: isBack
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(pi),
                              child: _buildBack(state.currentFlashcard),
                            )
                          : _buildFront(state.currentFlashcard),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: state.flashcardIndex > 0 ? () => context.read<AppState>().prevFlashcard() : null,
                icon: const Icon(Icons.arrow_back_ios),
              ),
              const SizedBox(width: 32),
              IconButton(
                onPressed: state.flashcardIndex < state.elements.length - 1 ? () => context.read<AppState>().nextFlashcard() : null,
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFront(var item) {
    return SizedBox(
      width: 400,
      height: 500,
      child: GlassContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${item.atomicNumber}', style: const TextStyle(fontSize: 24, color: Colors.white54)),
            const SizedBox(height: 24),
            Text(item.symbol, style: const TextStyle(fontSize: 96, fontWeight: FontWeight.bold, color: AppTheme.accentPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildBack(var item) {
    return SizedBox(
      width: 400,
      height: 500,
      child: GlassContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(item.name, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('${item.atomicMass} u', style: const TextStyle(fontSize: 24, color: Colors.white70)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(item.category.toUpperCase(), style: const TextStyle(letterSpacing: 1.5)),
            ),
          ],
        ),
      ),
    );
  }
}
