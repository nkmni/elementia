import 'package:flutter/foundation.dart';
import '../data/periodic_data.dart';
import '../data/element_data.dart';
import 'dart:async';

enum AppMode { dashboard, flashcards, quiz, match, findIt, trend, neighbors }

class AppState extends ChangeNotifier {
  final List<ElementData> elements = periodicTableData;
  AppMode _currentMode = AppMode.dashboard;
  AppMode get currentMode => _currentMode;

  // Flashcards (Active Recall)
  List<ElementData> _flashcardQueue = [];
  int _flashcardIndex = 0;
  bool _isRevealed = false;
  bool _showFrontName = true; // if true, show Name (ask Symbol/Num), else show Symbol (ask Name/Num)
  
  // User Inputs
  String _inputSymbol = '';
  String _inputName = '';
  String _inputNumber = '';
  String _inputCategory = '';
  
  // Session Stats
  int _sessionCorrect = 0;
  int _sessionTotal = 0;
  List<ElementData> _incorrectElements = [];

  ElementData get currentFlashcard => _flashcardQueue.isNotEmpty ? _flashcardQueue[_flashcardIndex] : elements[0];
  bool get isRevealed => _isRevealed;
  bool get showFrontName => _showFrontName;
  int get sessionCorrect => _sessionCorrect;
  int get sessionTotal => _sessionTotal;

  // Quiz
  int _quizScore = 0;
  ElementData? _currentQuizQuestion;
  String? _correctAnswer; // symbol or name
  List<String> _quizOptions = [];
  String _quizFeedback = '';
  List<ElementData> _quizQueue = [];
  final List<ElementData> _quizIncorrects = [];
  
  int get quizScore => _quizScore;
  ElementData? get currentQuizQuestion => _currentQuizQuestion;
  List<String> get quizOptions => _quizOptions;
  String get quizFeedback => _quizFeedback;

  // Match
  List<MatchTile> _matchTiles = [];
  List<MatchTile> _selectedTiles = [];
  int _matchedCount = 0;
  int _matchSeconds = 0;
  Timer? _matchTimer;
  
  List<MatchTile> get matchTiles => _matchTiles;
  List<MatchTile> get selectedMatchTiles => _selectedTiles;
  
