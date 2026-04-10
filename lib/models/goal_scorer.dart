class GoalScorer {
  final int rank;
  final String playerName;
  final String teamName;
  final int goals;
  final int? penalties;

  GoalScorer({
    required this.rank,
    required this.playerName,
    required this.teamName,
    required this.goals,
    this.penalties,
  });

  factory GoalScorer.fromJson(Map<String, dynamic> json) {
    return GoalScorer(
      rank: json['rank'],
      playerName: json['playerName'],
      teamName: json['teamName'],
      goals: json['goals'],
      penalties: json['penalties'],
    );
  }
}
