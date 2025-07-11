import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
import 'l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _editing = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _displayNameController.text = user?.displayName ?? '';
    _emailController.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(_displayNameController.text.trim());
        
        // Update email if changed
        if (_emailController.text.trim() != user.email) {
          await user.updateEmail(_emailController.text.trim());
        }
        
        // Update password if provided
        if (_passwordController.text.isNotEmpty) {
          await user.updatePassword(_passwordController.text);
          _passwordController.clear();
        }
        
        await user.reload();
      }
      setState(() { _editing = false; });
    } on FirebaseAuthException catch (e) {
      setState(() { _error = e.message; });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.profile),
        backgroundColor: Colors.blue[800],
        actions: [
          if (!_editing)
            IconButton(
              icon: Icon(Icons.edit),
              tooltip: 'Edit Profile',
              onPressed: () => setState(() => _editing = true),
            ),
        ],
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, size: 60, color: Colors.blue[700]),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _displayNameController,
                    enabled: _editing,
                    decoration: InputDecoration(
                      labelText: 'Display Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Display name required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    enabled: _editing,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email required';
                      }
                      if (!value.contains('@')) {
                        return 'Invalid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  if (_editing)
                    TextFormField(
                      controller: _passwordController,
                      enabled: _editing,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'New Password (optional)',
                        border: OutlineInputBorder(),
                        helperText: 'Leave empty to keep current password',
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty && value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 24),
                  if (_error != null)
                    Text(_error!, style: TextStyle(color: Colors.red)),
                  if (_editing)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _loading ? null : _saveProfile,
                          child: _loading ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text('Save'),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton(
                          onPressed: _loading ? null : () => setState(() => _editing = false),
                          child: Text('Cancel'),
                        ),
                      ],
                    ),
                  if (!_editing) ...[
                    ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: Text(loc.logout),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Confirm Logout'),
                            content: Text('Are you sure you want to log out?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text('Logout'),
                              ),
                            ],
                          ),
                        );
                        if (shouldLogout == true) {
                          try {
                            await FirebaseAuth.instance.signOut();
                            if (!mounted) return;
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const AuthWrapper()),
                              (Route<dynamic> route) => false,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Logged out successfully')),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Logout failed: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 