  String get matchTimeDisplay {
    final m = (_matchSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_matchSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
  bool get isMatchGameComplete => _matchedCount == 8;

  // Find It
  ElementData? _findTarget;
  String _findMessage = '';
  bool _findSuccess = false;
  List<ElementData> _findQueue = [];
  final Set<int> _foundAtomicNumbers = {};
  
  ElementData? get findTarget => _findTarget;
  String get findMessage => _findMessage;
  bool get findSuccess => _findSuccess;
  Set<int> get foundAtomicNumbers => _foundAtomicNumbers;
  
  // Recall Mode
  bool _isRecallMode = false;
  String _recallFeedback = '';
  
  bool get isRecallMode => _isRecallMode;
  String get recallFeedback => _recallFeedback;

  // F-Block helper for Find It
  bool isFBlock(ElementData e) {
    // Lanthanides (57-71) & Actinides (89-103)
    return (e.atomicNumber >= 57 && e.atomicNumber <= 71) ||
           (e.atomicNumber >= 89 && e.atomicNumber <= 103);
  }

  // Trend Master
  int _trendStreak = 0;
  List<ElementData> _trendPair = [];
  String _trendProperty = 'electronegativity'; // or 'atomicMass'
  String _trendFeedback = '';
  
  int get trendStreak => _trendStreak;
  List<ElementData> get trendPair => _trendPair;
  String get trendProperty => _trendProperty;
  String get trendFeedback => _trendFeedback;

  // Neighbors Mode
  ElementData? _neighborTarget;
  List<ElementData?> _correctNeighbors = []; // 8 slots, null if empty
  List<String> _neighborInputs = List.filled(8, '');
  List<bool?> _neighborResults = List.filled(8, null); // null=unchecked, true=correct
  String _neighborFeedback = '';
  
  ElementData? get neighborTarget => _neighborTarget;
  List<ElementData?> get correctNeighbors => _correctNeighbors;
  List<String> get neighborInputs => _neighborInputs;
  List<bool?> get neighborResults => _neighborResults;
  String get neighborFeedback => _neighborFeedback;

  // --- ACTIONS ---

  void setMode(AppMode mode) {
    _currentMode = mode;
    _stopTimers();
    notifyListeners();
    if (mode == AppMode.flashcards) initFlashcards();
    if (mode == AppMode.quiz) _initQuiz();
    if (mode == AppMode.match) _initMatch();
    if (mode == AppMode.findIt) _initFindIt();
    if (mode == AppMode.findIt) _initFindIt();
    if (mode == AppMode.trend) _initTrend();
    if (mode == AppMode.neighbors) _initNeighbors();
  }

  void _stopTimers() {
    _matchTimer?.cancel();
  }

  // Flashcards Logic
  void initFlashcards() {
    _flashcardQueue = List.from(elements)..shuffle();
    _flashcardIndex = 0;
    _sessionCorrect = 0;
    _sessionTotal = 0;
    _incorrectElements = [];
    _setupNextCard();
  }

  void _setupNextCard() {
    _isRevealed = false;
    _showFrontName = false; // Always show Symbol first (User Request)
    _inputSymbol = '';
    _inputName = '';
    _inputNumber = '';
    _inputCategory = '';
    notifyListeners();
  }
  
  void submitFlashcardAnswer({required String symbol, required String name, required String number, String? category}) {
    _inputSymbol = symbol;
    _inputName = name;
    _inputNumber = number;
    _inputCategory = category ?? '';
    
    // Check (Gamified) verification can happen here or just record stats
    // We reveal first
    _isRevealed = true;
    
    // Auto-grade foundation
    bool correctSymbol = symbol.trim().toLowerCase() == currentFlashcard.symbol.toLowerCase();
    bool correctName = name.trim().toLowerCase() == currentFlashcard.name.toLowerCase();
    bool correctNum = number.trim() == currentFlashcard.atomicNumber.toString();
    
    // So we record accuracy here
    
    // Normalize Category (simple contains check or exact match)
    bool correctCategory = category != null && category.toLowerCase() == currentFlashcard.category.toLowerCase();

    if (correctSymbol && correctName && correctNum && correctCategory) {
       _sessionCorrect++;
    } else {
       _incorrectElements.add(currentFlashcard);
    }
    _sessionTotal++;
    
    notifyListeners();
  }

  void nextFlashcard() {
    if (_flashcardIndex < _flashcardQueue.length - 1) {
      _flashcardIndex++;
      _setupNextCard();
    } else {
      // Loop or Finish?
      initFlashcards(); // Restart for now
    }
  }

  // Quiz
  void _initQuiz() {
    _quizScore = 0;
    _quizIncorrects.clear();
    _quizQueue = List.from(elements)..shuffle();
    _nextQuizQuestion();
  }

  void _nextQuizQuestion() {
    _quizFeedback = '';
    
    if (_quizQueue.isEmpty) {
      if (_quizIncorrects.isNotEmpty) {
        // Focus on errors
        _quizQueue = List.from(_quizIncorrects)..shuffle();
        _quizIncorrects.clear();
      } else {
        // Reset full loop
        _quizQueue = List.from(elements)..shuffle();
      }
    }
    
    final target = _quizQueue.removeLast();
    _currentQuizQuestion = target;
    
    // Type: Symbol -> Name OR Name -> Symbol
    bool askName = (DateTime.now().millisecond % 2 == 0);
    List<String> options = [];
    
    if (askName) {
      _correctAnswer = target.name;
      options = _generateDistractors(target, (e) => e.name);
    } else {
      _correctAnswer = target.symbol;
      options = _generateDistractors(target, (e) => e.symbol);
    }
    options.add(_correctAnswer!);
    options.shuffle();
    _quizOptions = options;
    notifyListeners();
  }

  List<String> _generateDistractors(ElementData target, String Function(ElementData) extractor) {
     final candidates = elements.where((e) => e.atomicNumber != target.atomicNumber).toList();
     
     // Similarity Score
     int score(ElementData cand) {
       int s = 0;
       
       final tVal = extractor(target);
       final cVal = extractor(cand);
       
       // Lexical: Starts with same letter?
       if (tVal.isNotEmpty && cVal.isNotEmpty && tVal[0] == cVal[0]) s += 3;
       // Lexical: Starts with same 2 letters?
       if (tVal.length > 1 && cVal.length > 1 && tVal.substring(0, 2) == cVal.substring(0, 2)) s += 2;
       
       // Chemical: Group (Vertical)
       if (cand.group != null && target.group != null && cand.group == target.group) s += 2;
       
       // Chemical: Period (Horizontal) - neighbors
       if (cand.period == target.period) s += 1;
       
       return s;
     }

     // Shuffle first to ensure variety if scores tie
     candidates.shuffle();
     
     // Sort by Score Descending
     candidates.sort((a, b) => score(b).compareTo(score(a))); 
     
     // Top 3
     return candidates.take(3).map(extractor).toList();
  }

  void answerQuiz(String answer) {
    if (_quizFeedback.isNotEmpty) return; // already answered
    if (answer == _correctAnswer) {
      _quizScore += 10;
      _quizFeedback = 'Correct!';
    } else {
      _quizFeedback = 'Wrong! It was $_correctAnswer';
      _quizIncorrects.add(_currentQuizQuestion!);
    }
    notifyListeners();
    Future.delayed(const Duration(seconds: 1), _nextQuizQuestion);
  }

  // Match
  void _initMatch() {
    _matchSeconds = 0;
    _matchedCount = 0;
    _selectedTiles.clear();
    
    
    // Pick 8 pair
    final subset = (List.of(elements)..shuffle()).take(8).toList();
    _matchTiles = [];
    for (var e in subset) {
      _matchTiles.add(MatchTile(id: e.atomicNumber, content: e.symbol, isSymbol: true));
      _matchTiles.add(MatchTile(id: e.atomicNumber, content: e.name, isSymbol: false));
    }
    _matchTiles.shuffle();
    
    _matchTimer?.cancel();
    _matchTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      _matchSeconds++;
      notifyListeners();
    });
  }

