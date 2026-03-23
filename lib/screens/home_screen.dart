import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../models/workout.dart';
import 'add_workout_screen.dart';
import 'history_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();
  List<Workout> _workouts = [];
  bool _isLoading = true;

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

  int get _totalWorkouts => _workouts.length;
  int get _totalMinutes => _workouts.fold(0, (sum, w) => sum + w.totalDuration);
  int get _totalCalories =>
      _workouts.fold(0, (sum, w) => sum + w.totalCalories);
  int get _currentStreak => _calculateStreak();

  int _calculateStreak() {
    if (_workouts.isEmpty) return 0;

    final dates = _workouts
        .map((w) => DateTime(w.date.year, w.date.month, w.date.day))
        .toSet()
        .toList();
    dates.sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime? lastDate;
    final now = DateTime.now();

    for (var date in dates) {
      if (lastDate == null) {
        if (date.isAfter(now.subtract(Duration(days: 1)))) {
          streak = 1;
          lastDate = date;
        } else {
          break;
        }
      } else if (lastDate.difference(date).inDays == 1) {
        streak++;
        lastDate = date;
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Мои тренировки',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StatisticsScreen()),
              );
            },
            tooltip: 'Статистика',
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              ).then((_) => _loadData());
            },
            tooltip: 'История',
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
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Приветствие
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.deepPurple.shade700,
                            Colors.deepPurple.shade900,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.3),
                            blurRadius: 15,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(Icons.sports_gymnastics,
                                color: Colors.white, size: 32),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Привет, спортсмен!',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  DateFormat('dd MMMM yyyy', 'ru')
                                      .format(DateTime.now()),
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          if (_currentStreak > 0)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade400,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.local_fire_department,
                                      color: Colors.white,
                                      size: 16), // Изменено
                                  SizedBox(width: 4),
                                  Text(
                                    '$_currentStreak',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Статистика
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

                    SizedBox(height: 24),

                    // Быстрые действия
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAction(
                            icon: Icons.add,
                            label: 'Новая\nтренировка',
                            color: Colors.deepPurple,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddWorkoutScreen()),
                              );
                              _loadData();
                            },
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickAction(
                            icon: Icons.bar_chart,
                            label: 'Статистика',
                            color: Colors.blue,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => StatisticsScreen()),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickAction(
                            icon: Icons.history,
                            label: 'История',
                            color: Colors.green,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HistoryScreen()),
                              ).then((_) => _loadData());
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Последние тренировки
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.fitness_center,
                                color: Colors.deepPurple, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Последние тренировки',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HistoryScreen()),
                            );
                          },
                          child: Text('Все',
                              style: TextStyle(color: Colors.deepPurple)),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    _workouts.isEmpty
                        ? Container(
                            padding: EdgeInsets.symmetric(vertical: 50),
                            child: Column(
                              children: [
                                Icon(Icons.sports_gymnastics,
                                    size: 80, color: Colors.grey.shade300),
                                SizedBox(height: 16),
                                Text(
                                  'Нет тренировок',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade600),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Нажмите + чтобы добавить',
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount:
                                _workouts.length > 5 ? 5 : _workouts.length,
                            itemBuilder: (context, index) {
                              final workout =
                                  _workouts.reversed.toList()[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 10,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () => _showWorkoutDetails(workout),
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.deepPurple.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(Icons.fitness_center,
                                                color: Colors.deepPurple,
                                                size: 24),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  DateFormat(
                                                          'dd MMMM yyyy', 'ru')
                                                      .format(workout.date),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  '${workout.totalDuration} мин • ${workout.totalCalories} ккал',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                                Text(
                                                  '${workout.exercises.length} упражнений',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(Icons.chevron_right,
                                              color: Colors.grey.shade400),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                    SizedBox(height: 16),

                    // Мотивационная фраза
                    if (_workouts.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.emoji_emotions,
                                color: Colors.deepPurple.shade400),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _getMotivationalQuote(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.deepPurple.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddWorkoutScreen()),
          );
          _loadData();
        },
        icon: Icon(Icons.add),
        label: Text('Новая тренировка'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4,
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
            spreadRadius: 1,
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
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500, color: color),
            ),
          ],
        ),
      ),
    );
  }

  void _showWorkoutDetails(Workout workout) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.fitness_center, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text(
              DateFormat('dd MMMM yyyy', 'ru').format(workout.date),
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
                Icons.timer, 'Длительность', '${workout.totalDuration} минут'),
            SizedBox(height: 12),
            _buildDetailRow(Icons.local_fire_department, 'Калории',
                '${workout.totalCalories} ккал'),
            SizedBox(height: 12),
            _buildDetailRow(Icons.fitness_center, 'Упражнений',
                '${workout.exercises.length}'),
            SizedBox(height: 12),
            _buildDetailRow(Icons.list, 'Упражнения',
                workout.exercises.map((e) => e.name).join(', ')),
            if (workout.notes.isNotEmpty) ...[
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 8),
              Text('📝 Заметки:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(workout.notes,
                  style: TextStyle(color: Colors.grey.shade700)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть', style: TextStyle(color: Colors.deepPurple)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple.shade400),
        SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w500),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  String _getMotivationalQuote() {
    List<String> quotes = [
      '🏆 Ты уже на пути к великим результатам!',
      '💪 Каждая тренировка приближает тебя к цели!',
      '⭐ Ты молодец, что не сдаёшься!',
      '🔥 Продолжай в том же духе!',
      '🎯 Ты становишься сильнее с каждой тренировкой!',
      '🌟 80% успеха - это просто начать!',
      '⚡ Дисциплина побеждает мотивацию!',
    ];
    return quotes[_totalWorkouts % quotes.length];
  }
}
