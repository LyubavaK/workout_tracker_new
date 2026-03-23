import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout.dart';
import '../models/exercise.dart';

class StorageService {
  static const String _workoutsKey = 'workouts';

  Future<void> saveWorkouts(List<Workout> workouts) async {
    final prefs = await SharedPreferences.getInstance();
    final workoutsJson = workouts
        .map((w) => {
              'id': w.id,
              'date': w.date.toIso8601String(),
              'notes': w.notes,
              'exercises': w.exercises
                  .map((e) => {
                        'id': e.id,
                        'name': e.name,
                        'durationMinutes': e.durationMinutes,
                        'caloriesPerMinute': e.caloriesPerMinute,
                      })
                  .toList(),
            })
        .toList();
    await prefs.setString(_workoutsKey, jsonEncode(workoutsJson));
  }

  Future<List<Workout>> loadWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? workoutsString = prefs.getString(_workoutsKey);

    if (workoutsString == null) return [];

    final List<dynamic> workoutsJson = jsonDecode(workoutsString);
    return workoutsJson.map((json) {
      return Workout(
        id: json['id'],
        date: DateTime.parse(json['date']),
        notes: json['notes'] ?? '',
        exercises: (json['exercises'] as List)
            .map((e) => Exercise(
                  id: e['id'],
                  name: e['name'],
                  durationMinutes: e['durationMinutes'],
                  caloriesPerMinute: e['caloriesPerMinute'],
                ))
            .toList(),
      );
    }).toList();
  }

  Future<void> addWorkout(Workout workout) async {
    final workouts = await loadWorkouts();
    workouts.add(workout);
    await saveWorkouts(workouts);
  }

  Future<void> deleteWorkout(String id) async {
    final workouts = await loadWorkouts();
    workouts.removeWhere((w) => w.id == id);
    await saveWorkouts(workouts);
  }
}
