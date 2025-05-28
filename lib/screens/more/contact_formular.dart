import 'package:flutter/material.dart';

class ContactFormPage extends StatefulWidget {
  const ContactFormPage({Key? key}) : super(key: key);

  @override
  State<ContactFormPage> createState() => _ContactFormPageState();
}

class _ContactFormPageState extends State<ContactFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  String _name = '';
  String _email = '';
  String _message = '';

  final _nameRegex = RegExp(r"^[a-zA-ZäöüÄÖÜß\s\-]+$");
  final _emailRegex = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w{2,}$");

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Thank you! Your message got sent to us. You will hear from us in the next 48 hours.',
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'We’d love to hear from you!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Your Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name.';
                  }
                  if (!_nameRegex.hasMatch(value.trim())) {
                    return 'Only letters and spaces allowed.';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email Address'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email address.';
                  }
                  if (!_emailRegex.hasMatch(value.trim())) {
                    return 'Enter a valid email address.';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(labelText: 'Your Message'),
                maxLines: 5,
                maxLength: 2000,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your message.';
                  }
                  if (value.length > 2000) {
                    return 'Message must be 2000 characters or fewer.';
                  }
                  return null;
                },
                onSaved: (value) => _message = value!.trim(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _submitForm, child: const Text('Send')),
            ],
          ),
        ),
      ),
    );
  }
}
