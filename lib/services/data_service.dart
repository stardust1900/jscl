import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/league_data.dart';
import '../models/match.dart';

class DataService {
  static Future<LeagueData> loadLeagueData() async {
    final String jsonString = await rootBundle.loadString('assets/data/league_data.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return LeagueData.fromJson(jsonMap);
  }

  static List<Match> getMatchesByDate(List<Match> matches, DateTime date) {
    return matches.where((match) => 
      match.date.year == date.year &&
      match.date.month == date.month &&
      match.date.day == date.day
    ).toList();
  }

  static List<Match> getUpcomingMatches(List<Match> matches) {
    final now = DateTime.now();
    return matches.where((match) => match.date.isAfter(now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  static List<Match> getCompletedMatches(List<Match> matches) {
    return matches.where((match) => match.isCompleted).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
