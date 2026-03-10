import 'package:flutter/material.dart';
import 'package:meal_management/core/data/app_store.dart';
import 'package:meal_management/core/theme/app_palette.dart';
import 'package:meal_management/core/widgets/custom_card.dart';
import 'package:meal_management/features/menu/presentation/pages/menu_detail_page.dart';
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
  bool _todayMealOn = true;
  bool _tomorrowMealOn = false;
  final Map<DateTime, bool> _mealStatusByDate = {};
  final AppStore _store = AppStore.instance;

  @override
  void initState() {
    super.initState();
    _mealStatusByDate[_normalize(DateTime.now())] = true;
    _mealStatusByDate[_normalize(DateTime.now().add(const Duration(days: 1)))] =
        false;
  }

  DateTime _normalize(DateTime day) => DateTime(day.year, day.month, day.day);

  bool? _statusForDay(DateTime day) => _mealStatusByDate[_normalize(day)];

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
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Toggle',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 14),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Today'),
                  value: _todayMealOn,
                  activeThumbColor: AppPallate.primary,
                  onChanged: (value) {
                    setState(() {
                      _todayMealOn = value;
                      _mealStatusByDate[_normalize(DateTime.now())] = value;
                    });
                  },
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tomorrow'),
                  value: _tomorrowMealOn,
                  activeThumbColor: AppPallate.primary,
                  onChanged: (value) {
                    setState(() {
                      _tomorrowMealOn = value;
                      _mealStatusByDate[
                          _normalize(DateTime.now().add(const Duration(days: 1)))] = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Date Range Selector',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () async {
                        final now = DateTime.now();
                        final range = await showDateRangePicker(
                          context: context,
                          firstDate: now.subtract(const Duration(days: 365)),
                          lastDate: now.add(const Duration(days: 365)),
                          initialDateRange: _selectedRange,
                        );
                        if (range != null) {
                          setState(() {
                            _selectedRange = range;
                            _rangeStart = range.start;
                            _rangeEnd = range.end;
                            _focusedDay = range.start;
                            _selectedDay = null;
                          });
                        }
                      },
                      child: const Text('Select'),
                    ),
                  ],
                ),
                Text(
                  _selectedRange == null
                      ? 'No range selected'
                      : 'From ${_selectedRange!.start.day}/${_selectedRange!.start.month} to ${_selectedRange!.end.day}/${_selectedRange!.end.month}',
                  style: const TextStyle(color: AppPallate.textSecondary),
                ),
              ],
            ),
          ),
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
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _rangeStart = null;
                      _rangeEnd = null;
                      _rangeSelectionMode = RangeSelectionMode.toggledOn;
                    });
                    _showDayStatusBottomSheet(selectedDay);
                  },
                  onRangeSelected: (start, end, focusedDay) {
                    setState(() {
                      _selectedDay = null;
                      _focusedDay = focusedDay;
                      _rangeStart = start;
                      _rangeEnd = end;
                      _rangeSelectionMode = RangeSelectionMode.toggledOn;
                    });
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
          _DateMenuCard(
            date: _selectedDay ?? _rangeStart ?? DateTime.now(),
            menu: _store.menuForDate(_selectedDay ?? _rangeStart ?? DateTime.now()),
          ),
        ],
      ),
    );
  }

  Future<void> _showDayStatusBottomSheet(DateTime day) async {
    final key = _normalize(day);
    var localStatus = _mealStatusByDate[key] ?? true;

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
                    title: Text(localStatus ? 'Meal ON' : 'Meal OFF'),
                    value: localStatus,
                    activeThumbColor: AppPallate.primary,
                    onChanged: (value) {
                      setModalState(() {
                        localStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _mealStatusByDate[key] = localStatus;
                          if (isSameDay(key, DateTime.now())) {
                            _todayMealOn = localStatus;
                          }
                          if (isSameDay(
                              key, DateTime.now().add(const Duration(days: 1)))) {
                            _tomorrowMealOn = localStatus;
                          }
                        });
                        Navigator.pop(context);
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

class _DateMenuCard extends StatelessWidget {
  const _DateMenuCard({
    required this.date,
    required this.menu,
  });

  final DateTime date;
  final DayMenu menu;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Menu for ${date.day}/${date.month}/${date.year}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...menu.asList().map(
            (meal) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFE5EFE5),
                child: Text(meal.title.characters.first),
              ),
              title: Text(meal.title),
              subtitle: Text(
                meal.items.join(' • '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.open_in_new_rounded),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MenuDetailPage(meal: meal, date: date),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
