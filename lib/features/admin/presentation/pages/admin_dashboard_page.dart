import 'package:flutter/material.dart';
import 'package:meal_management/core/data/app_store.dart';
import 'package:meal_management/core/widgets/custom_button.dart';
import 'package:meal_management/core/widgets/input_field.dart';
import 'package:meal_management/features/auth/prasentation/pages/loginpage.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _userNameController = TextEditingController();
  final _userEmailController = TextEditingController();
  final _userRoomController = TextEditingController();
  final _userIdController = TextEditingController();

  int _selectedWeekday = DateTime.monday;
  MealType _selectedMealType = MealType.breakfast;
  final _imageController = TextEditingController();
  final _itemsController = TextEditingController();

  final store = AppStore.instance;

  @override
  void initState() {
    super.initState();
    _loadCurrentMealFields();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _userEmailController.dispose();
    _userRoomController.dispose();
    _userIdController.dispose();
    _imageController.dispose();
    _itemsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Admin Control Center'),
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const Loginpage()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout_rounded),
                ),
              ],
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Users'),
                  Tab(text: 'Weekly Menu'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildUsersTab(),
                _buildWeeklyMenuTab(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsersTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Total registered users: ${store.users.length}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 12),
        ...store.users.map(
          (user) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${user.room} • ${user.id}\n${user.email}'),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () {
                  _userNameController.text = user.name;
                  _userEmailController.text = user.email;
                  _userRoomController.text = user.room;
                  _userIdController.text = user.id;
                  _showUserEditor();
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        CustomButton(
          label: 'Add new user',
          icon: Icons.person_add_alt_1_rounded,
          onPressed: () {
            _userNameController.clear();
            _userEmailController.clear();
            _userRoomController.clear();
            _userIdController.clear();
            _showUserEditor();
          },
        ),
      ],
    );
  }

  Widget _buildWeeklyMenuTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'Set menu once by weekday. Calendar pages will auto-show menu by date and weekday.',
            style: TextStyle(color: Color(0xFF637064), fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          initialValue: _selectedWeekday,
          decoration: const InputDecoration(hintText: 'Select weekday'),
          items: List.generate(7, (index) {
            final weekday = index + 1;
            return DropdownMenuItem(value: weekday, child: Text(_weekdayName(weekday)));
          }),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedWeekday = value;
              });
              _loadCurrentMealFields();
            }
          },
        ),
        const SizedBox(height: 12),
        SegmentedButton<MealType>(
          segments: const [
            ButtonSegment(value: MealType.breakfast, label: Text('Breakfast')),
            ButtonSegment(value: MealType.lunch, label: Text('Lunch')),
            ButtonSegment(value: MealType.dinner, label: Text('Dinner')),
          ],
          selected: {_selectedMealType},
          onSelectionChanged: (selection) {
            setState(() {
              _selectedMealType = selection.first;
            });
            _loadCurrentMealFields();
          },
        ),
        const SizedBox(height: 12),
        InputField(
          hint: 'Food image URL',
          controller: _imageController,
          prefixIcon: Icons.image_rounded,
        ),
        const SizedBox(height: 12),
        InputField(
          hint: 'Food items, separated by comma',
          controller: _itemsController,
          maxLines: 3,
          prefixIcon: Icons.list_alt_rounded,
        ),
        const SizedBox(height: 16),
        CustomButton(
          label: 'Save weekly menu',
          onPressed: _saveWeeklyMenu,
        ),
        const SizedBox(height: 14),
        _buildPreviewCard(),
      ],
    );
  }

  Widget _buildPreviewCard() {
    final menu = store.weeklyMenus[_selectedWeekday];
    if (menu == null) {
      return const SizedBox.shrink();
    }

    final entry = menu.entryForType(_selectedMealType);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            entry.imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text('${_weekdayName(_selectedWeekday)} ${entry.title}'),
        subtitle: Text(entry.items.join(' • ')),
      ),
    );
  }

  void _saveWeeklyMenu() {
    final image = _imageController.text.trim();
    final itemsRaw = _itemsController.text.trim();

    if (image.isEmpty || itemsRaw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image URL and items are required.')),
      );
      return;
    }

    final items = itemsRaw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    store.updateDayMeal(
      weekday: _selectedWeekday,
      mealType: _selectedMealType,
      entry: MealEntry(
        title: _mealTypeLabel(_selectedMealType),
        imageUrl: image,
        items: items,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_weekdayName(_selectedWeekday)} menu updated.')),
    );
  }

  void _loadCurrentMealFields() {
    final dayMenu = store.weeklyMenus[_selectedWeekday];
    if (dayMenu == null) {
      return;
    }

    final entry = dayMenu.entryForType(_selectedMealType);
    _imageController.text = entry.imageUrl;
    _itemsController.text = entry.items.join(', ');
  }

  void _showUserEditor() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            18 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InputField(
                hint: 'Name',
                controller: _userNameController,
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 10),
              InputField(
                hint: 'Email',
                controller: _userEmailController,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 10),
              InputField(
                hint: 'Room',
                controller: _userRoomController,
                prefixIcon: Icons.meeting_room_outlined,
              ),
              const SizedBox(height: 10),
              InputField(
                hint: 'ID',
                controller: _userIdController,
                prefixIcon: Icons.badge_outlined,
              ),
              const SizedBox(height: 12),
              CustomButton(
                label: 'Save user',
                onPressed: () {
                  if (_userNameController.text.trim().isEmpty ||
                      _userIdController.text.trim().isEmpty) {
                    return;
                  }
                  store.upsertUser(
                    AppUser(
                      name: _userNameController.text.trim(),
                      email: _userEmailController.text.trim(),
                      room: _userRoomController.text.trim(),
                      id: _userIdController.text.trim(),
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _weekdayName(int weekday) {
    const names = {
      DateTime.monday: 'Monday',
      DateTime.tuesday: 'Tuesday',
      DateTime.wednesday: 'Wednesday',
      DateTime.thursday: 'Thursday',
      DateTime.friday: 'Friday',
      DateTime.saturday: 'Saturday',
      DateTime.sunday: 'Sunday',
    };
    return names[weekday] ?? 'Monday';
  }

  String _mealTypeLabel(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
    }
  }
}
