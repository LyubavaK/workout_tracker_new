import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/storage_service.dart';
import '../models/workout.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StorageService _storage = StorageService();
  List<Workout> _workouts = [];
  bool _isLoading = true;
  String _period = 'week'; // week, month, year

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _workouts = await _storage.loadWorkouts();
    setState(() => _isLoading = false);
  }

  List<Workout> get _filteredWorkouts {
    final now = DateTime.now();
    switch (_period) {
      case 'week':
        return _workouts
            .where((w) => w.date.isAfter(now.subtract(Duration(days: 7))))
            .toList();
      case 'month':
        return _workouts
            .where((w) => w.date.isAfter(now.subtract(Duration(days: 30))))
            .toList();
      case 'year':
        return _workouts.where((w) => w.date.year == now.year).toList();
      default:
        return _workouts;
    }
  }

  int get _totalCalories =>
      _filteredWorkouts.fold(0, (sum, w) => sum + w.totalCalories);
  int get _totalMinutes =>
      _filteredWorkouts.fold(0, (sum, w) => sum + w.totalDuration);
  int get _totalWorkouts => _filteredWorkouts.length;
  double get _avgDuration =>
      _totalWorkouts > 0 ? _totalMinutes / _totalWorkouts : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Статистика'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: DropdownButton<String>(
              value: _period,
              dropdownColor: Colors.deepPurple,
              icon: Icon(Icons.calendar_today, color: Colors.white),
              underline: SizedBox(),
              items: [
                DropdownMenuItem(
                    value: 'week',
                    child:
                        Text('Неделя', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(
                    value: 'month',
                    child:
                        Text('Месяц', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(
                    value: 'year',
                    child: Text('Год', style: TextStyle(color: Colors.white))),
              ],
              onChanged: (value) {
                setState(() => _period = value!);
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Краткая статистика
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard('Тренировок', '$_totalWorkouts',
                              Icons.fitness_center, Colors.blue),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard('Минут', '$_totalMinutes',
                              Icons.timer, Colors.green),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard('Калорий', '$_totalCalories',
                              Icons.local_fire_department, Colors.orange),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Средняя длительность
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.show_chart,
                                color: Colors.deepPurple),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Средняя длительность',
                                    style: TextStyle(color: Colors.grey)),
                                Text(
                                  '${_avgDuration.toInt()} минут',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // График калорий
                    if (_filteredWorkouts.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.bar_chart, color: Colors.deepPurple),
                                SizedBox(width: 8),
                                Text('Динамика калорий',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 16),
                            Container(
                              height: 250,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: _getMaxCalories(),
                                  barGroups: _getBarGroups(),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                        getTitlesWidget: (value, meta) {
                                          return Text('${value.toInt()}',
                                              style: TextStyle(fontSize: 10));
                                        },
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: _getBottomTitles,
                                        reservedSize: 50,
                                      ),
                                    ),
                                  ),
                                  gridData: FlGridData(show: true),
                                  borderData: FlBorderData(show: false),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 20),

                    // Лучшая тренировка
                    if (_filteredWorkouts.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.emoji_events, color: Colors.amber),
                                SizedBox(width: 8),
                                Text('Достижения',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 12),
                            _buildAchievementRow('🏆 Лучшая по калориям',
                                _getBestWorkoutByCalories()),
                            _buildAchievementRow(
                                '⏱️ Самая длительная', _getLongestWorkout()),
                            _buildAchievementRow(
                                '📅 Самый активный день', _getBestDay()),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          SizedBox(height: 8),
          Text(value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  double _getMaxCalories() {
    if (_filteredWorkouts.isEmpty) return 100;
    double max = _filteredWorkouts
        .map((w) => w.totalCalories.toDouble())
        .reduce((a, b) => a > b ? a : b);
    return max * 1.2;
  }

  List<BarChartGroupData> _getBarGroups() {
    List<BarChartGroupData> groups = [];
    List<Workout> workouts = _filteredWorkouts;

    // Показываем последние 7 или 10 тренировок
    int count = workouts.length > 10 ? 10 : workouts.length;
    for (int i = 0; i < count; i++) {
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: workouts[i].totalCalories.toDouble(),
              color: Colors.deepPurple,
              width: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }
    return groups;
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    List<Workout> workouts = _filteredWorkouts;
    int index = value.toInt();
    if (index >= workouts.length) return Text('');
    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: Text(
        DateFormat('dd.MM').format(workouts[index].date),
        style: TextStyle(fontSize: 10),
      ),
    );
  }

  String _getBestWorkoutByCalories() {
    if (_filteredWorkouts.isEmpty) return 'Нет данных';
    final best = _filteredWorkouts
        .reduce((a, b) => a.totalCalories > b.totalCalories ? a : b);
    return '${best.totalCalories} ккал (${DateFormat('dd.MM').format(best.date)})';
  }

  String _getLongestWorkout() {
    if (_filteredWorkouts.isEmpty) return 'Нет данных';
    final longest = _filteredWorkouts
        .reduce((a, b) => a.totalDuration > b.totalDuration ? a : b);
    return '${longest.totalDuration} минут (${DateFormat('dd.MM').format(longest.date)})';
  }

  String _getBestDay() {
    if (_filteredWorkouts.isEmpty) return 'Нет данных';
    Map<String, int> days = {};
    for (var w in _filteredWorkouts) {
      String key = DateFormat('dd.MM').format(w.date);
      days[key] = (days[key] ?? 0) + 1;
    }
    String bestDay = '';
    int maxCount = 0;
    days.forEach((day, count) {
      if (count > maxCount) {
        maxCount = count;
        bestDay = day;
      }
    });
    return '$bestDay ($maxCount тренировок)';
  }

  Widget _buildAchievementRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(title, style: TextStyle(color: Colors.grey))),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
