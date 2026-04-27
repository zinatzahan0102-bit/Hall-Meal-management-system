import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal_management/core/data/firestore_service.dart';
import 'package:meal_management/core/widgets/custom_button.dart';
import 'package:meal_management/core/widgets/input_field.dart';
import 'package:meal_management/features/auth/data/auth_service.dart';

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({super.key});

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _complaintType = 'Food Quality';
  bool _isSubmitting = false;
  XFile? _selectedImage;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _submitComplaint() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      final user = AuthService().currentUser;
      if (user != null) {
        String? imageUrl;
        if (_selectedImage != null) {
          imageUrl = await FirestoreService().uploadImage(_selectedImage!);
        }

        await FirestoreService().addComplaint(user.uid, {
          'complaintType': _complaintType,
          'description': _descriptionController.text.trim(),
          'hasImage': imageUrl != null,
          'imageUrl': imageUrl,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Complaint submitted successfully')),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Box'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _complaintType,
              decoration: const InputDecoration(hintText: 'Complaint Type'),
              items: const [
                DropdownMenuItem(value: 'Food Quality', child: Text('Food Quality')),
                DropdownMenuItem(value: 'Service', child: Text('Service')),
                DropdownMenuItem(value: 'Suggestion', child: Text('Suggestion')),
                DropdownMenuItem(value: 'Others', child: Text('Others')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _complaintType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 14),
            InputField(
              hint: 'Describe your issue...',
              controller: _descriptionController,
              maxLines: 6,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image_outlined),
              label: Text(_selectedImage != null ? 'Photo selected' : 'Upload photo (optional)'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                foregroundColor: _selectedImage != null ? Colors.green : null,
              ),
            ),
            const SizedBox(height: 18),
            CustomButton(
              label: _isSubmitting ? 'Submitting...' : 'Submit Complaint',
              onPressed: _isSubmitting ? null : () => _submitComplaint(),
            ),
          ],
        ),
      ),
    );
  }
}
