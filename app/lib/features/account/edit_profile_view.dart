import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../auth/providers/auth_provider.dart';

class EditProfileView extends ConsumerStatefulWidget {
  const EditProfileView({super.key});

  @override
  ConsumerState<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  
  bool _isPasswordSectionVisible = false;
  String? _selectedAvatarBase64;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize with current user's data
    final user = ref.read(authProvider).user;
    if (user != null) {
      _nameController.text = user.name;
      _selectedAvatarBase64 = user.avatarUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        // Prefix with data URI scheme so it can be directly used in Image.memory or Network
        setState(() {
          _selectedAvatarBase64 = 'data:image/jpeg;base64,$base64String';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    final name = _nameController.text.trim();
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    
    final success = await ref.read(authProvider.notifier).updateProfile(
      name,
      avatarUrl: _selectedAvatarBase64,
      currentPassword: currentPassword.isNotEmpty ? currentPassword : null,
      newPassword: newPassword.isNotEmpty ? newPassword : null,
    );
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else if (mounted) {
      final error = ref.read(authProvider).error ?? 'Update failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar Picker
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      backgroundImage: _selectedAvatarBase64 != null
                          ? MemoryImage(base64Decode(_selectedAvatarBase64!.split(',').last))
                          : null,
                      child: _selectedAvatarBase64 == null
                          ? Icon(Icons.person, size: 50, color: Theme.of(context).colorScheme.primary)
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Display Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Name cannot be empty' : null,
              ),
              
              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Switch(
                    value: _isPasswordSectionVisible,
                    onChanged: (val) {
                      setState(() {
                        _isPasswordSectionVisible = val;
                        if (!val) {
                          _currentPasswordController.clear();
                          _newPasswordController.clear();
                        }
                      });
                    },
                  ),
                ],
              ),
              
              if (_isPasswordSectionVisible) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Current Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  validator: (val) {
                    if (_isPasswordSectionVisible && (val == null || val.isEmpty)) {
                      return 'Required to change password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'New Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.lock_reset),
                  ),
                  validator: (val) {
                    if (_isPasswordSectionVisible && (val == null || val.isEmpty)) {
                      return 'Required to change password';
                    }
                    if (_isPasswordSectionVisible && val!.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
              ],
              
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: authState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
