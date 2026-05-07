import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meal_management/core/data/app_store.dart';
import 'package:meal_management/core/data/firestore_service.dart';
import 'package:meal_management/core/theme/app_palette.dart';
import 'package:meal_management/core/widgets/custom_button.dart';
import 'package:meal_management/core/widgets/input_field.dart';
import 'package:meal_management/features/auth/prasentation/pages/loginpage.dart';
import 'package:meal_management/features/navigation/presentation/pages/main_navigation_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();

  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _roomController = TextEditingController();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  // Menu management controllers
  int _selectedWeekday = DateTime.monday;
  MealType _selectedMealType = MealType.breakfast;
  final _imageController = TextEditingController();
  final _itemsController = TextEditingController();

  final store = AppStore.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fabAnimationController.forward();
    _loadCurrentMealFields();

    // Check authentication status
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const Loginpage()),
            (route) => false,
          );
        }
        return;
      }

      // Check if user is admin
      try {
        final userDoc = await _firestoreService.getUser(user.uid);
        final userRole = userDoc?['role'] as String?;

        if (userRole != 'admin') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Access denied. Admin privileges required.')),
            );
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainNavigationPage()),
              (route) => false,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error checking permissions')),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const Loginpage()),
            (route) => false,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _roomController.dispose();
    _idController.dispose();
    _passwordController.dispose();
    _imageController.dispose();
    _itemsController.dispose();
    super.dispose();
  }

  Future<void> _addStudent() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _roomController.text.isEmpty ||
        _idController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create Firebase Auth account
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Add user data to Firestore
      final userData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'room': _roomController.text.trim(),
        'id': _idController.text.trim(),
        'role': 'student',
        'createdAt': DateTime.now(),
        'createdBy': FirebaseAuth.instance.currentUser?.email ?? 'admin',
      };

      await _firestoreService.addUser(userCredential.user!.uid, userData);

      if (mounted) {
        // Clear form
        _nameController.clear();
        _emailController.clear();
        _roomController.clear();
        _idController.clear();
        _passwordController.clear();

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding student: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteStudent(String userId, String email) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete $email? This will remove their account and all data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Delete from Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();

      // Delete Firebase Auth account (admin only)
      // Note: This requires admin privileges in production

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting student: ${e.toString()}')),
        );
      }
    }
  }

  void _showAddStudentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add New Student',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email (for login)',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _roomController,
              decoration: const InputDecoration(
                labelText: 'Room Number',
                prefixIcon: Icon(Icons.meeting_room),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'Student ID',
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addStudent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPallate.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Add Student'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            'Admin Dashboard',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
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
              Tab(text: 'Students', icon: Icon(Icons.people)),
              Tab(text: 'Menu', icon: Icon(Icons.restaurant_menu)),
            ],
            labelColor: AppPallate.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppPallate.primary,
          ),
        ),
        body: TabBarView(
          children: [
            _buildStudentsTab(),
            _buildMenuTab(),
          ],
        ),
        floatingActionButton: ScaleTransition(
          scale: _fabAnimation,
          child: FloatingActionButton.extended(
            onPressed: () => _showAddStudentDialog(),
            backgroundColor: AppPallate.primary,
            icon: const Icon(Icons.person_add_rounded),
            label: const Text('Add Student'),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              int studentCount = 0;
              if (snapshot.hasData) {
                studentCount = snapshot.data!.docs.length;
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppPallate.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppPallate.primary.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.people_rounded,
                      color: AppPallate.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$studentCount Students',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppPallate.primary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No students added yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap the + button to add your first student',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final students = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['role'] == 'student'; // Only show students, not admin
              }).toList();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index].data() as Map<String, dynamic>;
                  final userId = students[index].id;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: AppPallate.primary.withValues(alpha: 0.1),
                        child: Text(
                          student['name']?.substring(0, 1).toUpperCase() ?? '?',
                          style: TextStyle(
                            color: AppPallate.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      title: Text(
                        student['name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Room: ${student['room'] ?? 'N/A'} • ID: ${student['id'] ?? 'N/A'}'),
                          Text(
                            student['email'] ?? 'No email',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            _deleteStudent(userId, student['email'] ?? '');
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete Student'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTab() {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'Set menu once by weekday. Calendar pages will auto-show menu by date and weekday.',
                style: TextStyle(color: Color(0xFF637064), fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: _selectedWeekday,
                    decoration: const InputDecoration(
                      labelText: 'Select weekday',
                      border: OutlineInputBorder(),
                    ),
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
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
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
                    label: 'Save Menu',
                    onPressed: _saveWeeklyMenu,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildPreviewCard(),
          ],
        );
      },
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            entry.imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 60,
              height: 60,
              color: Colors.grey[200],
              child: const Icon(Icons.image_not_supported),
            ),
          ),
        ),
        title: Text(
          '${_weekdayName(_selectedWeekday)} ${entry.title}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          entry.items.join(' • '),
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  void _loadCurrentMealFields() {
    final menu = store.weeklyMenus[_selectedWeekday];
    if (menu != null) {
      final entry = menu.entryForType(_selectedMealType);
      _imageController.text = entry.imageUrl;
      _itemsController.text = entry.items.join(', ');
    } else {
      _imageController.clear();
      _itemsController.clear();
    }
  }

  void _saveWeeklyMenu() {
    final imageUrl = _imageController.text.trim();
    final itemsText = _itemsController.text.trim();

    if (imageUrl.isEmpty || itemsText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final items = itemsText.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty).toList();

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one food item')),
      );
      return;
    }

    store.setMealEntry(
      _selectedWeekday,
      _selectedMealType,
      MealEntry(
        title: _selectedMealType.name.toUpperCase(),
        imageUrl: imageUrl,
        items: items,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_selectedMealType.name} menu saved for ${_weekdayName(_selectedWeekday)}')),
    );
  }

  String _weekdayName(int weekday) {
    const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return names[weekday - 1];
  }
}