  void selectMatchTile(MatchTile tile) {
    if (tile.isMatched || _selectedTiles.contains(tile) || _selectedTiles.length >= 2) return;
    
    _selectedTiles.add(tile);
    notifyListeners();

    if (_selectedTiles.length == 2) {
      _checkMatch();
    }
  }

  void _checkMatch() {
    final t1 = _selectedTiles[0];
    final t2 = _selectedTiles[1];
    
    if (t1.id == t2.id) {
       // Match
       Future.delayed(const Duration(milliseconds: 300), () {
         t1.isMatched = true;
         t2.isMatched = true;
         _matchedCount++;
         _selectedTiles.clear();
         if (_matchedCount == 8) _matchTimer?.cancel();
         notifyListeners();
       });
    } else {
      // No Match
      Future.delayed(const Duration(milliseconds: 800), () {
        _selectedTiles.clear();
        notifyListeners();
      });
    }
  }
  
  // Find It
  void _initFindIt() {
    _foundAtomicNumbers.clear();
    _findQueue = List.from(elements)..shuffle();
    _nextFindTarget();
  }

  void _nextFindTarget() {
    if (_findQueue.isEmpty) {
       _findQueue = List.from(elements)..shuffle(); // MVP: Just loop all, or we could track find errors too
    }
    _findTarget = _findQueue.removeLast();
    _findMessage = '';
    _findSuccess = false;
    notifyListeners();
  }

  void toggleFindMode() {
    _isRecallMode = !_isRecallMode;
    _findMessage = '';
    _recallFeedback = '';
    // Reset queues optionally? nah.
    // If switching to Recall, we need a target. _findTarget works as Recall Target too.
    notifyListeners();
  }

  void checkFindItLocation(int atomicNumber) {
    if (_isRecallMode) return; // In Recall mode, tapping does nothing (or focuses?)
    
    if (_findSuccess) return;
    if (atomicNumber == _findTarget!.atomicNumber) {
      _findMessage = 'Correct! 🎉';
      _findSuccess = true;
      _foundAtomicNumbers.add(atomicNumber);
      notifyListeners();
      Future.delayed(const Duration(seconds: 1), _nextFindTarget);
    } else {
      _findMessage = 'Try Again!';
      notifyListeners();
    }
  }
  
  void checkRecallAnswer(String input) {
    if (!_isRecallMode || _findSuccess) return;
    
    if (input.trim().toLowerCase() == _findTarget!.symbol.toLowerCase()) {
      _findMessage = 'Correct! It was ${_findTarget!.name}';
      _findSuccess = true;
      _foundAtomicNumbers.add(_findTarget!.atomicNumber);
      notifyListeners();
      Future.delayed(const Duration(seconds: 1), _nextFindTarget);
    } else {
      _findMessage = 'Wrong!';
      notifyListeners();
    }
  }

