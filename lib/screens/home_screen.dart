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
        title: Text(
          'Мои тренировки',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
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
                    // Приветствие
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple.shade700,
                            Colors.deepPurple.shade900
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
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
                                Text(
                                  DateFormat('dd MMMM yyyy', 'ru')
                                      .format(DateTime.now()),
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 14),
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

                    // Последние тренировки
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '📋 Последние тренировки',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
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
                        ? Container(
                            padding: EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.sports_gymnastics,
                                    size: 64, color: Colors.grey.shade400),
                                SizedBox(height: 16),
                                Text(
                                  'Нет тренировок',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade600),
                                ),
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
                                _workouts.length > 3 ? 3 : _workouts.length,
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
                                child: ListTile(
                                  leading: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.fitness_center,
                                        color: Colors.deepPurple),
                                  ),
                                  title: Text(
                                    DateFormat('dd MMMM yyyy', 'ru')
                                        .format(workout.date),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    '${workout.totalDuration} мин • ${workout.totalCalories} ккал',
                                  ),
                                  trailing: Icon(Icons.chevron_right,
                                      color: Colors.grey),
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
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  void _showWorkoutDetails(Workout workout) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(DateFormat('dd MMMM yyyy', 'ru').format(workout.date)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
                Icons.timer, 'Длительность', '${workout.totalDuration} минут'),
            SizedBox(height: 8),
            _buildDetailRow(Icons.local_fire_department, 'Калории',
                '${workout.totalCalories} ккал'),
            SizedBox(height: 8),
            _buildDetailRow(Icons.fitness_center, 'Упражнений',
                '${workout.exercises.length}'),
            if (workout.notes.isNotEmpty) ...[
              SizedBox(height: 12),
              Divider(),
              Text('Заметки:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        SizedBox(width: 12),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        Spacer(),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
