import 'package:flutter/material.dart';
import 'models/league_data.dart';
import 'services/data_service.dart';
import 'pages/matches_page.dart';
import 'pages/standings_page.dart';
import 'pages/goal_scorers_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '江苏省城市足球联赛',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const LeagueHomePage(),
    );
  }
}

class LeagueHomePage extends StatefulWidget {
  const LeagueHomePage({super.key});

  @override
  State<LeagueHomePage> createState() => _LeagueHomePageState();
}

class _LeagueHomePageState extends State<LeagueHomePage> {
  int _currentIndex = 0;
  LeagueData? _leagueData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await DataService.loadLeagueData();
      setState(() {
        _leagueData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载数据失败: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('加载联赛数据中...', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: Colors.red[700])),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadData, child: const Text('重新加载')),
            ],
          ),
        ),
      );
    }

    final pages = [
      MatchesPage(matches: _leagueData!.matches),
      StandingsPage(standings: _leagueData!.standings),
      GoalScorersPage(goalScorers: _leagueData!.goalScorers),
    ];

    final titles = ['赛程', '积分榜', '射手榜'];

    return Scaffold(
      appBar: AppBar(
        title: Text('${_leagueData!.leagueName} - ${titles[_currentIndex]}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: '刷新数据',
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calendar_today), label: '赛程'),
          NavigationDestination(icon: Icon(Icons.table_chart), label: '积分榜'),
          NavigationDestination(icon: Icon(Icons.sports_soccer), label: '射手榜'),
        ],
      ),
    );
  }
}
