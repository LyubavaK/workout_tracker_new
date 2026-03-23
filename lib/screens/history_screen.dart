import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../models/workout.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final StorageService _storage = StorageService();
  List<Workout> _workouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() => _isLoading = true);
    _workouts = await _storage.loadWorkouts();
    _workouts.sort(
        (a, b) => b.date.compareTo(a.date)); // Сортировка от новых к старым
    setState(() => _isLoading = false);
  }

  Future<void> _deleteWorkout(Workout workout) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удалить тренировку'),
        content: Text(
            'Удалить тренировку от ${DateFormat('dd.MM.yyyy').format(workout.date)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              await _storage.deleteWorkout(workout.id);
              Navigator.pop(context);
              _loadWorkouts();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Тренировка удалена')),
              );
            },
            child: Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('История тренировок'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _workouts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Нет тренировок',
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('Добавьте первую тренировку',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _workouts.length,
                  itemBuilder: (context, index) {
                    final workout = _workouts[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child:
                              Icon(Icons.fitness_center, color: Colors.white),
                        ),
                        title: Text(
                          DateFormat('dd.MM.yyyy')
                              .format(workout.date), // Простой формат даты
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${workout.totalDuration} мин • ${workout.totalCalories} ккал • ${workout.exercises.length} упр.',
                        ),
                        trailing: PopupMenuButton(
                          icon: Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: Text('Удалить'),
                              onTap: () => _deleteWorkout(workout),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Упражнения:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                SizedBox(height: 8),
                                ...workout.exercises.map((exercise) => Padding(
                                      padding: EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(exercise.name),
                                          Text(
                                            '${exercise.durationMinutes} мин • ${exercise.caloriesBurned} ккал',
                                            style: TextStyle(
                                                color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    )),
                                if (workout.notes.isNotEmpty) ...[
                                  SizedBox(height: 12),
                                  Divider(),
                                  SizedBox(height: 8),
                                  Text(
                                    'Заметки:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  SizedBox(height: 4),
                                  Text(workout.notes),
                                ],
                                SizedBox(height: 8),
                                Divider(),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Всего времени:',
                                        style: TextStyle(color: Colors.grey)),
                                    Text('${workout.totalDuration} мин',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Всего калорий:',
                                        style: TextStyle(color: Colors.grey)),
                                    Text('${workout.totalCalories} ккал',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
