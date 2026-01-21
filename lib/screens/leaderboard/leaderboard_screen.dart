import 'package:flutter/material.dart';
import 'package:talent_valley_app/services/api_service.dart';
import 'package:talent_valley_app/models/models.dart';
import 'package:talent_valley_app/theme/app_theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final MockApiService _apiService = MockApiService();
  List<LeaderboardEntry>? _leaderboard;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    
    // Using mock session ID for demo
    final leaderboard = await _apiService.getLeaderboard('session_1');
    
    setState(() {
      _leaderboard = leaderboard;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLeaderboard,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _leaderboard == null || _leaderboard!.isEmpty
              ? _buildEmptyState()
              : _buildLeaderboard(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.leaderboard_outlined,
            size: 80,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No rankings yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Complete a quiz to see your ranking',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    return RefreshIndicator(
      onRefresh: _loadLeaderboard,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _leaderboard!.length + 1, // +1 for header
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildHeader();
          }
          
          final entry = _leaderboard![index - 1];
          final isCurrentUser = entry.displayName == 'You';
          
          return _LeaderboardCard(
            entry: entry,
            isCurrentUser: isCurrentUser,
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Trophy Icon
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.emoji_events,
                size: 48,
                color: Colors.white,
              ),
              SizedBox(height: 12),
              Text(
                'Top Performers',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        Text(
          'Rankings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        
        const SizedBox(height: 12),
      ],
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const _LeaderboardCard({
    required this.entry,
    required this.isCurrentUser,
  });

  String _getRankEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final rankEmoji = _getRankEmoji(entry.rank);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: isCurrentUser
            ? AppTheme.primaryColor.withOpacity(0.1)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Rank
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: entry.rank <= 3
                      ? AppTheme.primaryColor.withOpacity(0.2)
                      : AppTheme.surfaceColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    rankEmoji.isNotEmpty ? rankEmoji : '#${entry.rank}',
                    style: TextStyle(
                      fontSize: rankEmoji.isNotEmpty ? 24 : 16,
                      fontWeight: FontWeight.bold,
                      color: entry.rank <= 3
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Avatar
              CircleAvatar(
                radius: 24,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isCurrentUser
                        ? AppTheme.primaryGradient
                        : LinearGradient(
                            colors: [
                              AppTheme.textSecondary,
                              AppTheme.textTertiary,
                            ],
                          ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      entry.displayName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: isCurrentUser
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Level ${entry.level}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${entry.score}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                  Text(
                    'points',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
