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
  bool _isCalendarCollapsed = false; // 日历收起状态
  Set<String> _selectedTeams = {}; // 选中的球队

  // 获取所有球队列表
  Set<String> get _allTeams {
    final teams = <String>{};
    for (final match in widget.matches) {
      teams.add(match.homeTeam);
      teams.add(match.awayTeam);
    }
    return teams;
  }

  // 根据选中的球队过滤比赛
  List<Match> get _filteredMatches {
    if (_selectedTeams.isEmpty) {
      return widget.matches;
    }
    return widget.matches.where((match) {
      return _selectedTeams.contains(match.homeTeam) ||
          _selectedTeams.contains(match.awayTeam);
    }).toList();
  }

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

    final List<Match> matches = _filteredMatches;
    if (matches.isEmpty) return;

    for (final match in matches) {
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

    _sortedDates = _matchDates.toList()..sort((a, b) => a.compareTo(b));
  }

  void _toggleTeam(String team) {
    setState(() {
      if (_selectedTeams.contains(team)) {
        _selectedTeams.remove(team);
      } else {
        _selectedTeams.add(team);
      }
      _processMatches();
    });
  }

  void _clearTeamFilter() {
    setState(() {
      _selectedTeams.clear();
      _processMatches();
    });
  }

  void _toggleCalendarCollapse() {
    setState(() {
      _isCalendarCollapsed = !_isCalendarCollapsed;
    });
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
    final List<Match> matches = _filteredMatches;
    if (matches.isEmpty || _sortedDates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('暂无赛程数据'),
            if (_selectedTeams.isNotEmpty) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: _clearTeamFilter,
                child: const Text('清除筛选'),
              ),
            ],
          ],
        ),
      );
    }

    final matchDates = _getMatchDates();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;
    final sidebarWidth = _isCalendarCollapsed
        ? 0.0
        : (isWideScreen ? 200.0 : screenWidth / 3);

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.only(
            right: sidebarWidth + (sidebarWidth > 0 ? 10 : 0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._sortedDates.map((date) {
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        _formatDate(date),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    ...dayMatches.map(
                      (match) => _buildMatchCard(match, isWideScreen),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
        // 日历收起按钮
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: Icon(
              _isCalendarCollapsed ? Icons.chevron_left : Icons.chevron_right,
              color: Colors.grey[600],
            ),
            onPressed: _toggleCalendarCollapse,
            tooltip: _isCalendarCollapsed ? '展开日历' : '收起日历',
          ),
        ),
        // 日历面板和球队筛选
        if (!_isCalendarCollapsed)
          if (isWideScreen)
            Positioned(
              top: 36,
              right: 0,
              child: SizedBox(
                width: 200,
                child: _buildCalendarPanel(
                  matchDates,
                  maxHeight: screenHeight * 0.75,
                ),
              ),
            )
          else
            Positioned(
              top: 36,
              right: 0,
              child: SizedBox(
                width: screenWidth / 3,
                height: screenHeight * 0.75,
                child: _buildCalendarPanel(
                  matchDates,
                  maxHeight: screenHeight * 0.75,
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildCalendarPanel(Set<DateTime>? matchDates, {double? maxHeight}) {
    matchDates ??= {};
    return LayoutBuilder(
      builder: (context, constraints) {
        final panelWidth = constraints.maxWidth;
        final isNarrow = panelWidth < 100;
        final titleFontSize = isNarrow
            ? 10.0
            : (panelWidth / 15).clamp(10.0, 14.0);
        final dayFontSize = (panelWidth / 28).clamp(8.0, 12.0);
        final legendFontSize = (panelWidth / 28).clamp(8.0, 12.0);
        final teamFontSize = (panelWidth / 22).clamp(10.0, 14.0); // 球队字体稍大

        // 计算各部分高度
        final headerHeight = isNarrow ? 28.0 : 32.0;
        final weekdayRowHeight = isNarrow ? 16.0 : 20.0;
        final legendHeight = isNarrow ? 20.0 : 24.0;
        final teamFilterHeight = isNarrow ? 220.0 : 130.0;
        // 正方形：行高 = 单元格宽度
        final cellWidth = (panelWidth - 4) / 7;
        final rowHeight = cellWidth;
        final gridHeight = rowHeight * 6;

        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              SizedBox(
                height: headerHeight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: isNarrow ? 24 : panelWidth * 0.15,
                        child: IconButton(
                          icon: Icon(
                            Icons.chevron_left,
                            size: isNarrow ? 18 : panelWidth * 0.08,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              _currentMonth = DateTime(
                                _currentMonth.year,
                                _currentMonth.month - 1,
                              );
                            });
                          },
                        ),
                      ),
                      Flexible(
                        child: Text(
                          '${_currentMonth.year}年${_currentMonth.month}月',
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        width: isNarrow ? 24 : panelWidth * 0.15,
                        child: IconButton(
                          icon: Icon(
                            Icons.chevron_right,
                            size: isNarrow ? 18 : panelWidth * 0.08,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              _currentMonth = DateTime(
                                _currentMonth.year,
                                _currentMonth.month + 1,
                              );
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 星期标题行
              SizedBox(
                height: weekdayRowHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['日', '一', '二', '三', '四', '五', '六'].map((w) {
                      return SizedBox(
                        width: (panelWidth - 4) / 7,
                        child: Text(
                          w,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: w == '日' || w == '六'
                                ? Colors.red
                                : Colors.black,
                            fontSize: dayFontSize,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              // 日期网格
              SizedBox(
                height: gridHeight > 0 ? gridHeight : 100,
                child: _buildCalendarGridFixed(
                  matchDates!,
                  rowHeight > 0 ? rowHeight : 16,
                  dayFontSize,
                ),
              ),
              // 图例
              SizedBox(
                height: legendHeight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: 2),
                      Text(
                        '有',
                        style: TextStyle(
                          fontSize: legendFontSize,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: 2),
                      Text(
                        '无',
                        style: TextStyle(
                          fontSize: legendFontSize,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 球队筛选面板
              SizedBox(
                height: teamFilterHeight,
                child: _buildTeamFilterPanel(
                  panelWidth,
                  isNarrow ? (teamFontSize - 1) : teamFontSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeamFilterPanel(double panelWidth, double fontSize) {
    final allTeams = _allTeams.toList()..sort();
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedTeams.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: GestureDetector(
                onTap: _clearTeamFilter,
                child: Text(
                  '清除筛选',
                  style: TextStyle(fontSize: fontSize, color: Colors.blue[600]),
                ),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 4,
                runSpacing: 2,
                children: allTeams.map((team) {
                  final isSelected = _selectedTeams.contains(team);
                  return GestureDetector(
                    onTap: () => _toggleTeam(team),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        team.replaceAll('队', ''),
                        style: TextStyle(
                          fontSize: fontSize,
                          color: isSelected ? Colors.white : Colors.grey[700],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGridFixed(
    Set<DateTime> matchDates,
    double rowHeight,
    double fontSize,
  ) {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    final firstWeekday = firstDayOfMonth.weekday % 7;

    final matchDatesInMonth = <int>{};
    for (final date in matchDates) {
      if (date.year == _currentMonth.year &&
          date.month == _currentMonth.month) {
        matchDatesInMonth.add(date.day);
      }
    }

    // 构建6行数据
    final rows = <Widget>[];
    for (int row = 0; row < 6; row++) {
      final cells = <Widget>[];
      for (int col = 0; col < 7; col++) {
        final index = row * 7 + col;
        final dayNumber = index - firstWeekday + 1;
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          cells.add(Expanded(child: Container()));
        } else {
          final date = DateTime(
            _currentMonth.year,
            _currentMonth.month,
            dayNumber,
          );
          final hasMatch = matchDatesInMonth.contains(dayNumber);
          final isToday = _isToday(date);
          cells.add(
            Expanded(
              child: GestureDetector(
                onTap: hasMatch ? () => _scrollToDate(date) : null,
                child: Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: isToday
                        ? Colors.orange[100]
                        : hasMatch
                        ? Colors.blue[100]
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isToday && hasMatch
                          ? Colors.blue
                          : (isToday
                                ? Colors.orange
                                : (hasMatch
                                      ? Colors.blue[300]!
                                      : Colors.transparent)),
                      width: isToday ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$dayNumber',
                      style: TextStyle(
                        fontSize: fontSize.clamp(8.0, 14.0),
                        fontWeight: hasMatch || isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isToday
                            ? Colors.orange[800]
                            : hasMatch
                            ? Colors.blue[800]
                            : (date.weekday == DateTime.sunday ||
                                      date.weekday == DateTime.saturday
                                  ? Colors.grey[500]
                                  : Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }
      rows.add(
        SizedBox(
          height: rowHeight - 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(children: cells),
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
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

  Widget _buildMatchCard(Match match, bool isWideScreen) {
    final isCompleted = match.isCompleted;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    match.status,
                    style: TextStyle(
                      fontSize: 12,
                      color: isCompleted
                          ? Colors.green[800]
                          : Colors.orange[800],
                    ),
                  ),
                ),
                if (isCompleted && match.result != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      match.result!,
                      style: TextStyle(fontSize: 12, color: Colors.blue[800]),
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
            if (isCompleted) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  match.scoreDisplay,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (isWideScreen)
              _buildWideLayout(match)
            else
              _buildNarrowLayout(match, isCompleted),
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
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (isCompleted) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              _buildGoalDetails(match),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout(Match match) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildTeamLogo(match.homeTeam, size: 50),
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
        if (!match.isCompleted)
          const Text(
            'VS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        Expanded(
          child: Column(
            children: [
              _buildTeamLogo(match.awayTeam, size: 50),
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
    );
  }

  Widget _buildNarrowLayout(Match match, bool isCompleted) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildTeamLogo(match.homeTeam, size: 50),
                  const SizedBox(height: 4),
                  Text(
                    match.homeTeam,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    '主场',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (!isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: const Text(
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
                  _buildTeamLogo(match.awayTeam, size: 50),
                  const SizedBox(height: 4),
                  Text(
                    match.awayTeam,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    '客场',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
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
            children: homeGoalList
                .map(
                  (goal) => Padding(
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
                          color: goal.isOwnGoal
                              ? Colors.red[400]
                              : Colors.green[700],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            goal.isOwnGoal
                                ? '${goal.playerName}(乌龙) ${goal.minute}\''
                                : '${goal.playerName} ${goal.minute}\'',
                            style: TextStyle(
                              fontSize: 11,
                              color: goal.isOwnGoal
                                  ? Colors.red[600]
                                  : Colors.grey[700],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: awayGoalList
                .map(
                  (goal) => Padding(
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
                              color: goal.isOwnGoal
                                  ? Colors.red[600]
                                  : Colors.grey[700],
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
                          color: goal.isOwnGoal
                              ? Colors.red[400]
                              : Colors.green[700],
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