  // Trend Master
  void _initTrend() {
    _trendStreak = 0;
    _nextTrend();
  }

  void _nextTrend() {
    _trendFeedback = '';
    _trendProperty = (DateTime.now().second % 2 == 0) ? 'electronegativity' : 'atomicMass';
    
    final valid = elements.where((e) {
      if (_trendProperty == 'electronegativity') return e.electronegativity != null;
      return true; // atomic mass exists for all
    }).toList();
    
    valid.shuffle();
    if (valid.length < 2) return;
    _trendPair = [valid[0], valid[1]];
    notifyListeners();
  }

  void answerTrend(ElementData selected) {
    if (_trendFeedback.isNotEmpty) return;
    
    final other = _trendPair.first == selected ? _trendPair.last : _trendPair.first;
    double val1 = _getPropertyValue(selected);
    double val2 = _getPropertyValue(other);

    if (val1 > val2) {
      _trendStreak++;
      _trendFeedback = 'Correct!';
    } else {
      _trendStreak = 0;
      _trendFeedback = 'Wrong! ${other.name} is higher ($val2 vs $val1)';
    }
    notifyListeners();
    Future.delayed(const Duration(seconds: 2), _nextTrend);
  }

  double _getPropertyValue(ElementData e) {
    if (_trendProperty == 'electronegativity') return e.electronegativity ?? 0;
    if (_trendProperty == 'atomicMass') return double.tryParse(e.atomicMass) ?? 0;
    return 0;
  }
  
  // Neighbors
  void _initNeighbors() {
    _nextNeighborTarget();
  }
  
  
  void _nextNeighborTarget() {
    _neighborTarget = (List.of(elements)..shuffle()).first;
    // F-Block logic: Group is null. Skip for MVP logic or map to Group 3
    if (_neighborTarget!.group == null) {
      _nextNeighborTarget(); // Recursively try again
      return;
    }

    _neighborInputs = List.filled(8, '');
    _neighborResults = List.filled(8, null);
    _neighborFeedback = '';
    
    // Calculate 8 neighbors in Reading Order (TL -> BR)
    // 0:TL, 1:T, 2:TR, 3:L, 4:R, 5:BL, 6:B, 7:BR
    final p = _neighborTarget!.period;
    final g = _neighborTarget!.group!;
    
    _correctNeighbors = [];
    final offsets = [
      [-1, -1], // 0: TL
      [-1, 0],  // 1: T
      [-1, 1],  // 2: TR
      [0, -1],  // 3: L
      [0, 1],   // 4: R
      [1, -1],  // 5: BL
      [1, 0],   // 6: B
      [1, 1],   // 7: BR
    ];
    
    for (var o in offsets) {
      final np = p + o[0];
      final ng = g + o[1];
      
      // Look up element
      final match = elements.cast<ElementData?>().firstWhere(
        (e) => e != null && e.period == np && e.group == ng,
        orElse: () => null,
      );
      _correctNeighbors.add(match);
    }
    
    notifyListeners();
  }
  
  void updateNeighborInput(int index, String val) {
    _neighborInputs[index] = val;
    notifyListeners();
  }
  
  void checkNeighbors() {
    bool allCorrect = true;
    for (int i = 0; i < 8; i++) {
        final expected = _correctNeighbors[i];
        final input = _neighborInputs[i].trim();
        
        if (expected == null) {
          // Expect empty or dash
          if (input.isEmpty || input == '-') {
             _neighborResults[i] = true;
          } else {
             _neighborResults[i] = false;
             allCorrect = false;
          }
        } else {
          if (input.toLowerCase() == expected.symbol.toLowerCase()) {
             _neighborResults[i] = true;
          } else {
             _neighborResults[i] = false;
             allCorrect = false;
          }
        }
    }
    
    if (allCorrect) {
      _neighborFeedback = 'Perfect!';
      Future.delayed(const Duration(seconds: 2), _nextNeighborTarget);
    } else {
      _neighborFeedback = 'Check errors!';
    }
    notifyListeners();
  }
}

class MatchTile {
  final int id;
  final String content;
  final bool isSymbol;
  bool isMatched = false;

  MatchTile({required this.id, required this.content, required this.isSymbol});
}
