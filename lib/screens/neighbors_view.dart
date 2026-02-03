import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/glass_container.dart';
import '../theme/app_theme.dart';

class NeighborsView extends StatelessWidget {
  const NeighborsView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final target = state.neighborTarget;
    
    if (target == null) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: SizedBox(
          width: 500,
          child: Column(
            children: [
               const Text('ORBIT MODE', style: TextStyle(fontSize: 12, letterSpacing: 2, color: AppTheme.accentTertiary)),
               const SizedBox(height: 8),
               const Text('Identify the surrounding elements', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
               const SizedBox(height: 32),
               
               // 3x3 Grid
               AspectRatio(
                 aspectRatio: 1,
                 child: GridView.count(
                   key: ValueKey(target.atomicNumber), // Force rebuild to clear inputs
                   crossAxisCount: 3,
                   crossAxisSpacing: 16,
                   mainAxisSpacing: 16,
                   children: [
                     _buildInputSlot(context, state, 0, autofocus: true), // TL - Start Here
                     _buildInputSlot(context, state, 1), // T
                     _buildInputSlot(context, state, 2), // TR
                     
                     _buildInputSlot(context, state, 3), // L
                     _buildTarget(target),               // Center (Not an input)
                     _buildInputSlot(context, state, 4), // R
                     
                     _buildInputSlot(context, state, 5), // BL
                     _buildInputSlot(context, state, 6), // B
                     _buildInputSlot(context, state, 7), // BR
                   ],
                 ),
               ),
               
               const SizedBox(height: 24),
               Text(state.neighborFeedback, style: const TextStyle(fontSize: 20, color: AppTheme.accentSecondary, fontWeight: FontWeight.bold)),
               const SizedBox(height: 16),
               ElevatedButton(
                 onPressed: () => context.read<AppState>().checkNeighbors(),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: AppTheme.accentPrimary,
                   foregroundColor: Colors.white,
                   padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                 ),
                 child: const Text('CHECK ORBIT'),
               ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTarget(var e) {
    return GlassContainer(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${e.atomicNumber}', style: const TextStyle(fontSize: 14, color: Colors.white54)),
            const SizedBox(height: 4),
            Text(e.symbol, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.accentPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSlot(BuildContext context, AppState state, int index, {bool autofocus = false}) {
    final result = state.neighborResults[index];
    Color? borderColor;
    if (result == true) borderColor = Colors.green;
    if (result == false) borderColor = Colors.red;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: borderColor != null ? Border.all(color: borderColor, width: 2) : Border.all(color: Colors.white12),
      ),
      child: Stack(
        children: [
          Center(
            child: TextField(
              autofocus: autofocus,
              textInputAction: index == 7 ? TextInputAction.done : TextInputAction.next,
              onChanged: (val) => context.read<AppState>().updateNeighborInput(index, val),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, shadows: [Shadow(color: Colors.blueAccent, blurRadius: 10)]),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '?',
                hintStyle: TextStyle(color: Colors.white12),
              ),
            ),
          ),
          if (result == false)
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Text(
                state.correctNeighbors[index]?.symbol ?? 'Empty',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
