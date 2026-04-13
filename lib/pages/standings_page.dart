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
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth * 0.95;
        final isWideScreen = constraints.maxWidth > 400;

        return SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: tableWidth,
              child: DataTable(
                columnSpacing: isWideScreen ? 12 : 6,
                horizontalMargin: 4,
                headingRowColor: WidgetStateProperty.all(Colors.blue[50]),
                columns: [
                  DataColumn(label: Text('排名', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isWideScreen ? 15 : 13))),
                  DataColumn(label: Text('球队', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isWideScreen ? 15 : 13))),
                  DataColumn(label: Text('赛', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isWideScreen ? 14 : 12)), numeric: true),
                  DataColumn(label: Text('胜/平/负', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isWideScreen ? 14 : 12))),
                  DataColumn(label: Text('进/失/净', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isWideScreen ? 14 : 12)), numeric: true),
                  DataColumn(label: Text('积分', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isWideScreen ? 14 : 12)), numeric: true),
                ],
                rows: standings.map((team) => _buildRow(team, isWideScreen)).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildRow(TeamStandings team, bool isWideScreen) {
    Color rankColor = Colors.black;
    if (team.rank == 1) {
      rankColor = Colors.amber;
    } else if (team.rank == 2) {
      rankColor = Colors.grey;
    } else if (team.rank == 3) {
      rankColor = Colors.brown;
    }

    final fontSize = isWideScreen ? 15.0 : 13.0;
    final logoSize = isWideScreen ? 28.0 : 24.0;
    final rankSize = isWideScreen ? 28.0 : 24.0;

    return DataRow(
      cells: [
        DataCell(
          Container(
            width: rankSize,
            height: rankSize,
            decoration: BoxDecoration(
              color: team.rank <= 3 ? Color.fromRGBO(rankColor.r.toInt(), rankColor.g.toInt(), rankColor.b.toInt(), 0.1) : null,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${team.rank}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
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
              _buildTeamLogo(team.teamName, size: logoSize),
              SizedBox(width: isWideScreen ? 6 : 4),
              Flexible(
                child: Text(
                  team.teamName.replaceAll('队', ''),
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: fontSize),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        DataCell(Text('${team.played}', style: TextStyle(fontSize: fontSize))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${team.won}', style: TextStyle(fontSize: fontSize, color: Colors.green[700])),
              Text('/', style: TextStyle(fontSize: fontSize, color: Colors.grey)),
              Text('${team.drawn}', style: TextStyle(fontSize: fontSize, color: Colors.orange[700])),
              Text('/', style: TextStyle(fontSize: fontSize, color: Colors.grey)),
              Text('${team.lost}', style: TextStyle(fontSize: fontSize, color: Colors.red[700])),
            ],
          ),
        ),
        DataCell(
          Text(
            '${team.goalsFor}/${team.goalsAgainst}/${team.goalDifference > 0 ? '+' : ''}${team.goalDifference}',
            style: TextStyle(
              fontSize: fontSize,
              color: team.goalDifference > 0 ? Colors.green : team.goalDifference < 0 ? Colors.red : Colors.black,
            ),
          ),
        ),
        DataCell(
          Container(
            padding: EdgeInsets.symmetric(horizontal: isWideScreen ? 6 : 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${team.points}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                color: Colors.blue[800],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
