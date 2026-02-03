import 'package:flutter/foundation.dart';
import '../data/periodic_data.dart';
import '../data/element_data.dart';
import 'dart:async';

enum AppMode { dashboard, flashcards, quiz, match, findIt, trend }

class AppState extends ChangeNotifier {
  final List<ElementData> elements = periodicTableData;
  AppMode _currentMode = AppMode.dashboard;
  AppMode get currentMode => _currentMode;

  // Flashcards
  int _flashcardIndex = 0;
  bool _isFlipped = false;
  int get flashcardIndex => _flashcardIndex;
  bool get isFlipped => _isFlipped;
  ElementData get currentFlashcard => elements[_flashcardIndex];

  // Quiz
  int _quizScore = 0;
  ElementData? _currentQuizQuestion;
  String? _correctAnswer; // symbol or name
  List<String> _quizOptions = [];
  bool? _lastAnswerCorrect;
  String _quizFeedback = '';
  
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
  
  ElementData? get findTarget => _findTarget;
  String get findMessage => _findMessage;
  bool get findSuccess => _findSuccess;

  // Trend Master
  int _trendStreak = 0;
  List<ElementData> _trendPair = [];
  String _trendProperty = 'electronegativity'; // or 'atomicMass'
  String _trendFeedback = '';
  
  int get trendStreak => _trendStreak;
  List<ElementData> get trendPair => _trendPair;
  String get trendProperty => _trendProperty;
  String get trendFeedback => _trendFeedback;

  // --- ACTIONS ---

  void setMode(AppMode mode) {
    _currentMode = mode;
    _stopTimers();
    notifyListeners();
    if (mode == AppMode.flashcards) _initFlashcards();
    if (mode == AppMode.quiz) _initQuiz();
    if (mode == AppMode.match) _initMatch();
    if (mode == AppMode.findIt) _initFindIt();
    if (mode == AppMode.trend) _initTrend();
  }

  void _stopTimers() {
    _matchTimer?.cancel();
  }

  // Flashcards
  void _initFlashcards() {
    _flashcardIndex = 0;
    _isFlipped = false;
  }
  
  void nextFlashcard() {
    if (_flashcardIndex < elements.length - 1) {
      _flashcardIndex++;
      _isFlipped = false;
      notifyListeners();
    }
  }

  void prevFlashcard() {
    if (_flashcardIndex > 0) {
      _flashcardIndex--;
      _isFlipped = false;
      notifyListeners();
    }
  }

  void flipFlashcard() {
    _isFlipped = !_isFlipped;
    notifyListeners();
  }

  // Quiz
  void _initQuiz() {
    _quizScore = 0;
    _nextQuizQuestion();
  }

  void _nextQuizQuestion() {
    _quizFeedback = '';
    final target = (elements..shuffle()).first;
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
     final Set<String> opts = {};
     while(opts.length < 3) {
       final r = (elements..shuffle()).first;
       if (r.atomicNumber != target.atomicNumber) {
         opts.add(extractor(r));
       }
     }
     return opts.toList();
  }

  void answerQuiz(String answer) {
    if (_quizFeedback.isNotEmpty) return; // already answered
    if (answer == _correctAnswer) {
      _quizScore += 10;
      _quizFeedback = 'Correct!';
    } else {
      _quizFeedback = 'Wrong! It was $_correctAnswer';
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
    final subset = (elements..shuffle()).take(8).toList();
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
    _nextFindTarget();
  }

  void _nextFindTarget() {
    _findTarget = (elements..shuffle()).first;
    _findMessage = '';
    _findSuccess = false;
    notifyListeners();
  }

  void checkFindItLocation(int atomicNumber) {
    if (_findSuccess) return;
    if (atomicNumber == _findTarget!.atomicNumber) {
      _findMessage = 'Correct! 🎉';
      _findSuccess = true;
      notifyListeners();
      Future.delayed(const Duration(seconds: 1), _nextFindTarget);
    } else {
      _findMessage = 'Try Again!';
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
}

class MatchTile {
  final int id;
  final String content;
  final bool isSymbol;
  bool isMatched = false;

  MatchTile({required this.id, required this.content, required this.isSymbol});
}
