import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../models/workout.dart';
import 'add_workout_screen.dart';
import 'history_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Мои тренировки'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              ).then((_) => _loadData());
            },
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
                    // Статистика
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStat('Тренировок', '$_totalWorkouts',
                                Icons.fitness_center, Colors.blue),
                            _buildStat('Минут', '$_totalMinutes', Icons.timer,
                                Colors.green),
                            _buildStat('Калорий', '$_totalCalories',
                                Icons.local_fire_department, Colors.orange),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Последние тренировки
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Последние тренировки',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HistoryScreen()),
                            );
                          },
                          child: Text('Все'),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    _workouts.isEmpty
                        ? Center(
                            child: Column(
                              children: [
                                SizedBox(height: 50),
                                Icon(Icons.sports_gymnastics,
                                    size: 80, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('Нет тренировок',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.grey)),
                                Text('Нажмите + чтобы добавить',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount:
                                _workouts.length > 3 ? 3 : _workouts.length,
                            itemBuilder: (context, index) {
                              final workout =
                                  _workouts.reversed.toList()[index];
                              return Card(
                                margin: EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.deepPurple,
                                    child: Icon(Icons.fitness_center,
                                        color: Colors.white),
                                  ),
                                  title: Text(
                                    DateFormat('dd.MM.yyyy').format(
                                        workout.date), // Простой формат даты
                                  ),
                                  subtitle: Text(
                                    '${workout.totalDuration} мин • ${workout.totalCalories} ккал',
                                  ),
                                  trailing: Icon(Icons.chevron_right),
                                  onTap: () {
                                    _showWorkoutDetails(workout);
                                  },
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddWorkoutScreen()),
          );
          _loadData();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 28, color: color),
        SizedBox(height: 8),
        Text(value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  void _showWorkoutDetails(Workout workout) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(DateFormat('dd.MM.yyyy').format(workout.date)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Длительность: ${workout.totalDuration} минут'),
            Text('Калории: ${workout.totalCalories} ккал'),
            Text('Упражнений: ${workout.exercises.length}'),
            if (workout.notes.isNotEmpty) ...[
              SizedBox(height: 8),
              Divider(),
              Text('Заметки:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(workout.notes),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}
