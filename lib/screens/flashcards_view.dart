import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/glass_container.dart';
import '../theme/app_theme.dart';

class FlashcardsView extends StatefulWidget {
  const FlashcardsView({super.key});

  @override
  State<FlashcardsView> createState() => _FlashcardsViewState();
}

class _FlashcardsViewState extends State<FlashcardsView> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _numCtrl = TextEditingController();
  String? _selectedCategory;

  final List<String> _categories = [
    'alkali metal', 'alkaline earth metal', 'transition metal', 
    'post-transition metal', 'metalloid', 'polyatomic nonmetal', 
    'diatomic nonmetal', 'noble gas', 'lanthanide', 'actinide'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final card = state.currentFlashcard;
    final isRevealed = state.isRevealed;

    // Use a constraining sized box to force compact height
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          children: [
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
               child: _buildHeader(state),
             ),
             Expanded(
               child: GlassContainer(
                 child: SingleChildScrollView( // Allow scroll if screen is tiny
                   padding: const EdgeInsets.all(16),
                   child: Column(
                     mainAxisSize: MainAxisSize.min, // Shrink wrap
                     children: [
                       // 1. The Question (Visible Side: Always Symbol)
                       Container(
                         width: double.infinity,
                         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                         decoration: BoxDecoration(
                           color: isRevealed 
                              ? AppTheme.accentPrimary.withOpacity(0.1)
                              : Colors.transparent,
                           borderRadius: BorderRadius.circular(16),
                           border: Border.all(color: Colors.white10),
                         ),
                         child: Column(
                           children: [
                             const Text('SYMBOL', 
                               style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: Colors.white54)),
                             const SizedBox(height: 4),
                             Text(
                               card.symbol,
                               style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: AppTheme.accentPrimary, height: 1.0),
                             ),
                           ],
                         ),
                       ),
                       const SizedBox(height: 12),
                       
                       // 2. Input Fields (or Answers if revealed)
                       if (!isRevealed) ...[
                         // Atomic Number Input
                         SizedBox(
                           width: 120,
                           child: _buildInput(controller: _numCtrl, label: 'Atomic #', centered: true),
                         ),
                         const SizedBox(height: 8),
                         
                         // Name Input
                         SizedBox(
                           width: 240,
                           child: _buildInput(controller: _nameCtrl, label: 'Element Name', centered: true),
                         ),
                         const SizedBox(height: 8),
                         
                         // Category Dropdown
                         SizedBox(
                           width: 240,
                           child: DropdownButtonFormField<String>(
                             value: _selectedCategory,
                             dropdownColor: Colors.grey[900],
                             decoration: InputDecoration(
                               labelText: 'Category',
                               labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                               filled: true,
                               fillColor: Colors.white12,
                               contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                             ),
                             style: const TextStyle(color: Colors.white, fontSize: 14),
                             items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase(), style: const TextStyle(fontSize: 11)))).toList(),
                             onChanged: (v) => setState(() => _selectedCategory = v),
                           ),
                         ),
                         const SizedBox(height: 16),
                         
                         ElevatedButton(
                           onPressed: () {
                             context.read<AppState>().submitFlashcardAnswer(
                               symbol: card.symbol,
                               name: _nameCtrl.text,
                               number: _numCtrl.text,
                               category: _selectedCategory,
                             );
                           },
                           style: ElevatedButton.styleFrom(
                             backgroundColor: AppTheme.accentPrimary,
                             foregroundColor: Colors.white,
                             minimumSize: const Size(180, 40),
                             elevation: 4,
                           ),
                           child: const Text('SUBMIT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                           ),
                       ] else ...[
                         // 3. Revealed Details
                         Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             _buildDetailBox(
                               label: 'ATOMIC #', 
                               value: '${card.atomicNumber}',
                               correct: _numCtrl.text.trim() == card.atomicNumber.toString()
                             ),
                             const SizedBox(width: 8),
                             Flexible(
                               child: _buildDetailBox(
                                 label: 'NAME', 
                                 value: card.name,
                                 correct: _nameCtrl.text.trim().toLowerCase() == card.name.toLowerCase()
                               ),
                             ),
                           ],
                         ),
                         const SizedBox(height: 8),
                         // Category Result
                         _buildDetailBox(
                           label: 'CATEGORY', 
                           value: card.category.toUpperCase(), 
                           correct: (_selectedCategory?.toLowerCase() ?? '') == card.category.toLowerCase()
                         ),
                         const SizedBox(height: 12),
                         
                         // Color & Visuals
                         Container(
                           padding: const EdgeInsets.all(8),
                           decoration: BoxDecoration(
                             color: Colors.white10,
                             borderRadius: BorderRadius.circular(12),
                           ),
                           child: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               Container(
                                 width: 28, height: 28,
                                 decoration: BoxDecoration(
                                   shape: BoxShape.circle,
                                   color: _parseColor(card.hexColor),
                                   border: Border.all(color: Colors.white24, width: 2),
                                   boxShadow: [BoxShadow(color: _parseColor(card.hexColor).withOpacity(0.4), blurRadius: 10)],
                                 ),
                               ),
                               const SizedBox(width: 8),
                               Flexible(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     const Text('APPEARANCE', style: TextStyle(fontSize: 8, color: Colors.white54)),
                                     Text(card.colorDescription ?? 'Unknown', style: const TextStyle(fontSize: 12)),
                                   ],
                                 ),
                               ),
                             ],
                           ),
                         ),
                         const SizedBox(height: 16),
                         ElevatedButton(
                           onPressed: () {
                             _nameCtrl.clear();
                             _numCtrl.clear();
                             setState(() => _selectedCategory = null);
                             context.read<AppState>().nextFlashcard();
                           },
                           style: ElevatedButton.styleFrom(
                             backgroundColor: Colors.white24,
                             foregroundColor: Colors.white,
                             minimumSize: const Size(180, 40),
                           ),
                           child: const Text('NEXT CARD'),
                         ),
                       ],
                     ],
                   ),
                 ),
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ACTIVE RECALL', style: TextStyle(fontSize: 10, color: AppTheme.accentTertiary)),
            Text('${state.sessionCorrect} / ${state.sessionTotal} Correct', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        IconButton(
          onPressed: () => context.read<AppState>().initFlashcards(), // Reset
          icon: const Icon(Icons.refresh, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        )
      ],
    );
  }

  Widget _buildInput({required TextEditingController controller, required String label, bool centered = false}) {
    return TextField(
      controller: controller,
      textAlign: centered ? TextAlign.center : TextAlign.start,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
        filled: true,
        fillColor: Colors.white12,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDetailBox({required String label, required String value, required bool correct}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: correct ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: correct ? Colors.green : Colors.red),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 8, color: Colors.white70)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null) return Colors.white;
    try {
      if (hex.startsWith('#')) hex = hex.substring(1);
      return Color(int.parse('0xFF$hex'));
    } catch (e) {
      return Colors.white;
    }
  }
}
