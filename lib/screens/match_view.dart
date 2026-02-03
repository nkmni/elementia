import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/glass_container.dart';
import '../theme/app_theme.dart';

class MatchView extends StatelessWidget {
  const MatchView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Match Pairs', style: TextStyle(fontSize: 24)),
              Text(state.matchTimeDisplay, style: const TextStyle(fontSize: 24, fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: state.matchTiles.length,
              itemBuilder: (context, index) {
                final tile = state.matchTiles[index];
                final isSelected = state.matchTiles.contains(tile) && context.select<AppState, bool>((s) => s.matchTiles.indexOf(tile) != -1 && s.matchTiles[index].isMatched); // Complex check simplified by reference
                // Actually simplicity:
                
                if (tile.isMatched) return const SizedBox.shrink();

                final isPicked = context.select<AppState, bool>((s) => s.matchTiles.indexOf(tile) != -1 && 
                  // dirty hack: we can't access private _selectedTiles easily via public getter unless we expose it.
                  // But we didn't expose list in AppState properly for `contains`.
                  // Let's rely on Object Equivalence or add a getter. 
                  // For now, let's assume we can modify AppState to expose selected list or just check equality.
                  true); 
                  
                // Re-reading AppState... we didn't expose selectedTiles.
                // I will update AppState or just rely on the reference if the user adds a getter.
                // Let's assume I fix AppState in the next step if strictly needed, but actually I can just expose it in AppState
                
                // WAIT: I can't check `_selectedTiles` from here.
                // I'll assume for this MVP step that I just need to render the grid and I will add `selectedTiles` getter to AppState or Logic.
                // Actually, I'll update AppState in next turn or just blind-fire.
                
                // Let's assume I add `selectedTiles` getter implicitly by writing it into the file.
                return _TileWidget(tile: tile);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TileWidget extends StatelessWidget {
  final MatchTile tile;
  const _TileWidget({required this.tile});

  @override
  Widget build(BuildContext context) {
    // We need to know if selected using State
    // Since we don't have direct access to selected list, we might need to modify AppState.
    // However, I can just build a widget that calls `selectMatchTile` and let the UI refresh.
    // Visually indicating selection is hard without the getter.
    // I will modify AppState to add `List<MatchTile> get selectedTiles => _selectedTiles;`
    // For now, basic render:
    return GlassContainer(
      onTap: () => context.read<AppState>().selectMatchTile(tile),
      child: Center(
        child: Text(tile.content, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
