import 'package:flutter/material.dart';
import 'change_password_page.dart';

class UserSection extends StatefulWidget {
  const UserSection({super.key});

  @override
  State<UserSection> createState() => _UserSectionState();
}

class _UserSectionState extends State<UserSection> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController(text: 'Max Mustermann');
  final _emailController = TextEditingController(text: 'max@tum.com');

  final _nameRegex = RegExp(r"^[a-zA-ZäöüÄÖÜß\s\-]+$");
  final _emailRegex = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w{2,}$");

  void _toggleEditing() {
    if (_isEditing) {
      if (_formKey.currentState!.validate()) {
        setState(() => _isEditing = false);
      }
    } else {
      setState(() => _isEditing = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Personal Data', _isEditing, _toggleEditing),
          const SizedBox(height: 16),
          _buildValidatedField(
            label: 'Username',
            controller: _usernameController,
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a username.';
              }
              if (!_nameRegex.hasMatch(value.trim())) {
                return 'Only letters, spaces and hyphens allowed.';
              }
              return null;
            },
          ),
          _buildValidatedField(
            label: 'E-Mail',
            controller: _emailController,
            enabled: _isEditing,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email.';
              }
              if (!_emailRegex.hasMatch(value.trim())) {
                return 'Enter a valid email address.';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Password',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordPage(),
                ),
              );
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(
    String title,
    bool isEditing,
    VoidCallback onEditToggle,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(isEditing ? Icons.check : Icons.edit),
          tooltip: isEditing ? 'Save' : 'Edit',
          onPressed: onEditToggle,
        ),
      ],
    );
  }

  Widget _buildValidatedField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade200,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
