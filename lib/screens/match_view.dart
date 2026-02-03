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
                if (tile.isMatched) return const SizedBox.shrink();

                final isSelected = context.select<AppState, bool>((s) => s.selectedMatchTiles.contains(tile));

                return _TileWidget(tile: tile, isSelected: isSelected);
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
  final bool isSelected;
  const _TileWidget({required this.tile, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      onTap: () => context.read<AppState>().selectMatchTile(tile),
      // Highlight if selected
      padding: EdgeInsets.zero, // Custom padding
      child: Container(
        decoration: BoxDecoration(
           color: isSelected ? AppTheme.accentPrimary.withOpacity(0.3) : Colors.transparent,
           borderRadius: BorderRadius.circular(16),
           border: isSelected ? Border.all(color: AppTheme.accentPrimary, width: 2) : null,
        ),
        child: Center(
          child: Text(tile.content, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
