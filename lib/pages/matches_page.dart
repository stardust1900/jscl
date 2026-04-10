import 'package:flutter/material.dart';
import '../models/match.dart';

class MatchesPage extends StatefulWidget {
  final List<Match> matches;

  const MatchesPage({super.key, required this.matches});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  final ScrollController _scrollController = ScrollController();
  DateTime _currentMonth = DateTime.now();
  Map<DateTime, List<Match>> _groupedMatches = {};
  List<DateTime> _sortedDates = [];
  Set<DateTime> _matchDates = {};
  Map<DateTime, GlobalKey> _dateKeys = {};

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

  Widget _buildTeamLogo(String teamName, {double size = 40}) {
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
  void initState() {
    super.initState();
    _processMatches();
  }

  @override
  void didUpdateWidget(MatchesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.matches != oldWidget.matches) {
      _processMatches();
    }
  }

  void _processMatches() {
    _groupedMatches.clear();
    _sortedDates = [];
    _matchDates.clear();
    _dateKeys.clear();

    final List<Match> matches = widget.matches;
    if (matches == null || matches.isEmpty) return;

    // 按日期分组
    for (final match in matches) {
      if (match == null) continue;
      final date = match.date;
      final key = DateTime(date.year, date.month, date.day);
      final list = _groupedMatches[key];
      if (list == null) {
        _groupedMatches[key] = [match];
        _matchDates.add(key);
        _dateKeys[key] = GlobalKey();
      } else {
        list.add(match);
      }
    }

    // 排序日期
    _sortedDates = _matchDates.toList()..sort((a, b) => a.compareTo(b));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Set<DateTime> _getMatchDates() {
    return _matchDates;
  }

  void _scrollToDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    final globalKey = _dateKeys[key];
    if (globalKey?.currentContext != null) {
      Scrollable.ensureVisible(
        globalKey!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Match> matches = widget.matches;
    if (matches == null || matches.isEmpty || _sortedDates.isEmpty) {
      return const Center(child: Text('暂无赛程数据'));
    }

    final matchDates = _getMatchDates();
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // 赛程列表（右侧留出空间给日历）
        Padding(
          padding: const EdgeInsets.only(right: 210),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _sortedDates.map((date) {
                final dayMatches = _groupedMatches[date];
                if (dayMatches == null || dayMatches.isEmpty) {
                  return const SizedBox.shrink();
                }
                final dateKey = DateTime(date.year, date.month, date.day);
                return Column(
                  key: _dateKeys[dateKey],
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      color: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        _formatDate(date),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    ...dayMatches.map((match) => _buildMatchCard(match)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        // 日历面板（右上角）
        Positioned(
          top: 0,
          right: 0,
          child: SizedBox(
            width: 200,
            height: screenHeight * 0.4,
            child: _buildCalendarPanel(matchDates),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarPanel(Set<DateTime>? matchDates) {
    if (matchDates == null) matchDates = {};
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // 月份选择器
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 20),
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                    });
                  },
                ),
                Text(
                  '${_currentMonth.year}年${_currentMonth.month}月',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20),
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                    });
                  },
                ),
              ],
            ),
          ),
          // 星期标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text('日', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 12)),
                Text('一', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text('二', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text('三', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text('四', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text('五', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text('六', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 12)),
              ],
            ),
          ),
          // 日历网格
          Expanded(
            child: _buildCalendarGrid(matchDates),
          ),
          // 图例说明
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Text('有比赛', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                const SizedBox(width: 16),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Text('无比赛', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(Set<DateTime> matchDates) {
    if (matchDates.isEmpty) {
      return GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
        ),
        itemCount: 42,
        itemBuilder: (context, index) => const SizedBox.shrink(),
      );
    }

    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekday = firstDayOfMonth.weekday % 7;

    // 预计算当月有比赛的日期集合
    final matchDatesInMonth = <int>{};
    for (final date in matchDates) {
      if (date.year == _currentMonth.year && date.month == _currentMonth.month) {
        matchDatesInMonth.add(date.day);
      }
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final dayNumber = index - firstWeekday + 1;

        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }

        final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
        final hasMatch = matchDatesInMonth.contains(dayNumber);
        final isToday = _isToday(date);

        return GestureDetector(
          onTap: hasMatch ? () => _scrollToDate(date) : null,
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: hasMatch ? Colors.blue[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
              border: isToday
                  ? Border.all(color: Colors.blue, width: 2)
                  : hasMatch
                      ? Border.all(color: Colors.blue[300]!, width: 1)
                      : null,
            ),
            child: Center(
              child: Text(
                '$dayNumber',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: hasMatch ? FontWeight.bold : FontWeight.normal,
                  color: hasMatch
                      ? Colors.blue[800]
                      : date.weekday == DateTime.sunday || date.weekday == DateTime.saturday
                          ? Colors.grey[500]
                          : Colors.grey[600],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final matchDate = DateTime(date.year, date.month, date.day);

    if (matchDate == today) {
      return '今天 ${date.month}月${date.day}日';
    } else if (matchDate == today.add(const Duration(days: 1))) {
      return '明天 ${date.month}月${date.day}日';
    } else {
      return '${date.month}月${date.day}日 星期${_getWeekday(date.weekday)}';
    }
  }

  String _getWeekday(int weekday) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return weekdays[weekday - 1];
  }

  Widget _buildMatchCard(Match match) {
    final isCompleted = match.isCompleted;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green[100] : Colors.orange[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      match.status,
                      style: TextStyle(
                        fontSize: 12,
                        color: isCompleted ? Colors.green[800] : Colors.orange[800],
                      ),
                    ),
                  ),
                ),
                if (isCompleted && match.result != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      match.result!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                Text(
                  match.time,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildTeamLogo(match.homeTeam),
                      const SizedBox(height: 8),
                      Text(
                        match.homeTeam,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '主场',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: isCompleted
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          match.scoreDisplay,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : const Text(
                        'VS',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _buildTeamLogo(match.awayTeam),
                      const SizedBox(height: 8),
                      Text(
                        match.awayTeam,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '客场',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isCompleted) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              _buildGoalDetails(match),
            ],
            if (match.venue != null && match.venue!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      match.venue!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGoalDetails(Match match) {
    final homeGoalList = match.homeGoals ?? [];
    final awayGoalList = match.awayGoals ?? [];
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: homeGoalList.map((goal) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      goal.isOwnGoal 
                        ? Icons.error_outline 
                        : goal.isPenalty 
                          ? Icons.circle_outlined 
                          : Icons.sports_soccer,
                      size: 12,
                      color: goal.isOwnGoal ? Colors.red[400] : Colors.green[700],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        goal.isOwnGoal 
                          ? '${goal.playerName}(乌龙) ${goal.minute}\'' 
                          : '${goal.playerName} ${goal.minute}\'',
                        style: TextStyle(
                          fontSize: 11,
                          color: goal.isOwnGoal ? Colors.red[600] : Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ).toList(),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: awayGoalList.map((goal) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        goal.isOwnGoal 
                          ? '${goal.minute}\' ${goal.playerName}(乌龙)' 
                          : '${goal.minute}\' ${goal.playerName}',
                        style: TextStyle(
                          fontSize: 11,
                          color: goal.isOwnGoal ? Colors.red[600] : Colors.grey[700],
                        ),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      goal.isOwnGoal 
                        ? Icons.error_outline 
                        : goal.isPenalty 
                          ? Icons.circle_outlined 
                          : Icons.sports_soccer,
                      size: 12,
                      color: goal.isOwnGoal ? Colors.red[400] : Colors.green[700],
                    ),
                  ],
                ),
              ),
            ).toList(),
          ),
        ),
      ],
    );
  }
}
