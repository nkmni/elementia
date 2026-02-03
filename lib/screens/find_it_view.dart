import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/glass_container.dart';
import '../theme/app_theme.dart';

class FindItView extends StatelessWidget {
  const FindItView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final target = state.findTarget;

    if (target == null) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Find: ', style: TextStyle(fontSize: 24)),
              Text('${target.name} (${target.symbol})', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.accentPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          if (state.findMessage.isNotEmpty)
            Text(state.findMessage, style: const TextStyle(fontSize: 24, color: AppTheme.accentSecondary)),
          
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                   width: 1000,
                   // Grid representation
                   child: GridView.builder(
                     physics: const NeverScrollableScrollPhysics(),
                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                       crossAxisCount: 18,
                       crossAxisSpacing: 2,
                       mainAxisSpacing: 2,
                     ),
                     itemCount: 18 * 10, // 18 groups x 10 rows (approx)
                     itemBuilder: (context, index) {
                       // Map index to Group/Period
                       final row = index ~/ 18; // 0-based period index (roughly)
                       final col = index % 18;  // 0-based group index
                       
                       // Simple mapping: Period = row + 1, Group = col + 1
                       final p = row + 1;
                       final g = col + 1;
                       
                       // Check if an element exists at this coordinate
                       final el = state.elements.firstWhere(
                         (e) => e.period == p && e.group == g,
                         orElse: () => state.elements[0], // fallback
                       );
                       
                       // Hacky check if it's actually that element (by checking if we found default and if default matches coords)
                       // Better: use `where` and check length
                       final exists = state.elements.any((e) => e.period == p && e.group == g);
                       
                       if (!exists) return const SizedBox.shrink(); // Empty space
                       
                       final actualEl = state.elements.firstWhere((e) => e.period == p && e.group == g);

                       return GestureDetector(
                         onTap: () => context.read<AppState>().checkFindItLocation(actualEl.atomicNumber),
                         child: Container(
                           decoration: BoxDecoration(
                             color: Colors.white10,
                             border: Border.all(color: Colors.white24),
                             borderRadius: BorderRadius.circular(2),
                           ),
                           // Intentionally empty or just number? Game is "Find It" so usually blank or number.
                           // Let's show nothing to make it harder, or just atomic number?
                           // Walkthrough said "Blank Table".
                         ),
                       );
                     },
                   ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
