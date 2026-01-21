// Core data models for the app

class User {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final int xpTotal;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final List<String> earnedBadges;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    required this.xpTotal,
    required this.level,
    required this.currentStreak,
    required this.longestStreak,
    this.earnedBadges = const [],
  });

  // Calculate XP needed for next level
  int get xpToNextLevel {
    if (level == 1) return 100;
    if (level == 2) return 250;
    if (level == 3) return 500;
    if (level == 4) return 1000;
    return 1000 + ((level - 4) * 750);
  }

  // Calculate XP for current level
  int get xpForCurrentLevel {
    if (level == 1) return 0;
    if (level == 2) return 100;
    if (level == 3) return 250;
    if (level == 4) return 500;
    return 1000 + ((level - 5) * 750);
  }

  // Get progress percentage to next level
  double get levelProgress {
    int currentLevelXp = xpForCurrentLevel;
    int nextLevelXp = xpToNextLevel;
    int progressXp = xpTotal - currentLevelXp;
    int xpNeeded = nextLevelXp - currentLevelXp;
    return progressXp / xpNeeded;
  }

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    int? xpTotal,
    int? level,
    int? currentStreak,
    int? longestStreak,
    List<String>? earnedBadges,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      xpTotal: xpTotal ?? this.xpTotal,
      level: level ?? this.level,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      earnedBadges: earnedBadges ?? this.earnedBadges,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'xpTotal': xpTotal,
      'level': level,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'earnedBadges': earnedBadges,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      xpTotal: json['xpTotal'] as int,
      level: json['level'] as int,
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
      earnedBadges: (json['earnedBadges'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

class TrainingSession {
  final String id;
  final String title;
  final String description;
  final String qrCode;
  final DateTime startTime;
  final String quizId;

  TrainingSession({
    required this.id,
    required this.title,
    required this.description,
    required this.qrCode,
    required this.startTime,
    required this.quizId,
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      qrCode: json['qrCode'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      quizId: json['quizId'] as String,
    );
  }
}

class Quiz {
  final String id;
  final String title;
  final String description;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Question {
  final String id;
  final String questionText;
  final QuestionType type;
  final List<String> options;
  final List<int> correctAnswerIndices;
  final String explanation;

  Question({
    required this.id,
    required this.questionText,
    required this.type,
    required this.options,
    required this.correctAnswerIndices,
    required this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      questionText: json['questionText'] as String,
      type: QuestionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => QuestionType.multipleChoice,
      ),
      options: (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      correctAnswerIndices: (json['correctAnswerIndices'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      explanation: json['explanation'] as String,
    );
  }
}

enum QuestionType {
  multipleChoice,
  trueFalse,
  multipleSelect,
}

class QuizAttempt {
  final String quizId;
  final String sessionId;
  final int score;
  final int totalQuestions;
  final int xpEarned;
  final DateTime completedAt;

  QuizAttempt({
    required this.quizId,
    required this.sessionId,
    required this.score,
    required this.totalQuestions,
    required this.xpEarned,
    required this.completedAt,
  });

  double get scorePercentage => (score / totalQuestions * 100);

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      quizId: json['quizId'] as String,
      sessionId: json['sessionId'] as String,
      score: json['score'] as int,
      totalQuestions: json['totalQuestions'] as int,
      xpEarned: json['xpEarned'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }
}

class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final BadgeType type;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
  });
}

enum BadgeType {
  achievement,  // Earned once
  recurring,    // Can be earned multiple times
}

class LeaderboardEntry {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final int level;
  final int score;
  final int rank;

  LeaderboardEntry({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.level,
    required this.score,
    required this.rank,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      level: json['level'] as int,
      score: json['score'] as int,
      rank: json['rank'] as int,
    );
  }
}
