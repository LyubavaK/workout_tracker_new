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
        id: '1', name: 'Отжимания', durationMinutes: 5, caloriesPerMinute: 7),
    Exercise(
        id: '2', name: 'Приседания', durationMinutes: 5, caloriesPerMinute: 8),
    Exercise(id: '3', name: 'Планка', durationMinutes: 3, caloriesPerMinute: 5),
    Exercise(id: '4', name: 'Бег', durationMinutes: 10, caloriesPerMinute: 10),
    Exercise(
        id: '5', name: 'Скручивания', durationMinutes: 5, caloriesPerMinute: 6),
    Exercise(id: '6', name: 'Берпи', durationMinutes: 3, caloriesPerMinute: 12),
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
      locale: Locale('ru', 'RU'),
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
        SnackBar(content: Text('Добавьте хотя бы одно упражнение')),
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
      SnackBar(content: Text('Тренировка сохранена!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Новая тренировка'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Дата (простой числовой формат)
          Card(
            child: ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.deepPurple),
              title: Text('Дата тренировки'),
              subtitle: Text(
                  DateFormat('dd.MM.yyyy').format(_selectedDate)), // Упрощенно
              onTap: () => _selectDate(context),
            ),
          ),

          SizedBox(height: 16),

          // Упражнения
          Card(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Упражнения',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: Colors.deepPurple),
                        onPressed: () => _showExerciseDialog(),
                      ),
                    ],
                  ),
                ),
                if (_selectedExercises.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.fitness_center,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Нажмите + чтобы добавить упражнения'),
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
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                          backgroundColor: Colors.deepPurple,
                        ),
                        title: Text(exercise.name),
                        subtitle: Text(
                            '${exercise.durationMinutes} мин • ${exercise.caloriesBurned} ккал'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeExercise(index),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Заметки
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Заметки',
                  hintText: 'Ваши впечатления...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _notes = value,
              ),
            ),
          ),

          SizedBox(height: 16),

          // Итог
          Card(
            color: Colors.deepPurple.shade50,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('Время', style: TextStyle(color: Colors.grey)),
                      Text('$_totalDuration мин',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('Калории', style: TextStyle(color: Colors.grey)),
                      Text('$_totalCalories ккал',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('Упражнений', style: TextStyle(color: Colors.grey)),
                      Text('${_selectedExercises.length}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          ElevatedButton(
            onPressed: _saveWorkout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text('Сохранить тренировку', style: TextStyle(fontSize: 16)),
          ),
        ],
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
          height: 400,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Text('Выберите упражнение',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _availableExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _availableExercises[index];
                    final isSelected = _selectedExercises.contains(exercise);
                    return ListTile(
                      leading: Icon(
                        isSelected ? Icons.check_circle : Icons.fitness_center,
                        color: isSelected ? Colors.green : Colors.grey,
                      ),
                      title: Text(exercise.name),
                      subtitle: Text(
                          '${exercise.durationMinutes} мин • ${exercise.caloriesBurned} ккал'),
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
