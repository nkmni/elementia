import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../data/element_data.dart'; // Added import
import '../widgets/glass_container.dart';
import '../theme/app_theme.dart';

import '../widgets/periodic_table_grid.dart';

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
          // Header Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Find It', style: TextStyle(color: !state.isRecallMode ? AppTheme.accentPrimary : Colors.white54)),
              Switch(
                value: state.isRecallMode, 
                onChanged: (val) => context.read<AppState>().toggleFindMode(),
                activeColor: Colors.blueAccent,
              ),
              Text('Recall It', style: TextStyle(color: state.isRecallMode ? Colors.blueAccent : Colors.white54)),
            ],
          ),
          const SizedBox(height: 16),
          
          if (!state.isRecallMode) ...[
            // Find It Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Find: ', style: TextStyle(fontSize: 24)),
                Text('${target.name} (${target.symbol})', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.accentPrimary)),
              ],
            ),
          ] else ...[
            // Recall Header
            const Text('What element is highlighted?', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            SizedBox(
              width: 200,
              child: TextField(
                autofocus: true,
                onSubmitted: (val) {
                  context.read<AppState>().checkRecallAnswer(val);
                },
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: 'Symbol',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white12,
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          // Fixed height feedback
          SizedBox(
            height: 32,
            child: Center(
              child: Text(state.findMessage, style: const TextStyle(fontSize: 24, color: AppTheme.accentSecondary)),
            ),
          ),
          
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: PeriodicTableGrid(
                      isRecallMode: state.isRecallMode,
                      target: target,
                      foundAtomicNumbers: state.foundAtomicNumbers,
                    ),
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
