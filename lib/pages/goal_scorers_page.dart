import 'package:flutter/material.dart';
import '../models/goal_scorer.dart';

class GoalScorersPage extends StatelessWidget {
  final List<GoalScorer> goalScorers;

  const GoalScorersPage({super.key, required this.goalScorers});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: goalScorers.length,
      itemBuilder: (context, index) {
        final scorer = goalScorers[index];
        return _buildScorerCard(scorer);
      },
    );
  }

  Widget _buildScorerCard(GoalScorer scorer) {
    Color rankColor = Colors.grey[400]!;
    IconData? rankIcon;
    
    if (scorer.rank == 1) {
      rankColor = Colors.amber;
      rankIcon = Icons.emoji_events;
    } else if (scorer.rank == 2) {
      rankColor = Colors.grey;
      rankIcon = Icons.emoji_events;
    } else if (scorer.rank == 3) {
      rankColor = Colors.brown;
      rankIcon = Icons.emoji_events;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Color.fromRGBO(rankColor.r.toInt(), rankColor.g.toInt(), rankColor.b.toInt(), 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: rankColor, width: 2),
          ),
          child: Center(
            child: rankIcon != null
              ? Icon(rankIcon, color: rankColor, size: 24)
              : Text(
                  '${scorer.rank}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: rankColor,
                  ),
                ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                scorer.playerName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sports_soccer, size: 16, color: Colors.green[700]),
                  const SizedBox(width: 4),
                  Text(
                    '${scorer.goals}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(Icons.shield, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                scorer.teamName,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              if (scorer.penalties != null && scorer.penalties! > 0) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '点球: ${scorer.penalties}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange[800],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
