// Mock API service with dummy data for MVP
import 'package:talent_valley_app/models/models.dart';

class MockApiService {
  // Simulate network delay
  Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Mock user login
  Future<User> login(String email, String password) async {
    await _delay();
    
    // For MVP, accept any email/password
    return User(
      id: 'user_1',
      email: email,
      displayName: _extractNameFromEmail(email),
      xpTotal: 450,
      level: 3,
      currentStreak: 5,
      longestStreak: 12,
      earnedBadges: ['first_steps', 'quick_learner', 'on_fire'],
    );
  }

  // Mock user registration
  Future<User> register(String email, String password, String displayName) async {
    await _delay();
    
    return User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName,
      xpTotal: 0,
      level: 1,
      currentStreak: 0,
      longestStreak: 0,
      earnedBadges: [],
    );
  }

  // Validate QR code and join session
  Future<TrainingSession> joinSession(String qrCode) async {
    await _delay();
    
    // Mock session data
    return TrainingSession(
      id: 'session_1',
      title: 'Product Management Fundamentals',
      description: 'Learn the basics of product management in this comprehensive training session',
      qrCode: qrCode,
      startTime: DateTime.now().subtract(const Duration(hours: 1)),
      quizId: 'quiz_1',
    );
  }

  // Get quiz by ID
  Future<Quiz> getQuiz(String quizId) async {
    await _delay();
    
    return _getMockQuiz(quizId);
  }

  // Submit quiz and get results
  Future<QuizAttempt> submitQuiz(
    String quizId,
    String sessionId,
    Map<String, List<int>> answers,
  ) async {
    await _delay();
    
    final quiz = _getMockQuiz(quizId);
    int correctAnswers = 0;
    
    for (var question in quiz.questions) {
      final userAnswer = answers[question.id] ?? [];
      if (_listsEqual(userAnswer, question.correctAnswerIndices)) {
        correctAnswers++;
      }
    }
    
    // Calculate XP
    final baseXp = correctAnswers * 10;
    final completionBonus = correctAnswers == quiz.questions.length ? 100 : 50;
    final totalXp = baseXp + completionBonus;
    
    return QuizAttempt(
      quizId: quizId,
      sessionId: sessionId,
      score: correctAnswers,
      totalQuestions: quiz.questions.length,
      xpEarned: totalXp,
      completedAt: DateTime.now(),
    );
  }

  // Get session leaderboard
  Future<List<LeaderboardEntry>> getLeaderboard(String sessionId) async {
    await _delay();
    
    return _getMockLeaderboard();
  }

  // Get available badges
  Future<List<Badge>> getBadges() async {
    await _delay();
    
    return _getAllBadges();
  }

  // Helper: Extract name from email
  String _extractNameFromEmail(String email) {
    final username = email.split('@')[0];
    return username.split('.').map((part) {
      return part[0].toUpperCase() + part.substring(1);
    }).join(' ');
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

  // Mock quiz data
  Quiz _getMockQuiz(String quizId) {
    return Quiz(
      id: quizId,
      title: 'Product Management Quiz',
      description: 'Test your knowledge of product management fundamentals',
      questions: [
        Question(
          id: 'q1',
          questionText: 'What is the primary role of a Product Manager?',
          type: QuestionType.multipleChoice,
          options: [
            'Writing code',
            'Defining product vision and strategy',
            'Designing UI/UX',
            'Managing finances',
          ],
          correctAnswerIndices: [1],
          explanation: 'Product Managers define the product vision, strategy, and roadmap, working with cross-functional teams to bring products to market.',
        ),
        Question(
          id: 'q2',
          questionText: 'A user story should always be written from the user\'s perspective.',
          type: QuestionType.trueFalse,
          options: ['True', 'False'],
          correctAnswerIndices: [0],
          explanation: 'User stories follow the format: "As a [user], I want [goal], so that [benefit]" to maintain user focus.',
        ),
        Question(
          id: 'q3',
          questionText: 'Which of the following are part of the product development lifecycle? (Select all that apply)',
          type: QuestionType.multipleSelect,
          options: [
            'Discovery',
            'Design',
            'Development',
            'Deprecation',
          ],
          correctAnswerIndices: [0, 1, 2],
          explanation: 'The product lifecycle typically includes Discovery, Design, Development, Launch, and Growth. Deprecation comes much later.',
        ),
        Question(
          id: 'q4',
          questionText: 'What does MVP stand for in product development?',
          type: QuestionType.multipleChoice,
          options: [
            'Most Valuable Player',
            'Minimum Viable Product',
            'Maximum Value Proposition',
            'Minimal Version Prototype',
          ],
          correctAnswerIndices: [1],
          explanation: 'MVP stands for Minimum Viable Product - a product with just enough features to satisfy early customers and provide feedback.',
        ),
        Question(
          id: 'q5',
          questionText: 'Product-market fit means your product has found a sustainable market.',
          type: QuestionType.trueFalse,
          options: ['True', 'False'],
          correctAnswerIndices: [0],
          explanation: 'Product-market fit occurs when your product satisfies a strong market demand and can sustain growth.',
        ),
      ],
    );
  }

  // Mock leaderboard data
  List<LeaderboardEntry> _getMockLeaderboard() {
    return [
      LeaderboardEntry(
        userId: 'user_2',
        displayName: 'Sarah Johnson',
        level: 5,
        score: 980,
        rank: 1,
      ),
      LeaderboardEntry(
        userId: 'user_3',
        displayName: 'Michael Chen',
        level: 4,
        score: 876,
        rank: 2,
      ),
      LeaderboardEntry(
        userId: 'user_1',
        displayName: 'You',
        level: 3,
        score: 750,
        rank: 3,
      ),
      LeaderboardEntry(
        userId: 'user_4',
        displayName: 'Emily Rodriguez',
        level: 3,
        score: 695,
        rank: 4,
      ),
      LeaderboardEntry(
        userId: 'user_5',
        displayName: 'David Kim',
        level: 2,
        score: 523,
        rank: 5,
      ),
    ];
  }

  // All available badges
  List<Badge> _getAllBadges() {
    return [
      Badge(
        id: 'first_steps',
        name: 'First Steps',
        description: 'Complete your first quiz',
        icon: '🎯',
        type: BadgeType.achievement,
      ),
      Badge(
        id: 'quick_learner',
        name: 'Quick Learner',
        description: 'Score 100% on your first quiz',
        icon: '🔥',
        type: BadgeType.achievement,
      ),
      Badge(
        id: 'knowledge_seeker',
        name: 'Knowledge Seeker',
        description: 'Complete 5 quizzes',
        icon: '📚',
        type: BadgeType.achievement,
      ),
      Badge(
        id: 'training_champion',
        name: 'Training Champion',
        description: 'Complete 10 quizzes',
        icon: '🏆',
        type: BadgeType.achievement,
      ),
      Badge(
        id: 'speed_demon',
        name: 'Speed Demon',
        description: 'Complete a quiz in under 2 minutes',
        icon: '⚡',
        type: BadgeType.achievement,
      ),
      Badge(
        id: 'perfect_scholar',
        name: 'Perfect Scholar',
        description: 'Get 5 perfect scores',
        icon: '🎓',
        type: BadgeType.achievement,
      ),
      Badge(
        id: 'on_fire',
        name: 'On Fire',
        description: '3-day streak',
        icon: '🔥',
        type: BadgeType.recurring,
      ),
      Badge(
        id: 'unstoppable',
        name: 'Unstoppable',
        description: '7-day streak',
        icon: '🌊',
        type: BadgeType.recurring,
      ),
      Badge(
        id: 'legendary',
        name: 'Legendary',
        description: '30-day streak',
        icon: '💎',
        type: BadgeType.recurring,
      ),
    ];
  }
}
