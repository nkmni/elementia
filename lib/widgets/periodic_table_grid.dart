import 'package:flutter/material.dart';
import '../../data/element_data.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
import 'package:provider/provider.dart';

class PeriodicTableGrid extends StatelessWidget {
  final bool isRecallMode;
  final ElementData? target;
  final Set<int> foundAtomicNumbers;

  const PeriodicTableGrid({
    super.key,
    required this.isRecallMode,
    required this.target,
    required this.foundAtomicNumbers,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    
    return SizedBox(
      width: 1000,
      child: Column(
        children: [
          // Main Body (18x7)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 18,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 18 * 7, 
            itemBuilder: (context, index) {
              final row = index ~/ 18;
              final col = index % 18;
              final p = row + 1;
              final g = col + 1;
              
              // Standard periodic table holes
              if (p == 1 && (g > 1 && g < 18)) return const SizedBox.shrink();
              if ((p == 2 || p == 3) && (g > 2 && g < 13)) return const SizedBox.shrink();
              
              final el = state.elements.firstWhere(
                (e) => e.period == p && e.group == g,
                orElse: () => ElementData(atomicNumber: -1, symbol: '', name: '', atomicMass: '', category: '', period: 0, oxidationStates: [], summary: '', electronicConfiguration: ''),
              );
              
              if (el.atomicNumber == -1) return const SizedBox.shrink();
              
              return _buildCell(context, el, isRecallMode, target, foundAtomicNumbers);
            },
          ),
          const SizedBox(height: 16),
          // F-Block (Lanthanides)
          const Text('Lanthanides (58-71)', style: TextStyle(color: Colors.white54, fontSize: 10)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: state.elements
                .where((e) => e.atomicNumber >= 58 && e.atomicNumber <= 71)
                .map((e) => SizedBox(
                      width: 45,
                      height: 45,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: _buildCell(context, e, isRecallMode, target, foundAtomicNumbers),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // F-Block (Actinides)
          const Text('Actinides (90-103)', style: TextStyle(color: Colors.white54, fontSize: 10)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: state.elements
                .where((e) => e.atomicNumber >= 90 && e.atomicNumber <= 103)
                .map((e) => SizedBox(
                      width: 45,
                      height: 45,
                      child: Padding(
                         padding: const EdgeInsets.all(2.0),
                         child: _buildCell(context, e, isRecallMode, target, foundAtomicNumbers),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(BuildContext context, ElementData el, bool isRecall, ElementData? target, Set<int> found) {
    bool isFound = found.contains(el.atomicNumber);
    bool isTarget = target?.atomicNumber == el.atomicNumber;
    
    String content = el.atomicNumber.toString();
    if (isFound) content = el.symbol;
    
    Color color = Colors.white10;
    if (isFound) color = AppTheme.accentPrimary.withOpacity(0.3);
    
    if (isRecall && isTarget) {
      color = Colors.blueAccent.withOpacity(0.6); 
      content = '?'; 
    }

    // Barrier Logic
    bool showBarrier = (el.atomicNumber == 57 || el.atomicNumber == 89);

    return GestureDetector(
      onTap: () => context.read<AppState>().checkFindItLocation(el.atomicNumber),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white24),
            ),
            child: Center(
              child: Text(content, style: const TextStyle(fontSize: 10, color: Colors.white70)),
            ),
          ),
          if (showBarrier)
            Positioned(
              right: -3, 
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: Colors.amberAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
