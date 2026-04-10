import 'package:flutter/material.dart';
import '../models/team_standings.dart';

class StandingsPage extends StatelessWidget {
  final List<TeamStandings> standings;

  const StandingsPage({super.key, required this.standings});

  // 队徽映射
  static const Map<String, String> _teamLogos = {
    '常州队': 'assets/logo/changzhou.jpg',
    '南通队': 'assets/logo/nantong.jpg',
    '扬州队': 'assets/logo/yangzhou.jpg',
    '苏州队': 'assets/logo/suzhou.jpg',
    '无锡队': 'assets/logo/wuxi.jpg',
    '镇江队': 'assets/logo/zhenjiang.jpg',
    '连云港队': 'assets/logo/lianyungang.jpg',
    '盐城队': 'assets/logo/yancheng.jpg',
    '宿迁队': 'assets/logo/suqian.jpg',
    '南京队': 'assets/logo/nanjing.jpg',
    '淮安队': 'assets/logo/huaian.jpg',
    '徐州队': 'assets/logo/xuzhou.jpg',
    '泰州队': 'assets/logo/taizhou.jpg',
  };

  Widget _buildTeamLogo(String teamName, {double size = 32}) {
    final logoPath = _teamLogos[teamName];
    if (logoPath != null) {
      return ClipOval(
        child: Image.asset(
          logoPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.shield, size: size, color: Colors.grey);
          },
        ),
      );
    }
    return Icon(Icons.shield, size: size, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        horizontalMargin: 16,
        headingRowColor: WidgetStateProperty.all(Colors.blue[50]),
        columns: const [
          DataColumn(label: Text('排名', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('球队', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('赛', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
          DataColumn(label: Text('胜', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
          DataColumn(label: Text('平', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
          DataColumn(label: Text('负', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
          DataColumn(label: Text('进球', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
          DataColumn(label: Text('失球', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
          DataColumn(label: Text('净胜球', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
          DataColumn(label: Text('积分', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
        ],
        rows: standings.map((team) => _buildRow(team)).toList(),
      ),
    );
  }

  DataRow _buildRow(TeamStandings team) {
    Color rankColor = Colors.black;
    if (team.rank == 1) {
      rankColor = Colors.amber;
    } else if (team.rank == 2) {
      rankColor = Colors.grey;
    } else if (team.rank == 3) {
      rankColor = Colors.brown;
    }

    return DataRow(
      cells: [
        DataCell(
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: team.rank <= 3 ? Color.fromRGBO(rankColor.r.toInt(), rankColor.g.toInt(), rankColor.b.toInt(), 0.1) : null,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${team.rank}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: team.rank <= 3 ? rankColor : Colors.black54,
                ),
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTeamLogo(team.teamName, size: 28),
              const SizedBox(width: 8),
              Text(
                team.teamName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        DataCell(Text('${team.played}')),
        DataCell(Text('${team.won}')),
        DataCell(Text('${team.drawn}')),
        DataCell(Text('${team.lost}')),
        DataCell(Text('${team.goalsFor}')),
        DataCell(Text('${team.goalsAgainst}')),
        DataCell(
          Text(
            '${team.goalDifference > 0 ? '+' : ''}${team.goalDifference}',
            style: TextStyle(
              color: team.goalDifference > 0 
                ? Colors.green 
                : team.goalDifference < 0 
                  ? Colors.red 
                  : Colors.black,
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${team.points}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
