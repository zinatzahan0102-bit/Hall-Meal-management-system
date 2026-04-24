import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal_management/core/data/default_menu.dart';
import 'package:meal_management/core/data/firestore_service.dart';
import 'package:meal_management/core/theme/app_palette.dart';
import 'package:meal_management/core/widgets/custom_button.dart';
import 'package:meal_management/features/chat/presentation/pages/chat_page.dart';
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
  final _menuRateController = TextEditingController();
  final _mealRateController = TextEditingController();
  final _monthlyLimitController = TextEditingController();
  
  // Cutoff controllers
  final _breakfastCutoffController = TextEditingController();
  final _lunchCutoffController = TextEditingController();
  final _dinnerCutoffController = TextEditingController();

  String _currentImageUrl = '';
  List<String> _currentItems = [];
  bool _isLoading = false;
  int _feedbackType = 0; // 0: Complaints, 1: Reviews

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
      length: 5,
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
            isScrollable: true,
            tabs: [
              Tab(text: 'Students', icon: Icon(Icons.people)),
              Tab(text: 'Menu', icon: Icon(Icons.restaurant_menu)),
              Tab(text: 'Chat', icon: Icon(Icons.chat)),
              Tab(text: 'Feedback', icon: Icon(Icons.feedback)),
              Tab(text: 'Settings', icon: Icon(Icons.settings)),
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
            _buildChatTab(),
            _buildFeedbackTab(),
            _buildSettingsTab(),
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
                studentCount = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['role'] != 'admin';
                }).length;
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
                      onTap: () {
                        _showStudentActivity(userId, student['name'] ?? 'Unknown');
                      },
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
                    suffixIcon: _isUploading
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.upload_file_rounded),
                            onPressed: _pickAndUploadImage,
                          ),
                  ),
                  const SizedBox(height: 12),
                  InputField(
                    hint: 'Food items, separated by comma',
                    controller: _itemsController,
                    maxLines: 3,
                    prefixIcon: Icons.list_alt_rounded,
                  ),
                  const SizedBox(height: 12),
                  InputField(
                    hint: 'Meal Rate (BDT)',
                    controller: _menuRateController,
                    prefixIcon: Icons.money_rounded,
                    keyboardType: TextInputType.number,
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
  }

  Widget _buildPreviewCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: _currentImageUrl.isNotEmpty
                ? Image.network(
                    _currentImageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 150,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_selectedMealType.name.toUpperCase()} PREVIEW',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentItems.isNotEmpty ? _currentItems.join(', ') : 'No items',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _isUploading = true;
      });
      
      final url = await _firestoreService.uploadImage(image);
      
      setState(() {
        _isUploading = false;
      });
      
      if (url != null) {
        setState(() {
          _imageController.text = url;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image uploaded successfully!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image.')),
          );
        }
      }
    }
  }

  Future<void> _loadCurrentMealFields() async {
    final data = await _firestoreService.getMenuFuture(_selectedWeekday);
    if (data != null) {
      final mealKey = _selectedMealType.name;
      final mealData = data[mealKey] as Map<String, dynamic>?;
      if (mealData != null) {
        setState(() {
          _imageController.text = mealData['imageUrl'] ?? '';
          _itemsController.text = (mealData['items'] as List<dynamic>?)?.join(', ') ?? '';
          _menuRateController.text = mealData['rate']?.toString() ?? '';
          _currentImageUrl = _imageController.text;
          _currentItems = _itemsController.text.split(',').map((e) => e.trim()).toList();
        });
        return;
      }
    }

    final defaultMenu = defaultWeeklyMenu[_selectedWeekday] ?? defaultWeeklyMenu[1]!;
    final mealKey = _selectedMealType.name;
    final defaultMeal = defaultMenu[mealKey] as Map<String, dynamic>?;

    setState(() {
      if (defaultMeal != null) {
        _imageController.text = defaultMeal['imageUrl'] ?? '';
        _itemsController.text = (defaultMeal['items'] as List<dynamic>?)?.join(', ') ?? '';
      } else {
        _imageController.clear();
        _itemsController.clear();
      }
      _currentImageUrl = _imageController.text;
      _currentItems = _itemsController.text.split(',').map((e) => e.trim()).toList();
    });
  }

  Future<void> _saveWeeklyMenu() async {
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

    final rate = double.tryParse(_menuRateController.text) ?? 0.0;
    final mealKey = _selectedMealType.name;
    final menuData = {
      mealKey: {
        'imageUrl': imageUrl,
        'items': items,
        'rate': rate,
      }
    };

    try {
      await _firestoreService.updateMenu(_selectedWeekday, menuData);

      setState(() {
        _currentImageUrl = imageUrl;
        _currentItems = items;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_selectedMealType.name} menu saved for ${_weekdayName(_selectedWeekday)}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving menu: ${e.toString()}')),
        );
      }
    }
  }

  String _weekdayName(int weekday) {
    const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return names[weekday - 1];
  }

  Widget _buildSettingsTab() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _firestoreService.getMealSettingsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final data = snapshot.data ?? {
          'mealRate': 75.0, 
          'monthlyLimit': 1150.0,
          'breakfastCutoff': 22, // 10 PM previous day
          'lunchCutoff': 9, // 9 AM same day
          'dinnerCutoff': 15, // 3 PM same day
        };
        
        if (_mealRateController.text.isEmpty) {
          _mealRateController.text = data['mealRate'].toString();
        }
        if (_monthlyLimitController.text.isEmpty) {
          _monthlyLimitController.text = data['monthlyLimit'].toString();
        }
        if (_breakfastCutoffController.text.isEmpty) {
          _breakfastCutoffController.text = data['breakfastCutoff']?.toString() ?? '22';
        }
        if (_lunchCutoffController.text.isEmpty) {
          _lunchCutoffController.text = data['lunchCutoff']?.toString() ?? '9';
        }
        if (_dinnerCutoffController.text.isEmpty) {
          _dinnerCutoffController.text = data['dinnerCutoff']?.toString() ?? '15';
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSettingsCard(
              title: 'Meal Settings',
              children: [
                InputField(
                  hint: 'Meal Rate (BDT)',
                  controller: _mealRateController,
                  prefixIcon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                InputField(
                  hint: 'Monthly Minimum Deposit (BDT)',
                  controller: _monthlyLimitController,
                  prefixIcon: Icons.account_balance_wallet_rounded,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingsCard(
              title: 'Cut-off Times (24h format)',
              children: [
                InputField(
                  hint: 'Breakfast Cut-off (Previous Day Hour)',
                  controller: _breakfastCutoffController,
                  prefixIcon: Icons.breakfast_dining_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                InputField(
                  hint: 'Lunch Cut-off (Same Day Hour)',
                  controller: _lunchCutoffController,
                  prefixIcon: Icons.lunch_dining_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                InputField(
                  hint: 'Dinner Cut-off (Same Day Hour)',
                  controller: _dinnerCutoffController,
                  prefixIcon: Icons.dinner_dining_rounded,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Save All Settings',
              onPressed: _saveMealSettings,
            ),
            const SizedBox(height: 24),
            _buildSettingsCard(
              title: 'Danger Zone',
              children: [
                const Text(
                  'Resetting all meals will turn off all meals for all students for the upcoming month. This action cannot be undone.',
                  style: TextStyle(color: AppPallate.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Placeholder for reset functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Not implemented yet.')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppPallate.danger),
                  child: const Text('Reset All Students Meals'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPallate.surface,
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
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Future<void> _saveMealSettings() async {
    final mealRate = double.tryParse(_mealRateController.text) ?? 75.0;
    final monthlyLimit = double.tryParse(_monthlyLimitController.text) ?? 1150.0;
    final breakfastCutoff = int.tryParse(_breakfastCutoffController.text) ?? 22;
    final lunchCutoff = int.tryParse(_lunchCutoffController.text) ?? 9;
    final dinnerCutoff = int.tryParse(_dinnerCutoffController.text) ?? 15;
    
    await _firestoreService.updateMealSettings({
      'mealRate': mealRate,
      'monthlyLimit': monthlyLimit,
      'breakfastCutoff': breakfastCutoff,
      'lunchCutoff': lunchCutoff,
      'dinnerCutoff': dinnerCutoff,
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully!')),
      );
    }
  }

  Widget _buildChatTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('chats').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No active chats.',
              style: TextStyle(color: AppPallate.textSecondary),
            ),
          );
        }

        final chatRooms = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: chatRooms.length,
          itemBuilder: (context, index) {
            final chatRoom = chatRooms[index];
            final studentId = chatRoom.id;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(studentId).get(),
              builder: (context, userSnapshot) {
                final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                final name = userData?['name'] ?? 'Loading...';
                final email = userData?['email'] ?? '';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppPallate.primary.withValues(alpha: 0.1),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'S',
                      style: const TextStyle(color: AppPallate.primary),
                    ),
                  ),
                  title: Text(name),
                  subtitle: Text(email),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            chatRoomId: studentId,
                            chatRoomName: name,
                            currentUserId: user.uid,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFeedbackTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _feedbackType = 0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _feedbackType == 0 ? AppPallate.primary : Colors.white,
                    foregroundColor: _feedbackType == 0 ? Colors.white : AppPallate.textPrimary,
                  ),
                  child: const Text('Complaints'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _feedbackType = 1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _feedbackType == 1 ? AppPallate.primary : Colors.white,
                    foregroundColor: _feedbackType == 1 ? Colors.white : AppPallate.textPrimary,
                  ),
                  child: const Text('Reviews'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _feedbackType == 0 ? _buildComplaintsList() : _buildReviewsList(),
        ),
      ],
    );
  }

  Widget _buildComplaintsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('complaints').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No complaints received yet.',
              style: TextStyle(color: AppPallate.textSecondary),
            ),
          );
        }

        final complaints = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: complaints.length,
          itemBuilder: (context, index) {
            final complaint = complaints[index].data() as Map<String, dynamic>;
            final title = complaint['complaintType'] ?? 'No Title';
            final description = complaint['description'] ?? 'No Description';
            final status = complaint['status'] ?? 'Pending';
            final studentId = complaint['userId'] ?? '';
            final timestamp = complaint['timestamp'] as Timestamp?;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(studentId).get(),
              builder: (context, userSnapshot) {
                final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                final name = userData?['name'] ?? 'Unknown Student';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        _buildStatusChip(status),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(description),
                        if (complaint['imageUrl'] != null) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              complaint['imageUrl'],
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 14, color: AppPallate.textSecondary),
                            const SizedBox(width: 4),
                            Text(name, style: const TextStyle(color: AppPallate.textSecondary, fontSize: 12)),
                            const Spacer(),
                            if (timestamp != null)
                              Text(
                                _formatDate(timestamp.toDate()),
                                style: const TextStyle(color: AppPallate.textSecondary, fontSize: 12),
                              ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      _showComplaintDetails(complaints[index].id, complaint, name);
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildReviewsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collectionGroup('reviews').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No reviews received yet.',
              style: TextStyle(color: AppPallate.textSecondary),
            ),
          );
        }

        final reviews = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index].data() as Map<String, dynamic>;
            final rating = review['rating'] ?? 0;
            final comment = review['comment'] ?? 'No Comment';
            final timestamp = review['timestamp'] as Timestamp?;
            
            final pathSegments = reviews[index].reference.path.split('/');
            final studentId = pathSegments[1];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(studentId).get(),
              builder: (context, userSnapshot) {
                final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                final name = userData?['name'] ?? 'Unknown Student';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Row(
                      children: [
                        Text(
                          'Rating: $rating / 5',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppPallate.warning),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(comment),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 14, color: AppPallate.textSecondary),
                            const SizedBox(width: 4),
                            Text(name, style: const TextStyle(color: AppPallate.textSecondary, fontSize: 12)),
                            const Spacer(),
                            if (timestamp != null)
                              Text(
                                _formatDate(timestamp.toDate()),
                                style: const TextStyle(color: AppPallate.textSecondary, fontSize: 12),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = Colors.grey;
    if (status == 'Pending') color = AppPallate.warning;
    if (status == 'Resolved') color = AppPallate.success;
    if (status == 'Rejected') color = AppPallate.danger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showComplaintDetails(String id, Map<String, dynamic> complaint, String studentName) {
    final replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(complaint['complaintType'] ?? 'Feedback Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('From: $studentName'),
                const SizedBox(height: 8),
                Text('Status: ${complaint['status'] ?? 'Pending'}'),
                const SizedBox(height: 16),
                const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(complaint['description'] ?? 'No description'),
                if (complaint['imageUrl'] != null) ...[
                  const SizedBox(height: 16),
                  Image.network(complaint['imageUrl']),
                ],
                const SizedBox(height: 16),
                const Text('Admin Reply:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                if (complaint['reply'] != null)
                  Text(complaint['reply'], style: const TextStyle(color: AppPallate.primary))
                else
                  TextField(
                    controller: replyController,
                    decoration: const InputDecoration(hintText: 'Type your reply here...'),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            if (complaint['reply'] == null)
              ElevatedButton(
                onPressed: () async {
                  if (replyController.text.trim().isNotEmpty) {
                    await FirebaseFirestore.instance
                        .collection('complaints')
                        .doc(id)
                        .update({'reply': replyController.text.trim()});
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text('Send Reply'),
              ),
            if (complaint['status'] != 'Resolved')
              ElevatedButton(
                onPressed: () async {
                  await _firestoreService.updateComplaintStatus(id, 'Resolved');
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppPallate.success),
                child: const Text('Mark as Resolved'),
              ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showStudentActivity(String userId, String studentName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$studentName\'s Activity'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                StreamBuilder<Map<String, dynamic>>(
                  stream: _firestoreService.getMealStatsStream(userId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    final stats = snapshot.data!;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Meals', stats['totalMeals'].toString()),
                        _buildStatItem('Bill', 'BDT ${stats['totalBill']}'),
                      ],
                    );
                  },
                ),
                const Divider(),
                const Text('Recent Meals', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection('meals')
                        .orderBy('date', descending: true)
                        .limit(20)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No meal activity.'));
                      }
                      final meals = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: meals.length,
                        itemBuilder: (context, index) {
                          final mealDoc = meals[index].data() as Map<String, dynamic>;
                          final date = mealDoc['date'] ?? '';
                          final mealsMap = mealDoc['meals'] as Map<String, dynamic>?;
                          
                          bool b = mealsMap?['breakfast'] == true;
                          bool l = mealsMap?['lunch'] == true;
                          bool d = mealsMap?['dinner'] == true;

                          return ListTile(
                            title: Text(date),
                            subtitle: Text('B: ${b?'ON':'OFF'} | L: ${l?'ON':'OFF'} | D: ${d?'ON':'OFF'}'),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppPallate.primary)),
        Text(label, style: const TextStyle(color: AppPallate.textSecondary)),
      ],
    );
  }
}
