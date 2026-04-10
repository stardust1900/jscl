class TeamStandings {
  final int rank;
  final String teamName;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int points;

  TeamStandings({
    required this.rank,
    required this.teamName,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.points,
  });

  factory TeamStandings.fromJson(Map<String, dynamic> json) {
    return TeamStandings(
      rank: json['rank'],
      teamName: json['teamName'],
      played: json['played'],
      won: json['won'],
      drawn: json['drawn'],
      lost: json['lost'],
      goalsFor: json['goalsFor'],
      goalsAgainst: json['goalsAgainst'],
      points: json['points'],
    );
  }

  int get goalDifference => goalsFor - goalsAgainst;
}
