import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../data/element_data.dart'; // Added import
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
                           
                           // Check if valid coord
                           // Standard periodic table holes:
                           // Period 1: Only G1, G18
                           if (p == 1 && (g > 1 && g < 18)) return const SizedBox.shrink();
                           // Period 2,3: Only G1,2 and G13-18
                           if ((p == 2 || p == 3) && (g > 2 && g < 13)) return const SizedBox.shrink();
                           
                           final el = state.elements.firstWhere(
                             (e) => e.period == p && e.group == g,
                             orElse: () => ElementData(atomicNumber: -1, symbol: '', name: '', atomicMass: '', category: '', period: 0, oxidationStates: [], summary: '', electronicConfiguration: ''),
                           );
                           
                           if (el.atomicNumber == -1) return const SizedBox.shrink();

                           return _ElementCell(
                             symbol: el.atomicNumber.toString(), 
                             color: Colors.white10,
                             onTap: () => context.read<AppState>().checkFindItLocation(el.atomicNumber),
                           );
                         },
                       ),
                       const SizedBox(height: 16),
                       // F-Block (Lanthanides/Actinides)
                       // Just a simple row for now as we might not have full data, but logic supports it
                       const Text('Lanthanides & Actinides', style: TextStyle(color: Colors.white54)),
                       const SizedBox(height: 8),
                       Wrap(
                         spacing: 4,
                         runSpacing: 4,
                         alignment: WrapAlignment.center,
                         children: state.elements.where((e) => state.isFBlock(e)).map((e) {
                           return SizedBox(
                             width: 45, // approx grid cell width
                             height: 45,
                             child: _ElementCell(
                               symbol: e.atomicNumber.toString(),
                               color: Colors.white10,
                               onTap: () => context.read<AppState>().checkFindItLocation(e.atomicNumber),
                             ),
                           );
                         }).toList(),
                       )
                     ],
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

class _ElementCell extends StatelessWidget {
  final String symbol;
  final Color color;
  final VoidCallback onTap;

  const _ElementCell({required this.symbol, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white24),
        ),
        child: Center(
          child: Text(symbol, style: const TextStyle(fontSize: 10, color: Colors.white70)),
        ),
      ),
    );
  }
}
