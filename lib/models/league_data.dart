import 'match.dart';
import 'team_standings.dart';
import 'goal_scorer.dart';

class LeagueData {
  final String leagueName;
  final List<Match> matches;
  final List<TeamStandings> standings;
  final List<GoalScorer> goalScorers;

  LeagueData({
    required this.leagueName,
    required this.matches,
    required this.standings,
    required this.goalScorers,
  });

  factory LeagueData.fromJson(Map<String, dynamic> json) {
    final matches = (json['matches'] as List)
        .map((e) => Match.fromJson(e))
        .toList();
    
    final standings = _calculateStandings(matches);
    final goalScorers = _calculateGoalScorers(matches);

    return LeagueData(
      leagueName: json['leagueName'],
      matches: matches,
      standings: standings,
      goalScorers: goalScorers,
    );
  }

  static List<TeamStandings> _calculateStandings(List<Match> matches) {
    final Map<String, Map<String, dynamic>> teamStats = {};

    for (final match in matches) {
      if (!match.isCompleted) continue;

      final homeTeam = match.homeTeam;
      final awayTeam = match.awayTeam;
      final result = match.result;

      if (result == null) continue;

      teamStats.putIfAbsent(homeTeam, () => _initStats(homeTeam));
      teamStats.putIfAbsent(awayTeam, () => _initStats(awayTeam));

      teamStats[homeTeam]!['played']++;
      teamStats[awayTeam]!['played']++;

      // 计算进球数（从进球事件统计）
      final homeGoalsCount = match.homeGoals?.where((g) => !g.isOwnGoal).length ?? 0;
      final awayOwnGoals = match.homeGoals?.where((g) => g.isOwnGoal).length ?? 0;
      final awayGoalsCount = match.awayGoals?.where((g) => !g.isOwnGoal).length ?? 0;
      final homeOwnGoals = match.awayGoals?.where((g) => g.isOwnGoal).length ?? 0;

      // 主队实际进球 = 主队进球（非乌龙）+ 客队乌龙
      // 客队实际进球 = 客队进球（非乌龙）+ 主队乌龙
      final homeTotalGoals = homeGoalsCount + homeOwnGoals;
      final awayTotalGoals = awayGoalsCount + awayOwnGoals;

      teamStats[homeTeam]!['goalsFor'] += homeTotalGoals;
      teamStats[homeTeam]!['goalsAgainst'] += awayTotalGoals;
      teamStats[awayTeam]!['goalsFor'] += awayTotalGoals;
      teamStats[awayTeam]!['goalsAgainst'] += homeTotalGoals;

      // 根据结果计算积分
      if (result == '主队胜') {
        teamStats[homeTeam]!['won']++;
        teamStats[homeTeam]!['points'] += 3;
        teamStats[awayTeam]!['lost']++;
      } else if (result == '客队胜') {
        teamStats[awayTeam]!['won']++;
        teamStats[awayTeam]!['points'] += 3;
        teamStats[homeTeam]!['lost']++;
      } else if (result == '平局') {
        teamStats[homeTeam]!['drawn']++;
        teamStats[awayTeam]!['drawn']++;
        teamStats[homeTeam]!['points'] += 1;
        teamStats[awayTeam]!['points'] += 1;
      }
    }

    final standings = teamStats.values.map((stats) => TeamStandings(
      rank: 0,
      teamName: stats['teamName'],
      played: stats['played'],
      won: stats['won'],
      drawn: stats['drawn'],
      lost: stats['lost'],
      goalsFor: stats['goalsFor'],
      goalsAgainst: stats['goalsAgainst'],
      points: stats['points'],
    )).toList();

    standings.sort((a, b) {
      if (b.points != a.points) return b.points - a.points;
      final aDiff = a.goalDifference;
      final bDiff = b.goalDifference;
      if (bDiff != aDiff) return bDiff - aDiff;
      return b.goalsFor - a.goalsFor;
    });

    for (int i = 0; i < standings.length; i++) {
      standings[i] = TeamStandings(
        rank: i + 1,
        teamName: standings[i].teamName,
        played: standings[i].played,
        won: standings[i].won,
        drawn: standings[i].drawn,
        lost: standings[i].lost,
        goalsFor: standings[i].goalsFor,
        goalsAgainst: standings[i].goalsAgainst,
        points: standings[i].points,
      );
    }

    return standings;
  }

  static Map<String, dynamic> _initStats(String teamName) => {
    'teamName': teamName,
    'played': 0,
    'won': 0,
    'drawn': 0,
    'lost': 0,
    'goalsFor': 0,
    'goalsAgainst': 0,
    'points': 0,
  };

  static List<GoalScorer> _calculateGoalScorers(List<Match> matches) {
    final Map<String, Map<String, dynamic>> scorerStats = {};

    for (final match in matches) {
      if (match.homeGoals != null) {
        for (final goal in match.homeGoals!) {
          // 乌龙球不计入射手榜
          if (goal.isOwnGoal) continue;
          final key = '${goal.playerName}_${match.homeTeam}';
          scorerStats.putIfAbsent(key, () => _initScorer(goal.playerName, match.homeTeam));
          scorerStats[key]!['goals']++;
          if (goal.isPenalty) scorerStats[key]!['penalties']++;
        }
      }
      if (match.awayGoals != null) {
        for (final goal in match.awayGoals!) {
          // 乌龙球不计入射手榜
          if (goal.isOwnGoal) continue;
          final key = '${goal.playerName}_${match.awayTeam}';
          scorerStats.putIfAbsent(key, () => _initScorer(goal.playerName, match.awayTeam));
          scorerStats[key]!['goals']++;
          if (goal.isPenalty) scorerStats[key]!['penalties']++;
        }
      }
    }

    final scorers = scorerStats.values.map((stats) => GoalScorer(
      rank: 0,
      playerName: stats['playerName'],
      teamName: stats['teamName'],
      goals: stats['goals'],
      penalties: stats['penalties'] > 0 ? stats['penalties'] : null,
    )).toList();

    scorers.sort((a, b) => b.goals - a.goals);

    for (int i = 0; i < scorers.length; i++) {
      scorers[i] = GoalScorer(
        rank: i + 1,
        playerName: scorers[i].playerName,
        teamName: scorers[i].teamName,
        goals: scorers[i].goals,
        penalties: scorers[i].penalties,
      );
    }

    return scorers;
  }

  static Map<String, dynamic> _initScorer(String playerName, String teamName) => {
    'playerName': playerName,
    'teamName': teamName,
    'goals': 0,
    'penalties': 0,
  };
}
