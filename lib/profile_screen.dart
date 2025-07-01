import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final String name;
  final String email;

  const ProfileScreen({super.key, required this.name, required this.email});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    emailController = TextEditingController(text: widget.email);
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', nameController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile updated successfully!'),
        backgroundColor: Colors.teal,
      ),
    );

    Navigator.pop(context, {
      'name': nameController.text,
      'email': emailController.text,
    });
  }

  Future<void> _changePassword() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPassword = prefs.getString('password') ?? '';

    if (oldPasswordController.text != storedPassword) {
      _showError('Old password is incorrect.');
      return;
    }

    if (newPasswordController.text.length < 6) {
      _showError('New password must be at least 6 characters.');
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      _showError('New passwords do not match.');
      return;
    }

    await prefs.setString('password', newPasswordController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Password changed successfully!'),
        backgroundColor: Colors.teal,
      ),
    );

    oldPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'Edit Profile',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.teal[800],
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Profile'),
                ),
                const SizedBox(height: 32),
                Text(
                  'Change Password',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.teal[800],
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: oldPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Old Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _changePassword,
                  icon: const Icon(Icons.password),
                  label: const Text('Change Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
