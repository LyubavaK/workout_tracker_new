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
    _workouts.sort((a, b) => b.date.compareTo(a.date));
    setState(() => _isLoading = false);
  }

  Future<void> _deleteWorkout(Workout workout) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Удалить тренировку',
          style: TextStyle(color: Colors.deepPurple),
        ),
        content: Text(
          'Удалить тренировку от ${DateFormat('dd.MM.yyyy').format(workout.date)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              // Удаляем тренировку
              await _storage.deleteWorkout(workout.id);
              Navigator.pop(context);

              // Обновляем список
              await _loadWorkouts();

              // Показываем уведомление
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Тренировка удалена'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
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
        title: Text(
          'История тренировок',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Возвращаемся на главный экран и обновляем его
            Navigator.pop(context, true);
          },
        ),
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
          : _workouts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history,
                          size: 80, color: Colors.grey.shade300),
                      SizedBox(height: 16),
                      Text(
                        'Нет тренировок',
                        style: TextStyle(
                            fontSize: 18, color: Colors.grey.shade600),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Добавьте первую тренировку',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadWorkouts,
                  color: Colors.deepPurple,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _workouts.length,
                    itemBuilder: (context, index) {
                      final workout = _workouts[index];
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
                        child: Column(
                          children: [
                            // Основная информация
                            Material(
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
                                        child: Icon(
                                          Icons.fitness_center,
                                          color: Colors.deepPurple,
                                          size: 24,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              DateFormat('dd MMMM yyyy', 'ru')
                                                  .format(workout.date),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              '${workout.totalDuration} мин • ${workout.totalCalories} ккал',
                                              style: TextStyle(
                                                fontSize: 13,
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
                                      // Кнопка удаления (без меню)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: IconButton(
                                          icon: Icon(Icons.delete_outline,
                                              color: Colors.red.shade400,
                                              size: 22),
                                          onPressed: () =>
                                              _deleteWorkout(workout),
                                          tooltip: 'Удалить',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
}
