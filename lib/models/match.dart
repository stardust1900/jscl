class Match {
  final String id;
  final DateTime date;
  final String homeTeam;
  final String awayTeam;
  final String time;
  final String status;
  final String? result;
  final String? venue;
  final List<GoalEvent>? homeGoals;
  final List<GoalEvent>? awayGoals;

  Match({
    required this.id,
    required this.date,
    required this.homeTeam,
    required this.awayTeam,
    required this.time,
    this.status = '未开始',
    this.result,
    this.venue,
    this.homeGoals,
    this.awayGoals,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      date: DateTime.parse(json['date']),
      homeTeam: json['homeTeam'],
      awayTeam: json['awayTeam'],
      time: json['time'],
      status: json['status'] ?? '未开始',
      result: json['result'],
      venue: json['venue'],
      homeGoals: json['homeGoals'] != null
          ? (json['homeGoals'] as List).map((e) => GoalEvent.fromJson(e)).toList()
          : null,
      awayGoals: json['awayGoals'] != null
          ? (json['awayGoals'] as List).map((e) => GoalEvent.fromJson(e)).toList()
          : null,
    );
  }

  String get matchDisplay => '$homeTeam vs $awayTeam';

  // 从进球事件计算比分
  int? get homeScore {
    if (!isCompleted) return null;
    final homeGoalsCount = homeGoals?.where((g) => !g.isOwnGoal).length ?? 0;
    final awayOwnGoals = homeGoals?.where((g) => g.isOwnGoal).length ?? 0;
    return homeGoalsCount + awayOwnGoals;
  }

  int? get awayScore {
    if (!isCompleted) return null;
    final awayGoalsCount = awayGoals?.where((g) => !g.isOwnGoal).length ?? 0;
    final homeOwnGoals = awayGoals?.where((g) => g.isOwnGoal).length ?? 0;
    return awayGoalsCount + homeOwnGoals;
  }

  String get scoreDisplay {
    if (isCompleted) {
      return '$homeScore : $awayScore';
    }
    return 'vs';
  }

  bool get isCompleted => status == '已结束';
}

class GoalEvent {
  final String playerName;
  final int minute;
  final bool isPenalty;
  final bool isOwnGoal;

  GoalEvent({
    required this.playerName,
    required this.minute,
    this.isPenalty = false,
    this.isOwnGoal = false,
  });

  factory GoalEvent.fromJson(Map<String, dynamic> json) {
    return GoalEvent(
      playerName: json['playerName'],
      minute: json['minute'],
      isPenalty: json['isPenalty'] ?? false,
      isOwnGoal: json['isOwnGoal'] ?? false,
    );
  }
}
