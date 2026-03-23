import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../models/exercise.dart';
import '../models/workout.dart';

class AddWorkoutScreen extends StatefulWidget {
  @override
  _AddWorkoutScreenState createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final StorageService _storage = StorageService();
  DateTime _selectedDate = DateTime.now();
  List<Exercise> _selectedExercises = [];
  String _notes = '';

  final List<Exercise> _availableExercises = [
    Exercise(
        id: '1',
        name: '🏋️ Отжимания',
        durationMinutes: 5,
        caloriesPerMinute: 7),
    Exercise(
        id: '2',
        name: '🦵 Приседания',
        durationMinutes: 5,
        caloriesPerMinute: 8),
    Exercise(
        id: '3', name: '🧘 Планка', durationMinutes: 3, caloriesPerMinute: 5),
    Exercise(
        id: '4', name: '🏃 Бег', durationMinutes: 10, caloriesPerMinute: 10),
    Exercise(
        id: '5',
        name: '💪 Скручивания',
        durationMinutes: 5,
        caloriesPerMinute: 6),
    Exercise(
        id: '6', name: '⚡ Берпи', durationMinutes: 3, caloriesPerMinute: 12),
  ];

  int get _totalDuration =>
      _selectedExercises.fold(0, (sum, e) => sum + e.durationMinutes);
  int get _totalCalories =>
      _selectedExercises.fold(0, (sum, e) => sum + e.caloriesBurned);

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _addExercise(Exercise exercise) {
    setState(() {
      _selectedExercises.add(exercise);
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _selectedExercises.removeAt(index);
    });
  }

  Future<void> _saveWorkout() async {
    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Добавьте хотя бы одно упражнение'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final workout = Workout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _selectedDate,
      exercises: _selectedExercises,
      notes: _notes,
    );

    await _storage.addWorkout(workout);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Тренировка сохранена!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Новая тренировка'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Дата тренировки
            Container(
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
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.calendar_today, color: Colors.deepPurple),
                ),
                title: Text('Дата тренировки',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  DateFormat('dd MMMM yyyy', 'ru').format(_selectedDate),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                onTap: () => _selectDate(context),
              ),
            ),

            SizedBox(height: 20),

            // Упражнения
            Container(
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
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.fitness_center,
                                  color: Colors.deepPurple),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Упражнения',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showExerciseDialog(),
                          icon: Icon(Icons.add, size: 18),
                          label: Text('Добавить'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_selectedExercises.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.fitness_center,
                              size: 64, color: Colors.grey.shade300),
                          SizedBox(height: 16),
                          Text(
                            'Нет упражнений',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey.shade600),
                          ),
                          Text(
                            'Нажмите "Добавить" чтобы выбрать',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _selectedExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = _selectedExercises[index];
                        return Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.deepPurple,
                              child: Text('${index + 1}',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            title: Text(exercise.name,
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            subtitle: Text(
                              '${exercise.durationMinutes} мин • ${exercise.caloriesBurned} ккал',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline,
                                  color: Colors.red.shade400),
                              onPressed: () => _removeExercise(index),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Заметки
            Container(
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
              child: Padding(
                padding: EdgeInsets.all(16),
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
                          child: Icon(Icons.note, color: Colors.deepPurple),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Заметки',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Ваши впечатления, успехи, сложности...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.deepPurple, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      onChanged: (value) => _notes = value,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Итоговая информация
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade700,
                    Colors.deepPurple.shade900
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 15,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Icon(Icons.timer, color: Colors.white70, size: 28),
                        SizedBox(height: 8),
                        Text(
                          '$_totalDuration',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text('минут',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.white30,
                    ),
                    Column(
                      children: [
                        Icon(Icons.local_fire_department,
                            color: Colors.orange.shade300, size: 28),
                        SizedBox(height: 8),
                        Text(
                          '$_totalCalories',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text('калорий',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.white30,
                    ),
                    Column(
                      children: [
                        Icon(Icons.fitness_center,
                            color: Colors.white70, size: 28),
                        SizedBox(height: 8),
                        Text(
                          '${_selectedExercises.length}',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text('упражнений',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            // Кнопка сохранения - УЛУЧШЕННАЯ
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  shadowColor: Colors.deepPurple.withOpacity(0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'СОХРАНИТЬ ТРЕНИРОВКУ',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showExerciseDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: 500,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Text(
                  'Выберите упражнение',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _availableExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _availableExercises[index];
                    final isSelected = _selectedExercises.contains(exercise);
                    return ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.green.shade100
                              : Colors.deepPurple.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isSelected ? Icons.check : Icons.fitness_center,
                          color: isSelected ? Colors.green : Colors.deepPurple,
                        ),
                      ),
                      title: Text(
                        exercise.name,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                          '${exercise.durationMinutes} мин • ${exercise.caloriesBurned} ккал'),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      onTap: () {
                        if (!isSelected) {
                          _addExercise(exercise);
                        }
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
