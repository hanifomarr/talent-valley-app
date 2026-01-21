// App state management using Provider
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:talent_valley_app/models/models.dart';
import 'package:talent_valley_app/services/api_service.dart';

class AppState extends ChangeNotifier {
  final MockApiService _apiService = MockApiService();
  User? _currentUser;
  TrainingSession? _currentSession;
  Quiz? _currentQuiz;
  List<Badge>? _allBadges;
  
  // Quiz state
  int _currentQuestionIndex = 0;
  Map<String, List<int>> _userAnswers = {};
  bool _quizCompleted = false;
  QuizAttempt? _lastAttempt;

  // Getters
  User? get currentUser => _currentUser;
  TrainingSession? get currentSession => _currentSession;
  Quiz? get currentQuiz => _currentQuiz;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get quizCompleted => _quizCompleted;
  QuizAttempt? get lastAttempt => _lastAttempt;
  List<Badge> get allBadges => _allBadges ?? [];
  
  Question? get currentQuestion {
    if (_currentQuiz == null || _currentQuestionIndex >= _currentQuiz!.questions.length) {
      return null;
    }
    return _currentQuiz!.questions[_currentQuestionIndex];
  }

  List<Badge> get earnedBadges {
    if (_currentUser == null || _allBadges == null) return [];
    return _allBadges!
        .where((badge) => _currentUser!.earnedBadges.contains(badge.id))
        .toList();
  }

  List<Badge> get lockedBadges {
    if (_currentUser == null || _allBadges == null) return [];
    return _allBadges!
        .where((badge) => !_currentUser!.earnedBadges.contains(badge.id))
        .toList();
  }

  // Check if logged in
  bool get isLoggedIn => _currentUser != null;

  // Initialize app state
  Future<void> initialize() async {
    await _loadUser();
    await _loadBadges();
  }

  // Load user from local storage
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson != null) {
      _currentUser = User.fromJson(jsonDecode(userJson));
      notifyListeners();
    }
  }

  // Save user to local storage
  Future<void> _saveUser() async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', jsonEncode(_currentUser!.toJson()));
  }

  // Load all badges
  Future<void> _loadBadges() async {
    _allBadges = await _apiService.getBadges();
    notifyListeners();
  }

  // Login
  Future<bool> login(String email, String password) async {
    try {
      _currentUser = await _apiService.login(email, password);
      await _saveUser();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  // Register
  Future<bool> register(String email, String password, String displayName) async {
    try {
      _currentUser = await _apiService.register(email, password, displayName);
      await _saveUser();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Register error: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    _currentSession = null;
    _currentQuiz = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    notifyListeners();
  }

  // Join training session via QR code
  Future<bool> joinSession(String qrCode) async {
    try {
      _currentSession = await _apiService.joinSession(qrCode);
      
      // Load the quiz for this session
      _currentQuiz = await _apiService.getQuiz(_currentSession!.quizId);
      _currentQuestionIndex = 0;
      _userAnswers = {};
      _quizCompleted = false;
      _lastAttempt = null;
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Join session error: $e');
      return false;
    }
  }

  // Answer current question
  void answerQuestion(List<int> answerIndices) {
    if (currentQuestion == null) return;
    
    _userAnswers[currentQuestion!.id] = answerIndices;
    notifyListeners();
  }

  // Check if current question is answered
  bool isQuestionAnswered() {
    if (currentQuestion == null) return false;
    return _userAnswers.containsKey(currentQuestion!.id);
  }

  // Get answer for current question
  List<int>? getCurrentAnswer() {
    if (currentQuestion == null) return null;
    return _userAnswers[currentQuestion!.id];
  }

  // Check if answer is correct
  bool isAnswerCorrect(String questionId) {
    final question = _currentQuiz?.questions.firstWhere((q) => q.id == questionId);
    if (question == null) return false;
    
    final userAnswer = _userAnswers[questionId];
    if (userAnswer == null) return false;
    
    return _listsEqual(userAnswer, question.correctAnswerIndices);
  }

  // Move to next question
  void nextQuestion() {
    if (_currentQuiz == null) return;
    
    if (_currentQuestionIndex < _currentQuiz!.questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  // Submit quiz
  Future<void> submitQuiz() async {
    if (_currentQuiz == null || _currentSession == null) return;
    
    _lastAttempt = await _apiService.submitQuiz(
      _currentQuiz!.id,
      _currentSession!.id,
      _userAnswers,
    );
    
    // Update user XP and level
    if (_currentUser != null) {
      final newXp = _currentUser!.xpTotal + _lastAttempt!.xpEarned;
      final newLevel = _calculateLevel(newXp);
      
      _currentUser = _currentUser!.copyWith(
        xpTotal: newXp,
        level: newLevel,
      );
      
      await _saveUser();
    }
    
    _quizCompleted = true;
    notifyListeners();
  }

  // Reset quiz (for retake)
  void resetQuiz() {
    _currentQuestionIndex = 0;
    _userAnswers = {};
    _quizCompleted = false;
    _lastAttempt = null;
    notifyListeners();
  }

  // Helper: Calculate level from XP
  int _calculateLevel(int xp) {
    if (xp < 100) return 1;
    if (xp < 250) return 2;
    if (xp < 500) return 3;
    if (xp < 1000) return 4;
    
    // Level 5+
    int remainingXp = xp - 1000;
    return 5 + (remainingXp ~/ 750);
  }

  // Helper: Compare lists
  bool _listsEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    final aSorted = List<int>.from(a)..sort();
    final bSorted = List<int>.from(b)..sort();
    for (int i = 0; i < aSorted.length; i++) {
      if (aSorted[i] != bSorted[i]) return false;
    }
    return true;
  }
}
