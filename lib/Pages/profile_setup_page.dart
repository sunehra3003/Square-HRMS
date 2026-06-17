import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:new_app/Pages/main_page.dart';

const kNavy = Color(0xFF1B2E5E);

final supabase = Supabase.instance.client;

class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _departmentController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  File? _imageFile;

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  // ── Pick Image ───────────────────────────────────
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 400,
    );
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  // ── Upload Image to Supabase Storage ─────────────
  Future<String?> _uploadImage(String userId) async {
    if (_imageFile == null) return null;

    final bytes = await _imageFile!.readAsBytes();
    final filePath = 'images/$userId.png';

    await supabase.storage
        .from('employees')
        .uploadBinary(
          filePath,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    return supabase.storage.from('employees').getPublicUrl(filePath);
  }

  // ── Save Profile ─────────────────────────────────
  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty ||
        _roleController.text.trim().isEmpty ||
        _departmentController.text.trim().isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = supabase.auth.currentUser!.id;

      // ✅ Upload image first
      final imageUrl = await _uploadImage(userId);

      // ✅ Insert into all 3 tables in parallel
      await Future.wait([
        supabase.from('employees').insert({
          'user_id': userId,
          'name': _nameController.text.trim(),
          'role': _roleController.text.trim(),
          'department': _departmentController.text.trim(),
          'status': 'Active',
          'image': imageUrl ?? '',
        }),
        supabase.from('attendance_summary').insert({
          'user_id': userId,

          'present_days': 0,
          'total_days': 0,

          'late_count': 0,
        }),
        supabase.from('leave_stats').insert({
          'user_id': userId,
          'leave_balance': 20,
          'pending_approval': 0,
          'casual_used': 0,
          'casual_total': 10,
          'sick_used': 0,
          'sick_total': 14,
        }),
      ]);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  // ══════════════════════════════════════════════════
  // BUILD METHODS
  // ══════════════════════════════════════════════════

  // ── Header ───────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: kNavy.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline, color: kNavy),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Setup Profile',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kNavy,
                  ),
                ),
                Text(
                  'Tell us about yourself',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }

  // ── Step Indicator ───────────────────────────────
  Widget _buildStepIndicator() {
    return Row(
      children: [
        _stepDot(1, true, 'Account'),
        _stepLine(true),
        _stepDot(2, true, 'Verify'),
        _stepLine(true),
        _stepDot(3, true, 'Profile'),
      ],
    );
  }

  Widget _stepDot(int number, bool active, String label) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: active ? kNavy : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: active ? kNavy : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _stepLine(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: active ? kNavy : Colors.grey.shade300,
      ),
    );
  }

  // ── Image Picker ─────────────────────────────────
  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile Photo',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                // ── Preview circle ──────────────────
                CircleAvatar(
                  radius: 24,
                  backgroundColor: kNavy.withOpacity(0.1),
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!) as ImageProvider
                      : null,
                  child: _imageFile == null
                      ? const Icon(Icons.person_outline, color: kNavy, size: 24)
                      : null,
                ),
                const SizedBox(width: 14),

                // ── Text ────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _imageFile == null
                            ? 'Upload profile photo'
                            : 'Photo selected ✅',
                        style: TextStyle(
                          fontSize: 14,
                          color: _imageFile == null
                              ? Colors.grey
                              : Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'JPG or PNG, max 5MB',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),

                // ── Icon ────────────────────────────
                Icon(
                  _imageFile == null
                      ? Icons.upload_outlined
                      : Icons.check_circle_outline,
                  color: _imageFile == null ? Colors.grey : Colors.green,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Text Field ───────────────────────────────────
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: kNavy),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kNavy, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Error Message ────────────────────────────────
  Widget _buildErrorMessage() {
    if (_error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Submit Button ────────────────────────────────
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _saveProfile,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        backgroundColor: kNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: _isLoading
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Setting up...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Get Started',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
    );
  }

  // ── Main Build ───────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ── Header ─────────────────────────
              _buildHeader(),
              const SizedBox(height: 16),

              // ── Step Indicator ─────────────────
              _buildStepIndicator(),
              const SizedBox(height: 28),

              // ── Image Picker ───────────────────
              _buildImagePicker(),

              // ── Fields ─────────────────────────
              _buildField(
                label: 'Full Name',
                controller: _nameController,
                hint: 'e.g. Tanaka Hiroshi',
                icon: Icons.person_outline,
              ),
              _buildField(
                label: 'Job Role',
                controller: _roleController,
                hint: 'e.g. Flutter Developer',
                icon: Icons.work_outline,
              ),
              _buildField(
                label: 'Department',
                controller: _departmentController,
                hint: 'e.g. Engineering',
                icon: Icons.business_outlined,
              ),

              // ── Error ──────────────────────────
              _buildErrorMessage(),

              // ── Submit ─────────────────────────
              _buildSubmitButton(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
