import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meal_management/core/data/firestore_service.dart';
import 'package:meal_management/core/theme/app_palette.dart';
import 'package:meal_management/core/widgets/custom_card.dart';
import 'package:meal_management/features/auth/data/auth_service.dart';
import 'package:table_calendar/table_calendar.dart';

class MealsPage extends StatefulWidget {
  const MealsPage({super.key});

  @override
  State<MealsPage> createState() => _MealsPageState();
}

class _MealsPageState extends State<MealsPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;
  DateTimeRange? _selectedRange;
  DateTime? _lastTapTime;

  final Map<DateTime, bool> _mealStatusByDate = {};
  final Map<DateTime, Map<String, dynamic>> _mealDetailsByDate = {};
  Map<String, bool> _routineDays = {};
  Map<String, bool> _routineMealTimes = {};
  final FirestoreService _firestore = FirestoreService();
  StreamSubscription? _mealsSubscription;

  @override
  void initState() {
    super.initState();
    _listenToMeals();
    _loadUserPreferences();
  }

  @override
  void dispose() {
    _mealsSubscription?.cancel();
    super.dispose();
  }

  void _listenToMeals() {
    final user = AuthService().currentUser;
    if (user != null) {
      _mealsSubscription = _firestore.getMeals(user.uid).listen((meals) {
        setState(() {
          _mealStatusByDate.clear();
          _mealDetailsByDate.clear();
          for (var meal in meals) {
            final dateStr = meal['date'] as String?;
            final status = meal['status'] as bool?;
            final mealDetails = meal['meals'] as Map<String, dynamic>?;
            if (dateStr != null && status != null) {
              final date = DateTime.parse(dateStr);
              final key = _normalize(date);
              _mealStatusByDate[key] = status;
              if (mealDetails != null) {
                _mealDetailsByDate[key] = Map<String, dynamic>.from(mealDetails);
              }
            }
          }

        });
      });
    }
  }

  Future<void> _loadUserPreferences() async {
    final user = AuthService().currentUser;
    if (user != null) {
      final preferences = await _firestore.getUserPreferences(user.uid);
      if (preferences != null) {
        if (preferences.containsKey('selectedDateRange')) {
          final rangeData = preferences['selectedDateRange'] as Map<String, dynamic>;
          setState(() {
            _selectedRange = DateTimeRange(
              start: DateTime.parse(rangeData['start']),
              end: DateTime.parse(rangeData['end']),
            );
            _rangeStart = _selectedRange!.start;
            _rangeEnd = _selectedRange!.end;
            _focusedDay = _selectedRange!.start;
          });
        }
        if (preferences.containsKey('routine')) {
          final routine = preferences['routine'] as Map<String, dynamic>;
          final days = routine['days'] as Map<String, dynamic>?;
          final mealTimes = routine['mealTimes'] as Map<String, dynamic>?;
          setState(() {
            if (days != null) {
              _routineDays = Map<String, bool>.from(days);
            }
            if (mealTimes != null) {
              _routineMealTimes = Map<String, bool>.from(mealTimes);
            }
          });
        }
      }
    }
  }



  DateTime _normalize(DateTime day) => DateTime(day.year, day.month, day.day);

  bool? _statusForDay(DateTime day) {
    final normalizedDay = _normalize(day);
    if (_mealStatusByDate.containsKey(normalizedDay)) {
      return _mealStatusByDate[normalizedDay];
    }
    
    // Fallback to routine
    final weekdayStr = _getWeekdayStr(day);
    final dayActive = _routineDays[weekdayStr];
    if (dayActive != null) {
      return dayActive;
    }
    
    return null;
  }

  String _getWeekdayStr(DateTime day) {
    switch (day.weekday) {
      case DateTime.monday: return 'Mon';
      case DateTime.tuesday: return 'Tue';
      case DateTime.wednesday: return 'Wed';
      case DateTime.thursday: return 'Thu';
      case DateTime.friday: return 'Fri';
      case DateTime.saturday: return 'Sat';
      case DateTime.sunday: return 'Sun';
      default: return '';
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meals'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [


          const SizedBox(height: 12),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Calendar',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 12),
                TableCalendar<void>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2035, 12, 31),
                  focusedDay: _focusedDay,
                  rangeStartDay: _rangeStart,
                  rangeEndDay: _rangeEnd,
                  rangeSelectionMode: _rangeSelectionMode,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    final now = DateTime.now();
                    
                    // Double tap for single day detail
                    if (_lastTapTime != null && 
                        now.difference(_lastTapTime!) < const Duration(milliseconds: 500) &&
                        isSameDay(_selectedDay, selectedDay)) {
                      _showDayStatusBottomSheet(selectedDay);
                      _lastTapTime = now;
                      return;
                    }
                    _lastTapTime = now;

                    setState(() {
                      _focusedDay = focusedDay;
                      
                      if (_rangeStart == null) {
                        _rangeStart = selectedDay;
                        _rangeEnd = null;
                        _selectedDay = selectedDay;
                      } else if (_rangeEnd == null) {
                        if (isSameDay(_rangeStart, selectedDay)) {
                           // Tapped same day twice slowly, treat as single day selection?
                           // Actually let's just make it a single day range
                           _rangeEnd = selectedDay;
                        } else if (selectedDay.isBefore(_rangeStart!)) {
                           _rangeEnd = _rangeStart;
                           _rangeStart = selectedDay;
                        } else {
                           _rangeEnd = selectedDay;
                        }
                        _selectedDay = null;
                        
                        // Range completed! Show bottom sheet
                        if (_rangeStart != null && _rangeEnd != null) {
                           _showRangeStatusBottomSheet(_rangeStart!, _rangeEnd!);
                        }
                      } else {
                        // Start a new range
                        _rangeStart = selectedDay;
                        _rangeEnd = null;
                        _selectedDay = selectedDay;
                      }
                    });
                  },
                  onRangeSelected: (start, end, focusedDay) {
                    // Fallback for native TableCalendar range gesture (long-press then drag/tap)
                    setState(() {
                      _selectedDay = null;
                      _focusedDay = focusedDay;
                      _rangeStart = start;
                      _rangeEnd = end;
                    });
                    if (start != null && end != null) {
                      _showRangeStatusBottomSheet(start, end);
                    } else if (start != null && end == null) {
                      // Handled by onDaySelected effectively
                    }
                  },
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      final status = _statusForDay(day);
                      if (status == null) {
                        return const SizedBox.shrink();
                      }
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: status ? AppPallate.success : AppPallate.danger,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                  calendarStyle: const CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: AppPallate.primary,
                      shape: BoxShape.circle,
                    ),
                    rangeStartDecoration: BoxDecoration(
                      color: AppPallate.primary,
                      shape: BoxShape.circle,
                    ),
                    rangeEndDecoration: BoxDecoration(
                      color: AppPallate.primary,
                      shape: BoxShape.circle,
                    ),
                    rangeHighlightColor: Color(0xFFDFECDE),
                    todayDecoration: BoxDecoration(
                      color: Color(0xFFB8DDBA),
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    _LegendDot(color: AppPallate.success, label: 'ON'),
                    SizedBox(width: 16),
                    _LegendDot(color: AppPallate.danger, label: 'OFF'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // _DateMenuCard(
          //   date: _selectedDay ?? _rangeStart ?? DateTime.now(),
          //   menu: _store.menuForDate(_selectedDay ?? _rangeStart ?? DateTime.now()),
          // ),
        ],
      ),
    );
  }

  Future<void> _showDayStatusBottomSheet(DateTime day) async {
    final key = _normalize(day);
    final weekdayStr = _getWeekdayStr(day);
    final dayActive = _routineDays[weekdayStr] ?? true;
    final breakfastActive = _routineMealTimes['Breakfast'] ?? true;
    final lunchActive = _routineMealTimes['Lunch'] ?? true;
    final dinnerActive = _routineMealTimes['Dinner'] ?? true;

    final existingDetails = _mealDetailsByDate[key] ?? {
      'breakfast': _mealStatusByDate[key] ?? (dayActive && breakfastActive),
      'lunch': _mealStatusByDate[key] ?? (dayActive && lunchActive),
      'dinner': _mealStatusByDate[key] ?? (dayActive && dinnerActive),
    };
    
    var localBreakfast = existingDetails['breakfast'] ?? (dayActive && breakfastActive);
    var localLunch = existingDetails['lunch'] ?? (dayActive && lunchActive);
    var localDinner = existingDetails['dinner'] ?? (dayActive && dinnerActive);

    // Fetch rates from menu
    final menu = await _firestore.getMenuFuture(day.weekday);
    final breakfastRate = menu?['breakfast']?['rate'] ?? 75.0;
    final lunchRate = menu?['lunch']?['rate'] ?? 75.0;
    final dinnerRate = menu?['dinner']?['rate'] ?? 75.0;

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meal status for ${day.day}/${day.month}/${day.year}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(localBreakfast ? 'Breakfast ON (BDT $breakfastRate)' : 'Breakfast OFF (BDT $breakfastRate)'),
                    value: localBreakfast,
                    activeThumbColor: AppPallate.primary,
                    onChanged: (value) {
                      setModalState(() {
                        localBreakfast = value;
                      });
                    },
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(localLunch ? 'Lunch ON (BDT $lunchRate)' : 'Lunch OFF (BDT $lunchRate)'),
                    value: localLunch,
                    activeThumbColor: AppPallate.primary,
                    onChanged: (value) {
                      setModalState(() {
                        localLunch = value;
                      });
                    },
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(localDinner ? 'Dinner ON (BDT $dinnerRate)' : 'Dinner OFF (BDT $dinnerRate)'),
                    value: localDinner,
                    activeThumbColor: AppPallate.primary,
                    onChanged: (value) {
                      setModalState(() {
                        localDinner = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final anyMealOn = localBreakfast || localLunch || localDinner;
                        final mealDetails = {
                          'breakfast': localBreakfast,
                          'lunch': localLunch,
                          'dinner': localDinner,
                          'rates': {
                            'breakfast': breakfastRate,
                            'lunch': lunchRate,
                            'dinner': dinnerRate,
                          }
                        };

                        setState(() {
                          _mealStatusByDate[key] = anyMealOn;
                          _mealDetailsByDate[key] = mealDetails;

                        });

                        final navigator = Navigator.of(context);
                        final user = AuthService().currentUser;
                        if (user != null) {
                          await _firestore.addMeal(user.uid, {
                            'date': key.toIso8601String(),
                            'status': anyMealOn,
                            'meals': mealDetails,
                            'timestamp': DateTime.now(),
                          });
                        }

                        navigator.pop();
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showRangeStatusBottomSheet(DateTime start, DateTime end) async {
    var localBreakfast = true;
    var localLunch = true;
    var localDinner = true;
    var isLoading = false;

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Update meals from ${start.day}/${start.month} to ${end.day}/${end.month}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Breakfast'),
                    subtitle: const Text('Apply to all days in range'),
                    value: localBreakfast,
                    activeThumbColor: AppPallate.primary,
                    onChanged: isLoading ? null : (value) {
                      setModalState(() => localBreakfast = value);
                    },
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Lunch'),
                    subtitle: const Text('Apply to all days in range'),
                    value: localLunch,
                    activeThumbColor: AppPallate.primary,
                    onChanged: isLoading ? null : (value) {
                      setModalState(() => localLunch = value);
                    },
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Dinner'),
                    subtitle: const Text('Apply to all days in range'),
                    value: localDinner,
                    activeThumbColor: AppPallate.primary,
                    onChanged: isLoading ? null : (value) {
                      setModalState(() => localDinner = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () async {
                        final anyMealOn = localBreakfast || localLunch || localDinner;
                        
                        setModalState(() => isLoading = true);
                        
                        final navigator = Navigator.of(context);
                        final user = AuthService().currentUser;
                        if (user != null) {
                          var current = start;
                          final futures = <Future>[];
                          while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
                            final key = _normalize(current);
                            final currentDay = current;
                            
                            futures.add(() async {
                              final dayMenu = await _firestore.getMenuFuture(currentDay.weekday);
                              final bRate = dayMenu?['breakfast']?['rate'] ?? 75.0;
                              final lRate = dayMenu?['lunch']?['rate'] ?? 75.0;
                              final dRate = dayMenu?['dinner']?['rate'] ?? 75.0;

                              final details = {
                                'breakfast': localBreakfast,
                                'lunch': localLunch,
                                'dinner': localDinner,
                                'rates': {
                                  'breakfast': bRate,
                                  'lunch': lRate,
                                  'dinner': dRate,
                                }
                              };

                              await _firestore.addMeal(user.uid, {
                                'date': key.toIso8601String(),
                                'status': anyMealOn,
                                'meals': details,
                                'timestamp': DateTime.now(),
                              });
                            }());
                            
                            current = current.add(const Duration(days: 1));
                          }
                          await Future.wait(futures);
                        }
                        navigator.pop();
                      },
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Update Range'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

// class _DateMenuCard extends StatelessWidget {
//   const _DateMenuCard({
//     required this.date,
//     required this.menu,
//   });

//   final DateTime date;
//   final DayMenu menu;

//   @override
//   Widget build(BuildContext context) {
//     return CustomCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Menu for ${date.day}/${date.month}/${date.year}',
//             style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
//           ),
//           const SizedBox(height: 8),
//           ...menu.asList().map(
//             (meal) => ListTile(
//               contentPadding: EdgeInsets.zero,
//               leading: CircleAvatar(
//                 backgroundColor: const Color(0xFFE5EFE5),
//                 child: Text(meal.title.characters.first),
//               ),
//               title: Text(meal.title),
//               subtitle: Text(
//                 meal.items.join(' • '),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               trailing: const Icon(Icons.open_in_new_rounded),
//               onTap: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (_) => MenuDetailPage(meal: meal, date: date),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
