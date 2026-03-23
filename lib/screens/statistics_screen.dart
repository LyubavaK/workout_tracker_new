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

  int get _totalCalories {
    int total = 0;
    for (var w in _filteredWorkouts) {
      total += w.totalCalories;
    }
    return total;
  }

  int get _totalMinutes {
    int total = 0;
    for (var w in _filteredWorkouts) {
      total += w.totalDuration;
    }
    return total;
  }

  int get _totalWorkouts => _filteredWorkouts.length;

  double get _avgDuration =>
      _totalWorkouts > 0 ? _totalMinutes / _totalWorkouts : 0;

  double get _avgCalories =>
      _totalWorkouts > 0 ? _totalCalories / _totalWorkouts : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Статистика',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
              style: TextStyle(color: Colors.white, fontSize: 16),
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
                DropdownMenuItem(
                    value: 'all',
                    child: Text('Всё время',
                        style: TextStyle(color: Colors.white))),
              ],
              onChanged: (value) {
                setState(() => _period = value!);
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.deepPurple),
                  SizedBox(height: 16),
                  Text('Загрузка...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: Colors.deepPurple,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Краткая статистика - улучшенная видимость
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Тренировок',
                            '$_totalWorkouts',
                            Icons.fitness_center,
                            Colors.blue,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Минут',
                            '$_totalMinutes',
                            Icons.timer,
                            Colors.green,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Калорий',
                            '$_totalCalories',
                            Icons.local_fire_department,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Средние показатели
                    Row(
                      children: [
                        Expanded(
                          child: _buildAverageCard(
                            'Средняя длительность',
                            '${_avgDuration.toInt()} мин',
                            Icons.timer,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildAverageCard(
                            'Средние калории',
                            '${_avgCalories.toInt()} ккал',
                            Icons.local_fire_department,
                          ),
                        ),
                      ],
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
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.bar_chart,
                                      color: Colors.deepPurple, size: 20),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Динамика калорий',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
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
                                          return Text(
                                            '${value.toInt()}',
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500),
                                          );
                                        },
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: _getBottomTitles,
                                        reservedSize: 40,
                                      ),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawHorizontalLine: true,
                                    drawVerticalLine: false,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: Colors.grey.shade300,
                                        strokeWidth: 0.5,
                                      );
                                    },
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 0.5),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 20),

                    // Достижения
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
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.emoji_events,
                                      color: Colors.amber.shade700, size: 20),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Достижения',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            _buildAchievementRow('🏆 Лучшая по калориям',
                                _getBestWorkoutByCalories()),
                            SizedBox(height: 12),
                            _buildAchievementRow(
                                '⏱️ Самая длительная', _getLongestWorkout()),
                            SizedBox(height: 12),
                            _buildAchievementRow(
                                '📅 Самый активный день', _getBestDay()),
                            SizedBox(height: 12),
                            _buildAchievementRow('💪 Любимое упражнение',
                                _getFavoriteExercise()),
                          ],
                        ),
                      ),

                    if (_filteredWorkouts.isEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 50),
                        child: Column(
                          children: [
                            Icon(Icons.show_chart,
                                size: 64, color: Colors.grey.shade400),
                            SizedBox(height: 16),
                            Text(
                              'Нет данных для статистики',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey.shade600),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Добавьте тренировки чтобы увидеть статистику',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 20),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.9),
            color.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: Colors.white),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildAverageCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: Colors.deepPurple),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxCalories() {
    if (_filteredWorkouts.isEmpty) return 100;
    double max = 0;
    for (var w in _filteredWorkouts) {
      if (w.totalCalories > max) max = w.totalCalories.toDouble();
    }
    return max * 1.2;
  }

  List<BarChartGroupData> _getBarGroups() {
    List<BarChartGroupData> groups = [];
    List<Workout> workouts = _filteredWorkouts;

    // Показываем последние 7 тренировок для недели, или 10 для месяца/года
    int count = workouts.length > 10 ? 10 : workouts.length;
    for (int i = 0; i < count; i++) {
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: workouts[i].totalCalories.toDouble(),
              color: Colors.deepPurple,
              width: 25,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }
    return groups.reversed.toList();
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    List<Workout> workouts = _filteredWorkouts;
    int index = value.toInt();
    if (index >= workouts.length) return Text('');
    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: Text(
        DateFormat('dd.MM').format(workouts[index].date),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
      ),
    );
  }

  String _getBestWorkoutByCalories() {
    if (_filteredWorkouts.isEmpty) return 'Нет данных';
    Workout? best;
    for (var w in _filteredWorkouts) {
      if (best == null || w.totalCalories > best.totalCalories) {
        best = w;
      }
    }
    return '${best!.totalCalories} ккал (${DateFormat('dd.MM').format(best.date)})';
  }

  String _getLongestWorkout() {
    if (_filteredWorkouts.isEmpty) return 'Нет данных';
    Workout? longest;
    for (var w in _filteredWorkouts) {
      if (longest == null || w.totalDuration > longest.totalDuration) {
        longest = w;
      }
    }
    return '${longest!.totalDuration} мин (${DateFormat('dd.MM').format(longest.date)})';
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

  String _getFavoriteExercise() {
    if (_filteredWorkouts.isEmpty) return 'Нет данных';
    Map<String, int> exercises = {};
    for (var w in _filteredWorkouts) {
      for (var e in w.exercises) {
        String name = e.name.replaceAll(RegExp(r'[🏋️🦵🧘🏃💪⚡]'), '').trim();
        exercises[name] = (exercises[name] ?? 0) + 1;
      }
    }
    String favorite = '';
    int maxCount = 0;
    exercises.forEach((name, count) {
      if (count > maxCount) {
        maxCount = count;
        favorite = name;
      }
    });
    return '$favorite ($maxCount раз)';
  }

  Widget _buildAchievementRow(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
